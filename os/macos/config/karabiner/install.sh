#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Karabiner 설정 디렉토리 생성
mkdir -p ~/.config/karabiner

# Karabiner 설정 파일 복사
cp "$SCRIPT_DIR/karabiner.json" ~/.config/karabiner/karabiner.json

echo "Karabiner 설정이 완료되었습니다."
