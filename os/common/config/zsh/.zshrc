# ------------------------------------------------------------------------------
# Essential PATH (Homebrew만 먼저 설정)
# ------------------------------------------------------------------------------
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# ------------------------------------------------------------------------------
# Startup Display
# ------------------------------------------------------------------------------
if [[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "IntelliJ" && "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" && -z "$JEDI_TERM" && -z "$IDEA_INITIAL_DIRECTORY" ]]; then
  fastfetch --pipe false
fi

# ------------------------------------------------------------------------------
# Shell Startup
# ------------------------------------------------------------------------------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Only run in interactive shell
[[ $- == *i* ]] || return

# ------------------------------------------------------------------------------
# PATH and Environment Variables
# ------------------------------------------------------------------------------
# Locale
export LANG=en_US.UTF-8

# User Binaries
export PATH="$HOME/.local/bin:$PATH" # pipx etc
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Development Tools
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOMEBREW_PREFIX/opt/dotnet@8/libexec"

export PATH="$HOMEBREW_PREFIX/opt/luajit/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
if [[ -d "$HOME/.rd/bin" ]]; then
  export PATH="$HOME/.rd/bin:$PATH"
fi
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

export YSU_MESSAGE_POSITION="before"  # 명령어 실행 전 메시지 표시
export YSU_MODE=ALL                  # 모든 alias 제안 (기본은 최근 사용만)
export ENHANCD_FILTER="fzf --height 40% --reverse --border"
export ENHANCD_DOT_SHOW_FULLPATH=1  # .. 경로에서 전체 경로 표시
export ENHANCD_ENABLE_HOME=0        # 홈 디렉토리 히스토리 제외 (선택)
# atuin의 SQLite 데이터를 autosuggestions에 활용
export ATUIN_NOBIND="true"

export PROJECT_ROOT="$HOME/IdeaProjects"

# ------------------------------------------------------------------------------
# Plugin Management (zplug)
# ------------------------------------------------------------------------------
# Initialize zplug
export ZPLUG_HOME="$HOMEBREW_PREFIX/opt/zplug"
if [[ -f "$ZPLUG_HOME/init.zsh" ]]; then
  source "$ZPLUG_HOME/init.zsh"
fi

# zplug plugins
zplug "zsh-users/zsh-completions",              defer:0
zplug "zsh-users/zsh-autosuggestions",          defer:1
zplug "zsh-users/zsh-history-substring-search", defer:1

zplug "lib/completion",   from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/directories",  from:oh-my-zsh

zplug "plugins/git", from:oh-my-zsh
zplug "plugins/aws", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/yarn", from:oh-my-zsh

zplug "wfxr/forgit", defer:1
zplug "MichaelAquilina/zsh-you-should-use"
zplug "mroth/evalcache"
zplug "babarot/enhancd", use:init.sh

zplug "romkatv/zsh-defer"
# 사용 예: zsh-defer source ~/.fzf.zsh
zplug "romkatv/powerlevel10k", as:theme, depth:1

zplug "zsh-users/zsh-syntax-highlighting", defer:2

# zplug install if needed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then echo; zplug install; fi
fi

# Load plugins
zplug load

setopt extendedglob # glob qualifier 사용을 위해 필요

# Compinit optimization - check cache once a day
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
alias python="$HOMEBREW_PREFIX/bin/python3"
alias ls='lsd'
alias ll='ls -alhF'
alias vim='nvim'
alias vi='nvim'
alias cat="bat"
alias b-maint='brew update && brew upgrade && brew cleanup --prune=all && brew doctor'
alias ncc='npm cache clean --force'
alias kd='killall Dock'
alias bsl='brew services list'
alias vds='cd $PROJECT_ROOT/dev-init-setting && nvim .'
alias mcu='mac-cleanup'

alias aws-sso-login="aws sso login --sso-session sso-login"
alias dc-up-kalis='cd $PROJECT_ROOT/be/kalis-be-library && docker-compose up -d'
alias dc-stop-kalis='cd $PROJECT_ROOT/be/kalis-be-library && docker-compose stop'

alias ykp='cd $PROJECT_ROOT/fe/kalis-fe-pc && yarn kalis'
alias yka='cd $PROJECT_ROOT/fe/kalis-fe-admin && yarn kalis-office'

# =======================================================
# Git Wrapper 적용 (IntelliJ와 동일한 로직 공유): git-wrapper.sh의 실행 권한이 필요(chmod +x)
# =======================================================
if [[ -f "$HOME/git-wrapper.sh" ]]; then
  alias git="$HOME/git-wrapper.sh"
fi

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
function fzf-view() {
    fzf --preview '''[[ $(file --mime {}) =~ binary ]] &&
                  echo {} is a binary file ||
                  (bat --color=always {} ||
                  cat {}) 2> /dev/null | head -500'''
}

function bstart() {
  local service_to_start=$(brew services list | awk 'NR>1 {print $1}' | fzf)
  if [[ -n "$service_to_start" ]]; then
    brew services start "$service_to_start"
  fi
}

function bstop() {
  local service_to_stop=$(brew services list | grep started | awk '{print $1}' | fzf)
  if [[ -n "$service_to_stop" ]]; then
    brew services stop "$service_to_stop"
  fi
}

# ------------------------------------------------------------------------------
# Tool Initializations
# ------------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && zsh-defer source ~/.fzf.zsh

# mise with evalcache - 회사에서는 sdkman으로 대체
_evalcache mise activate zsh
# zsh-defer source "$HOME/.sdkman/bin/sdkman-init.sh"

# 설치 및 테스트
# brew install atuin
# atuin import auto  # 기존 zsh 히스토리 가져오기
# 명령어 히스토리 기반 추천 기능 활성화
zsh-defer _evalcache atuin init zsh --disable-up-arrow

# bun completions
[ -s "$HOME/.bun/_bun" ] && zsh-defer source "$HOME/.bun/_bun"

# Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh