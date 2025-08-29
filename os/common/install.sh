#!/bin/bash
# Common setup script
set -euo pipefail

echo "--- Starting common setup ---"

# Get the absolute path of the script's directory
# This allows the script to be run from anywhere
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
COMMON_DIR=$(dirname "$SCRIPT_DIR") # This will be the 'os' directory
PROJECT_ROOT=$(dirname "$COMMON_DIR")

# --- Link common configurations ---
echo "Linking common configurations..."

# Zsh
ln -sfv "$PROJECT_ROOT/os/common/config/zsh/.zshrc" "$HOME/.zshrc"

# Kitty
mkdir -p "$HOME/.config/kitty"
ln -sfv "$PROJECT_ROOT/os/common/config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Neovim (editors)
mkdir -p "$HOME/.config/nvim"
ln -sfv "$PROJECT_ROOT/os/common/config/editors/init.vim" "$HOME/.config/nvim/init.vim"
ln -sfv "$PROJECT_ROOT/os/common/config/editors/.ideavimrc" "$HOME/.ideavimrc"

# --- Install common assets (e.g., fonts) ---
echo "Installing common assets (fonts)..."
if [ "$(uname -s)" == "Darwin" ]; then
    FONT_DIR="$HOME/Library/Fonts"
    mkdir -p "$FONT_DIR"
    cp -fv "$PROJECT_ROOT/os/common/assets/fonts/"* "$FONT_DIR/"
fi
# Add logic for Linux font installation if needed

echo "--- Common setup finished ---"
