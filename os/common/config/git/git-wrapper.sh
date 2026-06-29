#!/bin/zsh

REAL_GIT="${REAL_GIT:-$(command -v git)}"

if [[ -z "$REAL_GIT" || ! -x "$REAL_GIT" ]]; then
    echo "[git-wrapper] git executable not found." >&2
    exit 127
fi

PROTECTED_PATHS=(
    "$PROJECT_ROOT/be"
    "$PROJECT_ROOT/fe"
    "$PROJECT_ROOT/flyway"
    "$PROJECT_ROOT/Keis"
)

CURRENT_DIR=$(pwd)
IS_TARGET_PROJECT=false

for path in "${PROTECTED_PATHS[@]}"; do
    if [[ "$CURRENT_DIR" == "$path"* ]]; then
        IS_TARGET_PROJECT=true
        break
    fi
done

if [ "$IS_TARGET_PROJECT" = false ]; then
    "$REAL_GIT" "$@"
    exit $?
fi

CURRENT_BRANCH=$("$REAL_GIT" symbolic-ref --short HEAD 2>/dev/null)

IS_RESTRICTED_CMD=false
HAS_TARGET_BRANCH=false

for arg in "$@"; do
    if [[ "$arg" == "pull" ]] || [[ "$arg" == "merge" ]]; then
        IS_RESTRICTED_CMD=true
    fi
    if [[ "$arg" == *"develop"* ]]; then
        HAS_TARGET_BRANCH=true
    fi
done

if [[ "$CURRENT_BRANCH" == feat* ]] && [ "$IS_RESTRICTED_CMD" = true ] && [ "$HAS_TARGET_BRANCH" = true ]; then
    echo "[BLOCKED by Wrapper] 이 프로젝트는 'develop' 직접 머지가 제한되어 있습니다." >&2
    echo "   감지된 경로: $CURRENT_DIR" >&2
    echo "   전략: develop -> stage -> feat 순서를 지켜주세요." >&2
    exit 1
fi

"$REAL_GIT" "$@"
