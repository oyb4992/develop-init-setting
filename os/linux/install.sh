#!/bin/bash
set -euo pipefail

echo "--- Starting Linux VPS setup ---"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LINUX_DIR=$SCRIPT_DIR
SUDO=sudo

if [ "$(id -u)" -eq 0 ]; then
    SUDO=
fi

link_file() {
    local source_path=$1
    local target_path=$2
    local target_dir

    target_dir=$(dirname "$target_path")
    mkdir -p "$target_dir"
    ln -sfv "$source_path" "$target_path"
}

install_apt_packages() {
    local packages_file="$LINUX_DIR/packages/apt.txt"
    local available_packages=()
    local skipped_packages=()
    local package

    if ! command -v apt-get >/dev/null 2>&1; then
        echo "ERROR: This Linux installer currently supports apt-based Ubuntu/Debian systems only." >&2
        exit 1
    fi

    if [ ! -f "$packages_file" ]; then
        echo "ERROR: Package list not found: $packages_file" >&2
        exit 1
    fi

    echo "Installing Ubuntu VPS packages..."
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
        echo "WARN: Packages not found in current apt sources: ${skipped_packages[*]}"
    fi
}

configure_security() {
    if [[ "${APPLY_SECURITY:-0}" != "1" ]]; then
        echo "Skipping firewall/security changes. Set APPLY_SECURITY=1 to configure ufw, fail2ban, and unattended-upgrades."
        return
    fi

    echo "Configuring VPS security defaults..."
    $SUDO ufw allow OpenSSH
    $SUDO ufw --force enable
    $SUDO systemctl enable --now fail2ban
    $SUDO dpkg-reconfigure -f noninteractive unattended-upgrades
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

echo "Linking Linux VPS configurations..."
link_file "$LINUX_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
link_file "$LINUX_DIR/config/tmux/.tmux.conf" "$HOME/.tmux.conf"

configure_security
configure_shell

echo ""
echo "=========================================="
echo "    Linux VPS Setup Complete!             "
echo "=========================================="
echo "Next steps:"
echo "1. Restart your SSH session or run: exec zsh"
echo "2. Start the OpenClaw tmux workspace: octmux"
echo "3. Review SSH hardening example: $LINUX_DIR/config/ssh/sshd_config.example"
echo ""
