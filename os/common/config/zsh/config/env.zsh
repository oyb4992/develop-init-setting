# PATH 중복 방지
typeset -U PATH

# Essential & Base Environment PATH
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export LANG=en_US.UTF-8
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Runtimes PATH
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOMEBREW_PREFIX/opt/dotnet@8/libexec"
export PATH="$HOMEBREW_PREFIX/opt/luajit/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PROJECT_ROOT="$HOME/Project"

# [경량화 핵심] 강력한 Zsh 히스토리 세부 옵션
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000

setopt append_history       # 히스토리 누적 추가
setopt share_history        # 여러 터미널 간 히스토리 실시간 공유
setopt hist_ignore_all_dups # 중복 명령어 정리
setopt hist_ignore_space    # 한 칸 띄우고 입력한 명령어는 기록 제외 (비밀번호 등 보호)
setopt hist_expire_dups_first
setopt auto_cd              # 디렉토리 이름만 쳐도 이동
setopt no_beep              # 불필요한 비프음 제거
setopt numeric_glob_sort    # 숫자 정렬 정상화

# 도구 관련 환경 변수
export ENHANCD_FILTER="fzf --height 40% --reverse --border"
export ENHANCD_DOT_SHOW_FULLPATH=1
export ENHANCD_ENABLE_HOME=0
export ATUIN_NOBIND="true"

# [영상 추천] Man 페이지 가독성을 높여주는 bat 페이저 설정
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# [영상 추천] FZF가 파일을 찾을 때 기본 find 대신 fd를 사용하도록 설정 (숨김 파일 포함, .git 제외)
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
fi