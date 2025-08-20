#!/bin/bash

HOOK_SCRIPT='#!/bin/sh

BRANCH_NAME=$(git symbolic-ref --short HEAD 2>/dev/null)

if [ -n "$BRANCH_NAME" ] && [ "$2" != "merge" ] && [ "$2" != "squash" ]; then
    # KALIS-숫자 패턴 추출
    ISSUE_NUMBER=$(echo "$BRANCH_NAME" | grep -o "KALIS-[0-9]\+")

    if [ -n "$ISSUE_NUMBER" ] && ! grep -q "$ISSUE_NUMBER" "$1"; then
        sed -i.bak "1s/^/[$ISSUE_NUMBER] /" "$1"
    fi
fi'

# 모든 git 디렉토리에 Hook 설치
find . -name ".git" -type d | while read gitdir; do
    module_path=$(dirname "$gitdir")
    echo "Installing KALIS hook for: $module_path"

    # Hook 파일 생성
    echo "$HOOK_SCRIPT" > "$gitdir/hooks/prepare-commit-msg"
    chmod +x "$gitdir/hooks/prepare-commit-msg"

    echo "✅ Hook installed in $gitdir/hooks/"
done

echo "🎉 All hooks installed successfully!"