#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SOURCE_DIR="$SCRIPT_DIR/config/krohnkite"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
TIMESTAMP="$(date +%Y%m%d%H%M%S).$$"

KWIN_SOURCE="$SOURCE_DIR/kwinrc"
SHORTCUTS_SOURCE="$SOURCE_DIR/kglobalshortcutsrc"
KWIN_TARGET="$TARGET_DIR/kwinrc"
SHORTCUTS_TARGET="$TARGET_DIR/kglobalshortcutsrc"

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Krohnkite KDE configuration is user-scoped; do not run this script as root." >&2
    exit 1
fi

for required_command in python3 kpackagetool6; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $required_command" >&2
        exit 1
    fi
done

for source_file in "$KWIN_SOURCE" "$SHORTCUTS_SOURCE"; do
    if [ ! -f "$source_file" ]; then
        echo "ERROR: Required Krohnkite configuration fragment not found: $source_file" >&2
        exit 1
    fi
done

if ! kpackagetool6 -t KWin/Script -s krohnkite >/dev/null 2>&1; then
    echo "ERROR: Krohnkite is not installed for the current user." >&2
    exit 1
fi

for target_file in "$KWIN_TARGET" "$SHORTCUTS_TARGET"; do
    if [ -L "$target_file" ]; then
        echo "ERROR: Refusing to replace symlinked KDE configuration: $target_file" >&2
        exit 1
    fi
done

python3 - "$KWIN_SOURCE" "$SHORTCUTS_SOURCE" "$KWIN_TARGET" "$SHORTCUTS_TARGET" "$TIMESTAMP" <<'PY'
import configparser
import errno
import fcntl
import hashlib
import os
import stat
import sys
import tempfile
import uuid


kwin_source, shortcuts_source, kwin_target, shortcuts_target, timestamp = sys.argv[1:]
config_pairs = (
    (kwin_source, kwin_target, True),
    (shortcuts_source, shortcuts_target, False),
)
lock_path = os.path.join(os.path.dirname(kwin_target), ".krohnkite-config-merge.lock")


class ConcurrentKDEChange(RuntimeError):
    pass


def report_exception(exception_type, exception, traceback):
    if issubclass(exception_type, ConcurrentKDEChange):
        print(f"ERROR: {exception}", file=sys.stderr)
        return
    sys.__excepthook__(exception_type, exception, traceback)


sys.excepthook = report_exception


def new_parser():
    parser = configparser.RawConfigParser(
        interpolation=None,
        delimiters=("=",),
        comment_prefixes=("#", ";"),
        inline_comment_prefixes=None,
        strict=True,
        empty_lines_in_values=False,
    )
    parser.optionxform = str
    return parser


def load_source_config(path):
    parser = new_parser()
    with open(path, encoding="utf-8") as config_file:
        parser.read_file(config_file, source=path)
    return parser


def stat_metadata(file_stat):
    return (
        file_stat.st_dev,
        file_stat.st_ino,
        file_stat.st_mode,
        file_stat.st_nlink,
        file_stat.st_uid,
        file_stat.st_gid,
        file_stat.st_size,
        file_stat.st_mtime_ns,
        file_stat.st_ctime_ns,
    )


def concurrent_change(path):
    raise ConcurrentKDEChange(
        "concurrent KDE settings change detected for "
        f"{path}; retry without editing System Settings while the apply is running."
    )


def open_readonly_no_follow(path):
    flags = os.O_RDONLY
    flags |= getattr(os, "O_CLOEXEC", 0)
    flags |= getattr(os, "O_NOFOLLOW", 0)
    if not hasattr(os, "O_NOFOLLOW") and os.path.islink(path):
        raise RuntimeError(f"refusing to replace symlinked KDE configuration: {path}")
    try:
        return os.open(path, flags)
    except OSError as error:
        if error.errno == errno.ELOOP:
            raise RuntimeError(
                f"refusing to replace symlinked KDE configuration: {path}"
            ) from error
        raise


def read_snapshot(path):
    try:
        file_descriptor = open_readonly_no_follow(path)
    except FileNotFoundError:
        return {
            "content": b"",
            "fingerprint": ("absent",),
            "stat": None,
        }

    try:
        before = os.fstat(file_descriptor)
        if not stat.S_ISREG(before.st_mode):
            raise RuntimeError(f"refusing to replace non-regular KDE configuration: {path}")

        try:
            path_stat = os.lstat(path)
        except FileNotFoundError:
            concurrent_change(path)
        if stat.S_ISLNK(path_stat.st_mode):
            raise RuntimeError(f"refusing to replace symlinked KDE configuration: {path}")
        if (path_stat.st_dev, path_stat.st_ino) != (before.st_dev, before.st_ino):
            concurrent_change(path)

        chunks = []
        while True:
            chunk = os.read(file_descriptor, 1024 * 1024)
            if not chunk:
                break
            chunks.append(chunk)
        content = b"".join(chunks)
        after = os.fstat(file_descriptor)
    finally:
        os.close(file_descriptor)

    if stat_metadata(before) != stat_metadata(after) or len(content) != after.st_size:
        concurrent_change(path)

    fingerprint = (
        "present",
        *stat_metadata(after),
        hashlib.sha256(content).digest(),
    )
    return {
        "content": content,
        "fingerprint": fingerprint,
        "stat": after,
    }


def parse_snapshot(snapshot, path):
    parser = new_parser()
    if snapshot["fingerprint"][0] == "present":
        parser.read_string(snapshot["content"].decode("utf-8"), source=path)
    return parser


def verify_unchanged(path, expected_fingerprint):
    if read_snapshot(path)["fingerprint"] != expected_fingerprint:
        concurrent_change(path)


def installed_result_fingerprint(snapshot):
    if snapshot["fingerprint"][0] == "absent":
        return ("absent",)

    file_stat = snapshot["stat"]
    return (
        "present",
        file_stat.st_mode,
        file_stat.st_uid,
        file_stat.st_gid,
        file_stat.st_size,
        hashlib.sha256(snapshot["content"]).digest(),
    )


def warn_rollback_skipped(target_path, backup_path, detail):
    message = (
        "WARNING: rollback was skipped to protect a concurrent KDE change for "
        f"{target_path}; {detail}."
    )
    if backup_path is not None:
        message += f" Preserved backup for manual recovery: {backup_path}"
    else:
        message += " No original backup exists; preserved the current target state."
    print(message, file=sys.stderr)


def merge_config(source, target, is_kwin):

    existing_desktop_ids = {}
    if is_kwin and target.has_section("Desktops"):
        for index in range(1, 11):
            key = f"Id_{index}"
            value = target.get("Desktops", key, raw=True, fallback="")
            if value.strip():
                existing_desktop_ids[key] = value

    for section in source.sections():
        if not target.has_section(section):
            target.add_section(section)
        for key, value in source.items(section, raw=True):
            target.set(section, key, value)

    if is_kwin:
        if not target.has_section("Desktops"):
            target.add_section("Desktops")
        for index in range(1, 11):
            key = f"Id_{index}"
            if key in existing_desktop_ids:
                target.set("Desktops", key, existing_desktop_ids[key])
            elif not target.get("Desktops", key, raw=True, fallback="").strip():
                target.set("Desktops", key, str(uuid.uuid4()))

    return target


def render_config(parser, target_path, mode):
    target_directory = os.path.dirname(target_path)
    target_name = os.path.basename(target_path)
    file_descriptor, temporary_path = tempfile.mkstemp(
        prefix=f".{target_name}.tmp.{timestamp}.",
        dir=target_directory,
        text=True,
    )
    try:
        os.fchmod(file_descriptor, mode)
        with os.fdopen(file_descriptor, "w", encoding="utf-8", newline="") as temporary_file:
            parser.write(temporary_file, space_around_delimiters=False)
            temporary_file.flush()
            os.fsync(temporary_file.fileno())
    except BaseException:
        try:
            os.close(file_descriptor)
        except OSError:
            pass
        try:
            os.unlink(temporary_path)
        except FileNotFoundError:
            pass
        raise
    return temporary_path


def write_all(file_descriptor, content):
    offset = 0
    while offset < len(content):
        written = os.write(file_descriptor, content[offset:])
        if written == 0:
            raise OSError("short write while preserving KDE configuration")
        offset += written


def create_backup(target_path, snapshot):
    backup_path = f"{target_path}.bak.{timestamp}"
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    flags |= getattr(os, "O_CLOEXEC", 0)
    flags |= getattr(os, "O_NOFOLLOW", 0)
    file_descriptor = os.open(backup_path, flags, 0o600)
    try:
        write_all(file_descriptor, snapshot["content"])
        os.fchmod(file_descriptor, stat.S_IMODE(snapshot["stat"].st_mode))
        os.fsync(file_descriptor)
    except BaseException:
        os.close(file_descriptor)
        try:
            os.unlink(backup_path)
        except FileNotFoundError:
            pass
        raise
    else:
        os.close(file_descriptor)

    os.utime(
        backup_path,
        ns=(snapshot["stat"].st_atime_ns, snapshot["stat"].st_mtime_ns),
        follow_symlinks=False,
    )
    return backup_path


def restore_snapshot(target_path, snapshot, expected_installed_fingerprint):
    target_directory = os.path.dirname(target_path)
    target_name = os.path.basename(target_path)
    file_descriptor, temporary_path = tempfile.mkstemp(
        prefix=f".{target_name}.rollback.{timestamp}.",
        dir=target_directory,
    )
    try:
        write_all(file_descriptor, snapshot["content"])
        os.fchmod(file_descriptor, stat.S_IMODE(snapshot["stat"].st_mode))
        os.fsync(file_descriptor)
        os.close(file_descriptor)
        file_descriptor = None
        os.utime(
            temporary_path,
            ns=(snapshot["stat"].st_atime_ns, snapshot["stat"].st_mtime_ns),
            follow_symlinks=False,
        )
        current_fingerprint = installed_result_fingerprint(
            read_snapshot(target_path)
        )
        if current_fingerprint != expected_installed_fingerprint:
            return False
        os.replace(temporary_path, target_path)
        return True
    finally:
        if file_descriptor is not None:
            os.close(file_descriptor)
        try:
            os.unlink(temporary_path)
        except FileNotFoundError:
            pass


def open_lock(path):
    flags = os.O_RDWR | os.O_CREAT
    flags |= getattr(os, "O_CLOEXEC", 0)
    flags |= getattr(os, "O_NOFOLLOW", 0)
    if not hasattr(os, "O_NOFOLLOW") and os.path.islink(path):
        raise RuntimeError(f"refusing symlinked Krohnkite merge lock: {path}")
    try:
        file_descriptor = os.open(path, flags, 0o600)
    except OSError as error:
        if error.errno == errno.ELOOP:
            raise RuntimeError(f"refusing symlinked Krohnkite merge lock: {path}") from error
        raise

    try:
        file_stat = os.fstat(file_descriptor)
        path_stat = os.lstat(path)
        if (
            not stat.S_ISREG(file_stat.st_mode)
            or file_stat.st_uid != os.getuid()
            or stat.S_ISLNK(path_stat.st_mode)
            or (path_stat.st_dev, path_stat.st_ino)
            != (file_stat.st_dev, file_stat.st_ino)
        ):
            raise RuntimeError(f"invalid Krohnkite merge lock: {path}")
        os.fchmod(file_descriptor, 0o600)
    except BaseException:
        os.close(file_descriptor)
        raise
    return file_descriptor


temporary_paths = {}
backup_paths = {}
originally_existed = {}
replaced_targets = []
target_snapshots = {}
expected_installed_fingerprints = {}

validated_sources = {}
for source_path, _, _ in config_pairs:
    validated_sources[source_path] = load_source_config(source_path)

os.makedirs(os.path.dirname(kwin_target), exist_ok=True)

lock_descriptor = open_lock(lock_path)
try:
    fcntl.flock(lock_descriptor, fcntl.LOCK_EX)
    try:
        for source_path, target_path, is_kwin in config_pairs:
            snapshot = read_snapshot(target_path)
            target_snapshots[target_path] = snapshot
            originally_existed[target_path] = snapshot["fingerprint"][0] == "present"
            target = parse_snapshot(snapshot, target_path)
            merged = merge_config(validated_sources[source_path], target, is_kwin)
            mode = (
                stat.S_IMODE(snapshot["stat"].st_mode)
                if originally_existed[target_path]
                else 0o600
            )
            temporary_path = render_config(merged, target_path, mode)
            temporary_paths[target_path] = temporary_path
            expected_installed_fingerprints[target_path] = (
                installed_result_fingerprint(read_snapshot(temporary_path))
            )

        for _, target_path, _ in config_pairs:
            verify_unchanged(
                target_path,
                target_snapshots[target_path]["fingerprint"],
            )

        for _, target_path, _ in config_pairs:
            if originally_existed[target_path]:
                backup_paths[target_path] = create_backup(
                    target_path,
                    target_snapshots[target_path],
                )

        try:
            for _, target_path, _ in config_pairs:
                verify_unchanged(
                    target_path,
                    target_snapshots[target_path]["fingerprint"],
                )
                os.replace(temporary_paths[target_path], target_path)
                temporary_paths.pop(target_path)
                replaced_targets.append(target_path)
        except BaseException:
            for target_path in reversed(replaced_targets):
                backup_path = backup_paths.get(target_path)
                expected_installed_fingerprint = (
                    expected_installed_fingerprints[target_path]
                )
                if originally_existed[target_path]:
                    try:
                        restored = restore_snapshot(
                            target_path,
                            target_snapshots[target_path],
                            expected_installed_fingerprint,
                        )
                    except BaseException as rollback_error:
                        warn_rollback_skipped(
                            target_path,
                            backup_path,
                            "the current target could not be safely restored "
                            f"({rollback_error})",
                        )
                        continue
                    if not restored:
                        warn_rollback_skipped(
                            target_path,
                            backup_path,
                            "the current target no longer matches the installed result",
                        )
                    continue

                try:
                    current_fingerprint = installed_result_fingerprint(
                        read_snapshot(target_path)
                    )
                except BaseException as rollback_check_error:
                    warn_rollback_skipped(
                        target_path,
                        backup_path,
                        "the current target could not be fingerprinted "
                        f"({rollback_check_error})",
                    )
                    continue

                if current_fingerprint != expected_installed_fingerprint:
                    warn_rollback_skipped(
                        target_path,
                        backup_path,
                        "the current target no longer matches the installed result",
                    )
                    continue

                try:
                    os.unlink(target_path)
                except BaseException as rollback_error:
                    warn_rollback_skipped(
                        target_path,
                        backup_path,
                        f"automatic rollback failed ({rollback_error})",
                    )
            raise
    finally:
        for temporary_path in temporary_paths.values():
            try:
                os.unlink(temporary_path)
            except FileNotFoundError:
                pass
        fcntl.flock(lock_descriptor, fcntl.LOCK_UN)
finally:
    os.close(lock_descriptor)

for _, target_path, _ in config_pairs:
    backup_path = backup_paths.get(target_path)
    if backup_path is not None:
        print(f"Backup: {backup_path}")
PY

echo "Krohnkite KDE configuration merged successfully into: $TARGET_DIR"
echo "Optional KWin rules example (not imported): $SOURCE_DIR/kwinrulesrc.example"
echo "Reboot immediately to apply the Krohnkite and KDE shortcut changes."
