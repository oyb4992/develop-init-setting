#!/bin/bash
set -euo pipefail

echo "--- Starting Ubuntu KDE Plasma desktop setup ---"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DESKTOP_DIR=$SCRIPT_DIR
PROJECT_ROOT=$(dirname "$(dirname "$(dirname "$DESKTOP_DIR")")")
SUDO=sudo

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

echo "Skipping KDE Plasma config linking. Plasma stores user state in shared config files; keep shortcut and panel changes manual."

install_flatpak_packages
install_snap_packages
configure_shell

echo ""
echo "=========================================="
echo "    Ubuntu KDE Desktop Setup Complete!    "
echo "=========================================="
echo "Next steps:"
echo "1. Log out and choose the Plasma session from the display manager."
echo "2. Use KRunner (Alt+Space by default) for app launching."
echo "3. Review KDE shortcuts in System Settings if you want AeroSpace-style bindings."
echo "4. Reboot if Snap, Flatpak, fonts, or session entries do not appear immediately."
echo ""
