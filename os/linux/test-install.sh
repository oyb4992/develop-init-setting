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
