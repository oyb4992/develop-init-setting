#!/bin/bash
# Common setup script
set -euo pipefail

echo "--- Starting common setup ---"

# Get the absolute path of the script's directory
# This allows the script to be run from anywhere
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
COMMON_DIR=$(dirname "$SCRIPT_DIR") # This will be the 'os' directory
PROJECT_ROOT=$(dirname "$COMMON_DIR")

link_file() {
    local source_path=$1
    local target_path=$2
    local target_dir

    target_dir=$(dirname "$target_path")
    mkdir -p "$target_dir"
    ln -sfv "$source_path" "$target_path"
}

install_tmux_plugin_manager() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [ -d "$tpm_dir/.git" ]; then
        echo "TPM already installed: $tpm_dir"
        return
    fi

    if ! command -v git >/dev/null 2>&1; then
        echo "WARN: git not found. Skipping TPM installation."
        return
    fi

    echo "Installing TPM (Tmux Plugin Manager)..."
    mkdir -p "$(dirname "$tpm_dir")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

# --- Link common configurations ---
echo "Linking common configurations..."

# Zsh
link_file "$PROJECT_ROOT/os/common/config/zsh/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.config/zsh"
for zsh_config_file in "$PROJECT_ROOT"/os/common/config/zsh/config/*.zsh; do
    link_file "$zsh_config_file" "$HOME/.config/zsh/$(basename "$zsh_config_file")"
done

# Git wrapper used by .zshrc
chmod +x "$PROJECT_ROOT/os/common/config/git/git-wrapper.sh"
link_file "$PROJECT_ROOT/os/common/config/git/git-wrapper.sh" "$HOME/git-wrapper.sh"

# LazyVim-style IdeaVim config
link_file "$PROJECT_ROOT/os/common/config/editors/lazyVim/.idea-lazy.vim" "$HOME/.idea-lazy.vim"
link_file "$PROJECT_ROOT/os/common/config/editors/lazyVim/.idea-lazy.vim" "$HOME/.ideavimrc"

# Ghostty
link_file "$PROJECT_ROOT/os/common/config/ghostty/config.ghostty" "$HOME/.config/ghostty/config"

# Starship
link_file "$PROJECT_ROOT/os/common/config/system/starship/starship.toml" "$HOME/.config/starship.toml"

# tmux
link_file "$PROJECT_ROOT/os/common/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
install_tmux_plugin_manager

# Zed (Vim mode)
link_file "$PROJECT_ROOT/os/common/config/zed/settings.json" "$HOME/.config/zed/settings.json"
link_file "$PROJECT_ROOT/os/common/config/zed/keymap.json" "$HOME/.config/zed/keymap.json"

# --- Install common assets (e.g., fonts) ---
echo "Installing common assets (fonts)..."
if [ "$(uname -s)" == "Darwin" ]; then
    FONT_DIR="$HOME/Library/Fonts"
    mkdir -p "$FONT_DIR"
    cp -fv "$PROJECT_ROOT/os/common/assets/fonts/"* "$FONT_DIR/"
elif [ "$(uname -s)" == "Linux" ]; then
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    cp -fv "$PROJECT_ROOT/os/common/assets/fonts/"* "$FONT_DIR/"
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$FONT_DIR"
    fi
fi

echo "--- Common setup finished ---"
