# PATH 중복 방지
typeset -U PATH

# ------------------------------------------------------------------------------
# Essential PATH
# ------------------------------------------------------------------------------
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# ------------------------------------------------------------------------------
# Locale
# ------------------------------------------------------------------------------
export LANG=en_US.UTF-8

# ------------------------------------------------------------------------------
# Base Environment & PATH
# ------------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH" # pipx etc
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOMEBREW_PREFIX/opt/dotnet@8/libexec"

export PATH="$HOMEBREW_PREFIX/opt/luajit/bin:$PATH"

export PROJECT_ROOT="$HOME/Project"

# Colima 미사용시 주석 해제.
# ### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
# if [[ -d "$HOME/.rd/bin" ]]; then
#   export PATH="$HOME/.rd/bin:$PATH"
# fi
# ### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# ------------------------------------------------------------------------------
# Shared Helpers
# ------------------------------------------------------------------------------
function is_plain_terminal_session() {
  [[ "$TERM_PROGRAM" != "vscode" && \
     "$TERM_PROGRAM" != "IntelliJ" && \
     "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" && \
     -z "$JEDI_TERM" && \
     -z "$IDEA_INITIAL_DIRECTORY" ]]
}

# ------------------------------------------------------------------------------
# Powerlevel10k Instant Prompt
# ------------------------------------------------------------------------------
if is_plain_terminal_session; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi

# ------------------------------------------------------------------------------
# Runtime Manager (즉시 로드)
# ------------------------------------------------------------------------------
# mise를 사용할 때
# if command -v mise >/dev/null 2>&1; then
#   export MISE_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mise"
#   eval "$(mise activate zsh)"
# fi

# nvm fallback 예시
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# sdkman 사용 환경
if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# ------------------------------------------------------------------------------
# Shell Options & Tool Environment
# ------------------------------------------------------------------------------
export YSU_MESSAGE_POSITION="before"  # 명령어 실행 전 메시지 표시
export YSU_MODE=BESTMATCH             # 모든 alias 제안 (기본은 최근 사용만)
export ENHANCD_FILTER="fzf --height 40% --reverse --border"
export ENHANCD_DOT_SHOW_FULLPATH=1    # .. 경로에서 전체 경로 표시
export ENHANCD_ENABLE_HOME=0          # 홈 디렉토리 히스토리 제외 (선택)
export ATUIN_NOBIND="true"            # atuin의 SQLite 데이터를 autosuggestions에 활용

# ------------------------------------------------------------------------------
# Plugin Management (zplug)
# ------------------------------------------------------------------------------
export ZPLUG_HOME="$HOMEBREW_PREFIX/opt/zplug"
if [[ -f "$ZPLUG_HOME/init.zsh" ]]; then
  source "$ZPLUG_HOME/init.zsh"

  zplug "zsh-users/zsh-completions",              defer:0
  zplug "zsh-users/zsh-autosuggestions",          defer:1
  zplug "zsh-users/zsh-history-substring-search", defer:1

  zplug "lib/completion",   from:oh-my-zsh
  zplug "lib/key-bindings", from:oh-my-zsh
  zplug "lib/directories",  from:oh-my-zsh

  zplug "plugins/git", from:oh-my-zsh
  zplug "plugins/aws", from:oh-my-zsh
  zplug "plugins/docker", from:oh-my-zsh
  zplug "plugins/npm", from:oh-my-zsh
  zplug "plugins/yarn", from:oh-my-zsh

  # zplug "wfxr/forgit", defer:1
  zplug "MichaelAquilina/zsh-you-should-use"
  zplug "mroth/evalcache"
  zplug "babarot/enhancd", use:init.sh

  zplug "romkatv/zsh-defer"
  zplug "romkatv/powerlevel10k", as:theme, depth:1

  zplug "zsh-users/zsh-syntax-highlighting", defer:2

  if ! zplug check; then
    printf "Install? [y/N]: "
    if read -q; then echo; zplug install; fi
  fi

  zplug load
fi

setopt extendedglob

# ------------------------------------------------------------------------------
# Completion Init
# ------------------------------------------------------------------------------
autoload -Uz compinit

zsh_config_dir="${ZDOTDIR:-$HOME}"
zcompdump="$zsh_config_dir/.zcompdump"
if [[ ! -s "$zcompdump" || "$zcompdump" -ot "$zsh_config_dir/.zshrc" ]]; then
  compinit
else
  compinit -C
fi
unset zsh_config_dir zcompdump

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
alias python="$HOMEBREW_PREFIX/bin/python3"
alias ls='lsd'
alias ll='ls -alhF'
alias vim='nvim'
alias vi='nvim'
alias cat="bat"
alias cdh="cd $HOME"
alias cdb="cd $PROJECT_ROOT/be/kalis-be-library/"
alias cdf="cd $PROJECT_ROOT/fe"
alias cl="clear"
alias b-maint='brew update && brew upgrade && brew cleanup --prune=all && brew doctor'
alias ncc='npm cache clean --force'
alias kd='killall Dock'
alias bsl='brew services list'
alias vds='cd $PROJECT_ROOT/dev-init-setting && nvim .'
alias mc='mole clean --dry-run'
alias vzh='vim $HOME/.zshrc'
alias szh='source $HOME/.zshrc'
alias cs="colima start"
alias ct="colima stop"
# alias soc="ssh -i ~/Documents/KEY/2026/02/ssh-key-2026-02-17.key ubuntu@168.107.22.152"
# alias n8ns="ssh -i ~/Documents/KEY/2026/02/ssh-key-2026-02-17.key -N -L 5678:127.0.0.1:5678 ubuntu@168.107.22.152"

# alias aws-sso-login="aws sso login --sso-session sso-login"
# alias dc-up-kalis='cd $PROJECT_ROOT/be/kalis-be-library && docker compose up -d'
# alias dc-stop-kalis='cd $PROJECT_ROOT/be/kalis-be-library && docker compose stop'

# alias ykp='cd $PROJECT_ROOT/fe/kalis-fe-pc && yarn kalis'
# alias yka='cd $PROJECT_ROOT/fe/kalis-fe-admin && yarn kalis-office'

# =======================================================
# Git Wrapper 적용 (IntelliJ와 동일한 로직 공유)
# =======================================================
if [[ -f "$HOME/git-wrapper.sh" ]]; then
  alias git="$HOME/git-wrapper.sh"
fi

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
function fzf-view() {
  fzf --preview '[[ $(file --mime {}) =~ binary ]] &&
                echo {} is a binary file ||
                (bat --color=always {} ||
                command cat {}) 2> /dev/null | head -500'
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

# 1. fzf 설정
if (( $+functions[zsh-defer] )); then
  [ -f ~/.fzf.zsh ] && zsh-defer source ~/.fzf.zsh
else
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# 2. atuin 설정
if command -v atuin >/dev/null 2>&1; then
  if (( $+functions[_evalcache] )); then
    _evalcache atuin init zsh --disable-up-arrow
  else
    eval "$(atuin init zsh --disable-up-arrow)"
  fi
fi

# 3. bun completions
if (( $+functions[zsh-defer] )); then
  [ -s "$HOME/.bun/_bun" ] && zsh-defer source "$HOME/.bun/_bun"
else
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
fi

# ------------------------------------------------------------------------------
# Theme
# ------------------------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ------------------------------------------------------------------------------
# tmux auto start
# ------------------------------------------------------------------------------
if command -v tmux &> /dev/null && \
   [ -z "$TMUX" ] && \
   is_plain_terminal_session; then
  tmux new-session -A -s main
fi
