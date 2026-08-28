#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALLER="$SCRIPT_DIR/install.sh"

configure_security_source=$(sed -n '/^configure_security() {$/,/^}$/p' "$INSTALLER")
if [ -z "$configure_security_source" ]; then
    echo "ERROR: configure_security function not found in $INSTALLER" >&2
    exit 1
fi
eval "$configure_security_source"

calls=()
ufw() { calls+=("ufw $*"); }
systemctl() { calls+=("systemctl $*"); }
dpkg-reconfigure() { calls+=("dpkg-reconfigure $*"); }
SUDO=

unset APPLY_SECURITY
configure_security >/dev/null
if [ "${#calls[@]}" -ne 0 ]; then
    echo "ERROR: default install changed security services: ${calls[*]}" >&2
    exit 1
fi

calls=()
APPLY_SECURITY=1 configure_security >/dev/null
expected=(
    "ufw allow OpenSSH"
    "ufw --force enable"
    "systemctl enable --now fail2ban"
    "dpkg-reconfigure -f noninteractive unattended-upgrades"
)
if [ "${calls[*]}" != "${expected[*]}" ]; then
    echo "ERROR: APPLY_SECURITY=1 calls differ: ${calls[*]}" >&2
    exit 1
fi

echo "PASS: Linux security changes stay opt-in"

ROOT_DIR=$(cd "$SCRIPT_DIR/../.." && pwd)
ROOT_INSTALLER="$ROOT_DIR/install.sh"
MOCK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/dev-init-dispatch-test.XXXXXX")
trap 'rm -rf "$MOCK_DIR"' EXIT

printf '%s\n' '#!/bin/bash' 'printf "Linux\\n"' > "$MOCK_DIR/uname"
printf '%s\n' \
    '#!/bin/bash' \
    'if [ "${LINUX_PROFILE+x}" = x ]; then' \
    '    profile="set:$LINUX_PROFILE"' \
    'else' \
    '    profile="unset"' \
    'fi' \
    'printf "%s\\t%s\\n" "$profile" "$*" >> "$DISPATCH_CALLS_FILE"' \
    > "$MOCK_DIR/bash"
chmod +x "$MOCK_DIR/uname" "$MOCK_DIR/bash"

assert_vps_dispatch() {
    local profile=$1
    local expected_profile=$2
    local calls_file="$MOCK_DIR/calls"
    local actual
    local expected

    : > "$calls_file"
    if [ "$profile" = "__unset__" ]; then
        env -u LINUX_PROFILE PATH="$MOCK_DIR:$PATH" DISPATCH_CALLS_FILE="$calls_file" \
            /bin/bash "$ROOT_INSTALLER" >/dev/null
    else
        LINUX_PROFILE="$profile" PATH="$MOCK_DIR:$PATH" DISPATCH_CALLS_FILE="$calls_file" \
            /bin/bash "$ROOT_INSTALLER" >/dev/null
    fi

    actual=$(<"$calls_file")
    expected="$expected_profile"$'\t'"$ROOT_DIR/os/linux/install.sh"
    if [ "$actual" != "$expected" ]; then
        echo "ERROR: Linux dispatcher calls differ for $expected_profile: $actual" >&2
        exit 1
    fi
}

assert_vps_dispatch "__unset__" "unset"
assert_vps_dispatch "desktop" "set:desktop"
assert_vps_dispatch "dev-desktop" "set:dev-desktop"

echo "PASS: Linux dispatcher always runs only the VPS installer"
