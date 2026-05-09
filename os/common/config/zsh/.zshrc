# zmodload zsh/zprof #zsh쉘 로딩 디버깅 모니터링 시작
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

export PROJECT_ROOT="$HOME/IdeaProjects"

# ------------------------------------------------------------------------------
# Shared Helpers
# ------------------------------------------------------------------------------
function is_zed_terminal_session() {
  [[ "$IN_ZED_TERMINAL" == "1" || "$ZED_TERM" == "true" ]]
}

function is_plain_terminal_session() {
  [[ "$TERM_PROGRAM" != "vscode" &&
     "$TERM_PROGRAM" != "IntelliJ" &&
     "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" &&
     -z "$JEDI_TERM" &&
     -z "$IDEA_INITIAL_DIRECTORY" ]]

  local is_plain=$?

  if is_zed_terminal_session; then
    return 1
  fi

  return $is_plain
}

if is_zed_terminal_session; then
  export EDITOR="zed --wait"
  export VISUAL="zed --wait"
fi

# ------------------------------------------------------------------------------
# Startup Display & Shell Prompt
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
if command -v mise >/dev/null 2>&1; then
  export MISE_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mise"
  eval "$(mise activate zsh)"
fi

# # nvm fallback 예시
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
#
# # sdkman 사용 환경
# if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
#   source "$HOME/.sdkman/bin/sdkman-init.sh"
# fi

# ------------------------------------------------------------------------------
# Shell Options & Tool Environment
# ------------------------------------------------------------------------------
# export YSU_MESSAGE_POSITION="before"  # 명령어 실행 전 메시지 표시
# export YSU_MODE=BESTMATCH             # 모든 alias 제안 (기본은 최근 사용만)
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

  zplug "zsh-users/zsh-autosuggestions",          defer:1
  zplug "zsh-users/zsh-history-substring-search", defer:1
  zplug "lib/key-bindings", from:oh-my-zsh
  zplug "lib/directories",  from:oh-my-zsh
  zplug "plugins/git", from:oh-my-zsh
  # zplug "plugins/docker", from:oh-my-zsh
  zplug "MichaelAquilina/zsh-you-should-use"
  # zplug "mroth/evalcache"
  zplug "babarot/enhancd", use:init.sh
  zplug "romkatv/zsh-defer"
  zplug "romkatv/powerlevel10k", as:theme, depth:1

  zplug "Aloxaf/fzf-tab"

  zplug "zsh-users/zsh-syntax-highlighting", defer:2
  # 필요시 주석 해제
  # if ! zplug check; then
  #   printf "Install? [y/N]: "
  #   if read -q; then echo; zplug install; fi
  # fi

  zplug load
fi
setopt extendedglob

# ------------------------------------------------------------------------------
# fzf-tab
# ------------------------------------------------------------------------------
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' continuous-trigger '/'

zstyle ':fzf-tab:complete:*' fzf-preview '
  if [[ -d "$realpath" ]]; then
    if command -v lsd >/dev/null 2>&1; then
      lsd --color=always "$realpath"
    else
      ls -la "$realpath"
    fi
  elif [[ -f "$realpath" ]]; then
    if file --mime "$realpath" | grep -q "text/"; then
      if command -v bat >/dev/null 2>&1; then
        bat --color=always --style=numbers --line-range=:200 "$realpath"
      else
        sed -n "1,200p" "$realpath"
      fi
    else
      file "$realpath"
    fi
  fi
'

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
alias python="$HOMEBREW_PREFIX/bin/python3"
alias ll='ls -alhF'
alias vim='nvim'
alias vi='nvim'
alias cdh="cd $HOME"
alias cdp="cd $PROJECT_ROOT"
alias cdw="cd $PROJECT_ROOT/worktrees/"
alias cl="clear"
alias b-maint='brew update && brew upgrade && brew cleanup --prune=all && brew doctor'
alias ncc='npm cache clean --force'
alias kd='killall Dock'
alias bsl='brew services list'
alias vds="cd $PROJECT_ROOT/dev-init-setting && vim ."
alias vt='vim ~/.tmux.conf'
alias mc='mole clean --dry-run'
alias vzh="vim $HOME/.zshrc"
alias szh="source $HOME/.zshrc"
alias cs="colima start"
alias ct="colima stop"
alias gcgl="git config --global --list"

command -v lsd >/dev/null 2>&1 && alias ls='lsd'
command -v bat >/dev/null 2>&1 && alias cat='bat'

# =======================================================
# Git Wrapper 적용 (IntelliJ와 동일한 로직 공유)
# =======================================================
if [[ -f "$HOME/git-wrapper.sh" ]]; then
  function git() {
    "$HOME/git-wrapper.sh" "$@"
  }

  autoload -Uz _git
  compdef _git git
fi
setopt complete_aliases

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
function fzf-view() {
  fzf --preview '[[ $(file --mime {}) =~ binary ]] &&
                echo {} is a binary file ||
                (bat --color=always {} ||
                cat {}) 2> /dev/null | head -500'
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

function wta() {
  if [ -z "$1" ]; then
    echo "Usage: wta <branch> [base]"
    return 1
  fi

  local branch="$1"
  local base="${2:-origin/feat/$branch}"
  local repo_name="${PWD##*/}"
  local safe_branch="${branch//\//-}"
  local base_dir="$PROJECT_ROOT/worktrees"
  local dir="${base_dir}/${repo_name}-${safe_branch}"

  mkdir -p "$base_dir"

  git fetch origin || return 1

  if git worktree list --porcelain | grep -q "^branch refs/heads/$branch$"; then
    echo "Branch already checked out in another worktree: $branch"
    git worktree list
    return 1
  fi

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Using existing local branch: $branch"
    git worktree add "$dir" "$branch" || return 1
  else
    echo "Creating local branch: $branch from $base"
    git worktree add -b "$branch" "$dir" "$base" || return 1
  fi

  echo "Created: $dir"
}

function wtr() {
  if [ -z "$1" ]; then
    echo "Usage: wtr <branch>"
    return 1
  fi

  local branch="$1"
  local target=""
  local current_wt=""

  while IFS= read -r line; do
    case "$line" in
      worktree\ *)
        current_wt="${line#worktree }"
        ;;
      branch\ refs/heads/*)
        local current_branch="${line#branch refs/heads/}"
        if [ "$current_branch" = "$branch" ]; then
          target="$current_wt"
          break
        fi
        ;;
    esac
  done < <(git worktree list --porcelain)

  if [ -z "$target" ]; then
    echo "No worktree found for branch: $branch"
    return 1
  fi

  git worktree remove "$target" || return 1
  echo "Removed: $target"
}

function wtrf() {
  if [ -z "$1" ]; then
    echo "Usage: wtrf <branch>"
    return 1
  fi

  local branch="$1"
  local target=""
  local current_wt=""

  while IFS= read -r line; do
    case "$line" in
      worktree\ *)
        current_wt="${line#worktree }"
        ;;
      branch\ refs/heads/*)
        local current_branch="${line#branch refs/heads/}"
        if [ "$current_branch" = "$branch" ]; then
          target="$current_wt"
          break
        fi
        ;;
    esac
  done < <(git worktree list --porcelain)

  if [ -z "$target" ]; then
    echo "No worktree found for branch: $branch"
    return 1
  fi

  git worktree remove --force "$target" || return 1
  echo "Force removed: $target"
}

function wtl() {
  git worktree list
}

function gco-all() {
  if [ -z "$1" ]; then
    echo "Usage: gco-all <branch>"
    return 1
  fi

  local branch="$1"

  for dir in */; do
    if [ -d "$dir/.git" ]; then   # ← 핵심
      echo "==> $dir"

      (
        cd "$dir" || exit

        git fetch origin

        if git show-ref --verify --quiet "refs/heads/$branch"; then
          git switch "$branch"
        elif git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
          git switch -c "$branch" "origin/$branch"
        else
          echo "  ❌ branch not found: $branch"
        fi
      )
    fi
  done
}

# ------------------------------------------------------------------------------
# Tool Initializations
# ------------------------------------------------------------------------------

# 1. fzf 설정
# fzf-history-widget을 직접 바인딩하기 위해 즉시 로드한다.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# 2. atuin 설정
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
fi

# 3. history search key bindings
# Atuin >= 18 uses atuin-search. fzf-history-widget is defined by ~/.fzf.zsh.
if (( ${+widgets[atuin-search]} )); then
  bindkey -M emacs '^R' atuin-search
  bindkey -M viins '^R' atuin-search
fi

if (( ${+widgets[fzf-history-widget]} )); then
  bindkey -M emacs '^X^R' fzf-history-widget
  bindkey -M viins '^X^R' fzf-history-widget
fi

# 4. bun completions
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

# Colima 미사용시 주석 해제.
## MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
#export PATH="/Users/oyunbog/.rd/bin:$PATH"
## MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section
# zprof #zsh쉘 로딩 디버깅 모니터링 종료
