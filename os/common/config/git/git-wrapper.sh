#!/bin/zsh

# =======================================================
# .zshrc에 Git Wrapper 적용 (IntelliJ와 동일한 로직 공유)
# =======================================================
# alias git="$HOME/git-wrapper.sh"

# 1. 실제 Git 경로 (터미널에서 'which git'으로 확인한 경로)
# 보통 Mac은 /usr/bin/git 또는 /opt/homebrew/bin/git
REAL_GIT="/opt/homebrew/bin/git"

# -----------------------------------------------------------
# [설정] 보호하고 싶은 프로젝트의 루트 경로들을 적어주세요.
# 이 경로(또는 그 하위 폴더)에서 실행될 때만 차단 로직이 동작합니다.
# 예시: "/Users/내이름/Work/my-project"
PROTECTED_PATHS=(
    "$PROJECT_ROOT/be"
    "$PROJECT_ROOT/fe"
    "$PROJECT_ROOT/flyway"
    "$PROJECT_ROOT/KALis"
)
# -----------------------------------------------------------

# 2. 현재 실행 위치가 보호 대상인지 확인
CURRENT_DIR=$(pwd)
IS_TARGET_PROJECT=false

for path in "${PROTECTED_PATHS[@]}"; do
    # 현재 위치가 설정한 경로로 시작하는지 확인 (하위 폴더 포함)
    if [[ "$CURRENT_DIR" == "$path"* ]]; then
        IS_TARGET_PROJECT=true
        break
    fi
done

# 보호 대상 경로가 아니면, 검사 없이 바로 Git 실행하고 종료! 🚀
if [ "$IS_TARGET_PROJECT" = false ]; then
    "$REAL_GIT" "$@"
    exit $?
fi


# === 아래부터는 기존 차단 로직과 동일합니다 ===

# 3. 현재 브랜치 확인
CURRENT_BRANCH=$("$REAL_GIT" symbolic-ref --short HEAD 2>/dev/null)

# 4. 명령어 및 인자 분석
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

# 5. 차단 실행
# 조건: [보호 경로임] AND [feat 브랜치] AND [pull/merge] AND [develop 포함]
if [[ "$CURRENT_BRANCH" == feat* ]] && [ "$IS_RESTRICTED_CMD" = true ] && [ "$HAS_TARGET_BRANCH" = true ]; then
    echo "⛔️ [BLOCKED by Wrapper] 이 프로젝트는 'develop' 직접 머지가 제한되어 있습니다." >&2
    echo "   📂 감지된 경로: $CURRENT_DIR" >&2
    echo "👉 전략: develop -> stage -> feat 순서를 지켜주세요." >&2
    exit 1
fi

# 6. 통과 시 실행
"$REAL_GIT" "$@"