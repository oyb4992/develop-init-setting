#!/bin/bash
set -euo pipefail

echo "--- Starting Ubuntu KDE Plasma desktop setup ---"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DESKTOP_DIR=$SCRIPT_DIR
PROJECT_ROOT=$(dirname "$(dirname "$(dirname "$DESKTOP_DIR")")")
SUDO=sudo
KROHNKITE_CONFIG_APPLIED=0
KROHNKITE_READY=0

if [ "$(id -u)" -eq 0 ]; then
    SUDO=
fi

install_apt_packages() {
    local packages_file="$DESKTOP_DIR/packages/apt.txt"
    local available_packages=()
    local skipped_packages=()
    local package

    if ! command -v apt-get >/dev/null 2>&1; then
        echo "ERROR: This desktop installer currently supports apt-based Ubuntu/Debian systems only." >&2
        exit 1
    fi

    if [ ! -f "$packages_file" ]; then
        echo "ERROR: Package list not found: $packages_file" >&2
        exit 1
    fi

    echo "Installing Ubuntu KDE Plasma desktop apt packages..."
    $SUDO apt-get update

    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" == \#* ]] && continue

        if apt-cache show "$package" >/dev/null 2>&1; then
            available_packages+=("$package")
        else
            skipped_packages+=("$package")
        fi
    done < "$packages_file"

    if [ "${#available_packages[@]}" -gt 0 ]; then
        $SUDO apt-get install -y "${available_packages[@]}"
    fi

    if [ "${#skipped_packages[@]}" -gt 0 ]; then
        echo "WARN: Apt packages not found in current sources: ${skipped_packages[*]}"
    fi
}

install_flatpak_packages() {
    local packages_file="$DESKTOP_DIR/packages/flatpak.txt"
    local package

    if [ ! -f "$packages_file" ]; then
        echo "WARN: Flatpak package list not found: $packages_file"
        return
    fi

    if ! command -v flatpak >/dev/null 2>&1; then
        echo "WARN: flatpak not found after apt install. Skipping Flatpak apps."
        return
    fi

    echo "Configuring user Flathub remote..."
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    echo "Installing Flatpak desktop apps..."
    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" == \#* ]] && continue
        flatpak --user install -y --noninteractive flathub "$package" || echo "WARN: Failed to install Flatpak package: $package"
    done < "$packages_file"
}

install_snap_packages() {
    local packages_file="$DESKTOP_DIR/packages/snap.txt"
    local package_line

    if [ ! -f "$packages_file" ]; then
        echo "WARN: Snap package list not found: $packages_file"
        return
    fi

    if ! command -v snap >/dev/null 2>&1; then
        echo "WARN: snap not found after apt install. Skipping Snap apps."
        return
    fi

    echo "Installing Snap desktop apps..."
    while IFS= read -r package_line || [[ -n "$package_line" ]]; do
        [[ -z "$package_line" || "$package_line" == \#* ]] && continue
        read -r -a snap_args <<< "$package_line"
        $SUDO snap install "${snap_args[@]}" || echo "WARN: Failed to install Snap package: $package_line"
    done < "$packages_file"
}

cleanup_krohnkite_package() {
    local package_file=$1

    if [[ -n "$package_file" ]] && ! rm -f -- "$package_file"; then
        echo "WARN: Failed to remove temporary Krohnkite package: $package_file"
    fi

    return 0
}

get_krohnkite_installed_version() {
    local package_metadata=$1
    local metadata_line
    local package_path=

    while IFS= read -r metadata_line; do
        if [[ "$metadata_line" =~ ^[[:space:]]*Path[[:space:]]*:[[:space:]]*(.*)$ ]]; then
            package_path=${BASH_REMATCH[1]}
            package_path="${package_path#"${package_path%%[![:space:]]*}"}"
            package_path="${package_path%"${package_path##*[![:space:]]}"}"
            break
        fi
    done <<< "$package_metadata"

    if [[ -z "$package_path" ]] || ! command -v python3 >/dev/null 2>&1; then
        return 1
    fi

    python3 - "$package_path/metadata.json" 2>/dev/null <<'PY'
import json
import sys

try:
    with open(sys.argv[1], encoding="utf-8") as metadata_file:
        version = json.load(metadata_file)["KPlugin"]["Version"]
except (OSError, KeyError, TypeError, ValueError):
    raise SystemExit(1)

if not isinstance(version, str) or not version:
    raise SystemExit(1)

print(version)
PY
}

install_krohnkite() {
    local version="0.9.9.2"
    local package_url="https://codeberg.org/anametologin/Krohnkite/releases/download/$version/krohnkite.kwinscript"
    local expected_checksum="42f7f66531d366c74b5fc860381da3517ccb4cdccd1f80c122fcab6e9a8fcf7e"
    local package_metadata
    local installed_version=
    local package_file
    local package_action
    local checksum_output
    local actual_checksum

    KROHNKITE_READY=0

    if [ "$(id -u)" -eq 0 ]; then
        echo "WARN: Krohnkite is user-scoped. Run this installer as the desktop user to install it."
        return
    fi

    if ! command -v kpackagetool6 >/dev/null 2>&1; then
        echo "WARN: kpackagetool6 not found after apt install. Skipping Krohnkite."
        return
    fi

    if package_metadata=$(LC_ALL=C kpackagetool6 -t KWin/Script -s krohnkite 2>/dev/null); then
        installed_version=$(get_krohnkite_installed_version "$package_metadata") || installed_version=

        if [[ "$installed_version" == "$version" ]]; then
            KROHNKITE_READY=1
            echo "Krohnkite $version is already installed. Skipping."
            return
        fi

        package_action=-u
        if [[ -n "$installed_version" ]]; then
            echo "Upgrading Krohnkite from $installed_version to $version..."
        else
            echo "Upgrading Krohnkite to $version (installed version could not be determined)..."
        fi
    else
        package_action=-i
        echo "Installing Krohnkite $version..."
    fi

    if ! command -v sha256sum >/dev/null 2>&1; then
        if [[ "$package_action" == "-u" ]]; then
            echo "WARN: sha256sum not found. Skipping Krohnkite upgrade."
        else
            echo "WARN: sha256sum not found. Skipping Krohnkite install."
        fi
        return
    fi

    if ! package_file=$(mktemp "${TMPDIR:-/tmp}/krohnkite.XXXXXX"); then
        echo "WARN: Failed to create a temporary file for Krohnkite."
        return
    fi

    if ! curl --connect-timeout 15 --max-time 120 -fsSL "$package_url" -o "$package_file"; then
        echo "WARN: Failed to download Krohnkite."
        cleanup_krohnkite_package "$package_file"
        return
    fi

    if ! checksum_output=$(sha256sum "$package_file"); then
        echo "WARN: Failed to calculate the Krohnkite checksum."
        cleanup_krohnkite_package "$package_file"
        return
    fi

    read -r actual_checksum _ <<< "$checksum_output"
    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        echo "WARN: Krohnkite checksum verification failed."
        cleanup_krohnkite_package "$package_file"
        return
    fi

    if ! kpackagetool6 -t KWin/Script "$package_action" "$package_file"; then
        if [[ "$package_action" == "-u" ]]; then
            echo "WARN: Failed to upgrade Krohnkite."
        else
            echo "WARN: Failed to install Krohnkite."
        fi
        cleanup_krohnkite_package "$package_file"
        return
    fi

    KROHNKITE_READY=1
    cleanup_krohnkite_package "$package_file"
    if [[ "$package_action" == "-u" ]]; then
        echo "Krohnkite upgraded to $version."
    else
        echo "Krohnkite $version installed. Enable it in System Settings > Window Management > KWin Scripts."
    fi
}

apply_krohnkite_config() {
    local apply_script=$DESKTOP_DIR/apply-krohnkite-config.sh

    if [[ "${APPLY_KROHNKITE_CONFIG:-0}" != "1" ]]; then
        echo "Skipping Krohnkite KDE configuration. Set APPLY_KROHNKITE_CONFIG=1 to merge the tracked settings."
        return
    fi

    if [[ "$KROHNKITE_READY" != "1" ]]; then
        echo "WARN: Required Krohnkite version 0.9.9.2 is not ready; skipping KDE configuration."
        return
    fi

    if [ ! -f "$apply_script" ]; then
        echo "WARN: Krohnkite configuration script not found: $apply_script"
        return
    fi

    if ! bash "$apply_script"; then
        echo "WARN: Krohnkite configuration failed; existing KDE backups were preserved."
        return
    fi

    KROHNKITE_CONFIG_APPLIED=1
}

configure_shell() {
    if [[ "${CHANGE_SHELL:-0}" != "1" ]]; then
        echo "Skipping default shell change. Set CHANGE_SHELL=1 to switch the current user to zsh."
        return
    fi

    local zsh_path
    zsh_path=$(command -v zsh)
    if [ "${SHELL:-}" != "$zsh_path" ]; then
        chsh -s "$zsh_path"
    fi
}

install_apt_packages

if [ -f "$PROJECT_ROOT/os/common/install.sh" ]; then
    echo "Running common setup for shared terminal/editor configuration..."
    bash "$PROJECT_ROOT/os/common/install.sh"
else
    echo "WARN: Common setup script not found, skipping."
fi

install_krohnkite
apply_krohnkite_config

echo "KDE shared state is not symlinked; Krohnkite settings merge only with APPLY_KROHNKITE_CONFIG=1."

install_flatpak_packages
install_snap_packages
configure_shell

echo ""
echo "=========================================="
echo "    Ubuntu KDE Desktop Setup Complete!    "
echo "=========================================="
echo "Next steps:"
if [[ "$KROHNKITE_CONFIG_APPLIED" == "1" ]]; then
    echo "1. Reboot immediately so KWin and KGlobalAccel load the merged Krohnkite settings."
    echo "2. Choose the Plasma session and confirm Krohnkite is enabled after login."
    echo "3. Use KRunner (Alt+Space by default) for app launching."
    echo "4. Verify the AeroSpace-style shortcuts and all ten virtual desktops."
elif [[ "${APPLY_KROHNKITE_CONFIG:-0}" == "1" && "$KROHNKITE_READY" != "1" ]]; then
    echo "1. Krohnkite 0.9.9.2 was not ready, so its tracked KDE configuration was not applied."
    echo "2. Resolve the Krohnkite install or upgrade warning, then rerun with APPLY_KROHNKITE_CONFIG=1."
    echo "3. Package and shell setup continued; choose the Plasma session after login."
    echo "4. Use KRunner (Alt+Space by default) for app launching."
elif [[ "${APPLY_KROHNKITE_CONFIG:-0}" == "1" ]]; then
    echo "1. Krohnkite configuration was not applied; review the configuration warning above."
    echo "2. Rerun with APPLY_KROHNKITE_CONFIG=1 after resolving the warning."
    echo "3. Package and shell setup continued; choose the Plasma session after login."
    echo "4. Use KRunner (Alt+Space by default) for app launching."
else
    echo "1. Log out and choose the Plasma session from the display manager."
    echo "2. Enable and configure Krohnkite in System Settings > Window Management > KWin Scripts."
    echo "3. Use KRunner (Alt+Space by default) for app launching."
    echo "4. Reboot if Krohnkite, Snap, Flatpak, fonts, or session entries do not appear immediately."
fi
echo ""
