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

# --- Link common configurations ---
echo "Linking common configurations..."

# Zsh
link_file "$PROJECT_ROOT/os/common/config/zsh/.zshrc" "$HOME/.zshrc"

# Git wrapper used by .zshrc
chmod +x "$PROJECT_ROOT/os/common/config/git/git-wrapper.sh"
link_file "$PROJECT_ROOT/os/common/config/git/git-wrapper.sh" "$HOME/git-wrapper.sh"

# LazyVim-style IdeaVim config
link_file "$PROJECT_ROOT/os/common/config/editors/lazyVim/.idea-lazy.vim" "$HOME/.idea-lazy.vim"
link_file "$PROJECT_ROOT/os/common/config/editors/lazyVim/.idea-lazy.vim" "$HOME/.ideavimrc"

# Ghostty
link_file "$PROJECT_ROOT/os/common/config/ghostty/config.ghostty" "$HOME/.config/ghostty/config"

# tmux
link_file "$PROJECT_ROOT/os/common/config/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Zed (Vim mode)
link_file "$PROJECT_ROOT/os/common/config/zed/settings.json" "$HOME/.config/zed/settings.json"
link_file "$PROJECT_ROOT/os/common/config/zed/keymap.json" "$HOME/.config/zed/keymap.json"

# --- Install common assets (e.g., fonts) ---
echo "Installing common assets (fonts)..."
if [ "$(uname -s)" == "Darwin" ]; then
    FONT_DIR="$HOME/Library/Fonts"
    mkdir -p "$FONT_DIR"
    cp -fv "$PROJECT_ROOT/os/common/assets/fonts/"* "$FONT_DIR/"
fi
# Add logic for Linux font installation if needed

echo "--- Common setup finished ---"
