#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../../../.." && pwd)

link_file() {
    local source_path=$1
    local target_path=$2
    local target_dir

    target_dir=$(dirname "$target_path")
    mkdir -p "$target_dir"
    ln -sfv "$source_path" "$target_path"
}

link_file "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

chmod +x "$PROJECT_ROOT/os/common/config/git/git-wrapper.sh"
link_file "$PROJECT_ROOT/os/common/config/git/git-wrapper.sh" "$HOME/git-wrapper.sh"

echo "Zsh configuration installed."
