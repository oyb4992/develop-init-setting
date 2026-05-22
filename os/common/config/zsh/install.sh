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

ORIGIN_DIR="$SCRIPT_DIR/config"

# 대상 폴더 생성 (없을 경우 대비)
mkdir -p ~/.config/zsh

# 반복문을 돌며 심볼릭 링크 생성
for file in env.zsh aliases.zsh bindings.zsh plugins.zsh functions.zsh; do
    ln -sf "$ORIGIN_DIR/$file" "$HOME/.config/zsh/$file"
    echo "🔗 Linked: ~/.config/zsh/$file -> $ORIGIN_DIR/$file"
done

chmod +x "$PROJECT_ROOT/os/common/config/git/git-wrapper.sh"
link_file "$PROJECT_ROOT/os/common/config/git/git-wrapper.sh" "$HOME/git-wrapper.sh"

echo "Zsh configuration installed."
