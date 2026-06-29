#!/bin/bash
set -euo pipefail

echo "--- Starting Ubuntu desktop development setup ---"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DEV_DESKTOP_DIR=$SCRIPT_DIR
PROJECT_ROOT=$(dirname "$(dirname "$(dirname "$DEV_DESKTOP_DIR")")")
SUDO=sudo

if [ "$(id -u)" -eq 0 ]; then
    SUDO=
fi

install_apt_packages() {
    local packages_file="$DEV_DESKTOP_DIR/packages/apt.txt"
    local available_packages=()
    local skipped_packages=()
    local package

    if ! command -v apt-get >/dev/null 2>&1; then
        echo "ERROR: This installer currently supports apt-based Ubuntu/Debian systems only." >&2
        exit 1
    fi

    if [ ! -f "$packages_file" ]; then
        echo "ERROR: Package list not found: $packages_file" >&2
        exit 1
    fi

    echo "Installing Ubuntu desktop development apt packages..."
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

configure_shell

echo ""
echo "=============================================="
echo "    Ubuntu Desktop Dev Setup Complete!        "
echo "=============================================="
echo "This mode does not install KDE Plasma, Flatpak apps, Snap apps, or display-manager packages."
echo "Review optional tools not available from Ubuntu 24.04 apt sources: starship, atuin, lazygit."
echo ""
