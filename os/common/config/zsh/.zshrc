# ------------------------------------------------------------------------------
# PATH and Environment Variables
# ------------------------------------------------------------------------------
# Locale
export LANG=en_US.UTF-8

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# User Binaries
export PATH="$HOME/.local/bin:$PATH" # pipx etc
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Development Tools
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOMEBREW_PREFIX/Cellar/dotnet@8/8.0.13/libexec"

export PATH="$HOMEBREW_PREFIX/opt/luajit/bin:$PATH"

# Prevent system binary override
export PATH="$PATH:/usr/local/bin"

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
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/zsh_reload", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh
zplug "plugins/macos", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/fzf", from:oh-my-zsh
zplug "plugins/aws", from:oh-my-zsh
zplug "plugins/copypath", from:oh-my-zsh
zplug "plugins/copyfile", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/yarn", from:oh-my-zsh

zplug "changyuheng/zsh-interactive-cd"
zplug "wfxr/forgit", defer:1
zplug "MichaelAquilina/zsh-you-should-use"

zplug "romkatv/powerlevel10k", as:theme, depth:1

zplug "zsh-users/zsh-syntax-highlighting"

# Load plugins
zplug load

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
alias vds='nvim ~/IdeaProjects/dev-init-setting'

# ------------------------------------------------------------------------------
# Tooling Configurations & Initializations
# ------------------------------------------------------------------------------
# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
function fzf-view() {
    fzf --preview '''[[ $(file --mime {}) =~ binary ]] &&
                  echo {} is a binary file ||
                  (bat --color=always {} ||
                  cat {}) 2> /dev/null | head -500'''
}

# Brew Service Start (fzf)
function bstart() {
  local service_to_start=$(brew services list | awk 'NR>1 {print $1}' | fzf)
  if [[ -n "$service_to_start" ]]; then
    brew services start "$service_to_start"
  fi
}

# Brew Service Stop (fzf)
function bstop() {
  local service_to_stop=$(brew services list | grep started | awk '{print $1}' | fzf)
  if [[ -n "$service_to_stop" ]]; then
    brew services stop "$service_to_stop"
  fi
}

# =======================================================
# Git 보호 로직: feat 브랜치에서 develop 직접 pull/merge 차단
# =======================================================
function git() {
  # 1. 사용자가 입력한 명령어 종류 확인 (pull 또는 merge)
  local command="$1"

  if [[ "$command" == "pull" ]] || [[ "$command" == "merge" ]]; then
    
    # 2. 현재 브랜치 이름 확인 (에러 방지를 위해 stderr는 숨김)
    local current_branch=$(command git symbolic-ref --short HEAD 2>/dev/null)

    # 3. 입력된 모든 인자 중에서 'develop'이 포함되어 있는지 검사
    # 예: git pull origin develop  -> 'develop' 감지
    # 예: git merge develop        -> 'develop' 감지
    local args="$@"
    
    # [조건] 현재 브랜치가 'feat'로 시작하고, 명령어 인자에 'develop'이 포함된 경우
    if [[ "$current_branch" == feat* ]] && [[ "$args" == *"develop"* ]]; then
        echo "🛑 [BLOCKED] 'feat' 브랜치에서 'develop'을 직접 가져올 수 없습니다."
        echo "   --------------------------------------------------"
        echo "   🚫 명령어: git $args"
        echo "   📍 현재 위치: $current_branch"
        echo "   ✅ 올바른 전략: develop -> stage -> feat 순서를 따라주세요."
        echo "   --------------------------------------------------"
        
        # 실제 git 명령어를 실행하지 않고 함수 종료 (Return 1)
        return 1 
    fi
  fi

  # 위 조건에 걸리지 않았다면 원래 git 명령어 정상 실행
  command git "$@"
}

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# mise (replaces rbenv, nvm, etc)
eval "$(mise activate zsh)"

# Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Run fastfetch only in full terminals (skip in IDEs)
if [[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "IntelliJ" && -z "$JEDI_TERM" && -z "$IDEA_INITIAL_DIRECTORY" ]]; then
  fastfetch --pipe false
fi
