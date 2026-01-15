# ------------------------------------------------------------------------------
# PATH and Environment Variables
# ------------------------------------------------------------------------------
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH=$HOMEBREW_PREFIX/bin:$PATH
export PATH=$HOMEBREW_PREFIX/sbin:$PATH
export PATH="$PATH:/Users/oyunbog/.dotnet/tools"
export PATH=$HOMEBREW_PREFIX/opt/luajit/bin:$PATH
export PATH="$PATH:/Users/oyunbog/.local/bin" # From pipx

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export DOTNET_ROOT="$HOMEBREW_PREFIX/Cellar/dotnet@8/8.0.13/libexec"
export LANG=en_US.UTF-8

export PATH="$PATH:/usr/local/bin" # System binary override prevention
# ------------------------------------------------------------------------------
# Shell Startup
# ------------------------------------------------------------------------------
# Run fastfetch
#fastfetch
flashfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# Plugin Management (zplug)
# ------------------------------------------------------------------------------
# Initialize zplug
export ZPLUG_HOME=$HOMEBREW_PREFIX/opt/zplug
if [[ -f $ZPLUG_HOME/init.zsh ]]; then
  source $ZPLUG_HOME/init.zsh
fi

# zplug plugins
zplug "zsh-users/zsh-completions",              defer:0
zplug "zsh-users/zsh-autosuggestions",          defer:1, on:"zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting",      defer:1, on:"zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search", defer:2, on:"zsh-users/zsh-syntax-highlighting"

zplug "lib/completion",   from:oh-my-zsh
zplug "lib/key-bindings", from:oh-my-zsh
zplug "lib/directories",  from:oh-my-zsh

zplug "plugins/git", from:oh-my-zsh
zplug "plugins/zsh_reload", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh
zplug "plugins/macos", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/mise", from:oh-my-zsh
zplug "plugins/fzf", from:oh-my-zsh
zplug "plugins/aws", from:oh-my-zsh

zplug "romkatv/powerlevel10k", as:theme, depth:1

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

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
alias brew-maint='brew update && brew upgrade && brew cleanup && brew doctor'
alias d-img-prune='docker image prune -f'
alias npm-cache-clean='npm cache clean --force'
alias dock-restart='killall Dock'
alias brew-services='brew services list'
# alias dc-up='docker-compose up -d'
# alias dc-stop='docker-compose stop'
alias lc-update='docker stop lobe-chat && docker rm lobe-chat && docker pull lobehub/lobe-chat && docker run -d -p 3210:3210 -e OPENAI_API_KEY=sk-xxxx -e ACCESS_CODE=lobe66 --name lobe-chat lobehub/lobe-chat'
alias lc-start='docker start lobe-chat && docker ps'
alias lc-stop='docker stop lobe-chat && docker ps'

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

 # Brew 서비스 시작 (fzf로 선택)
 function bstart() {
   # 1. `brew services list`: 서비스 목록을 가져옵니다.
   # 2. `awk 'NR>1 {print $1}'`: 헤더를 제외하고 서비스 이름만 추출합니다.
   # 3. `fzf`: fzf를 통해 목록에서 하나를 선택하게 합니다.
   # 4. 선택된 서비스 이름을 `brew services start`에 전달합니다.
   local service_to_start=$(brew services list | awk 'NR>1 {print $1}' | fzf)
 
   # fzf에서 ESC를 누르거나 선택하지 않은 경우를 대비
   if [[ -n "$service_to_start" ]]; then
     brew services start "$service_to_start"
   fi
 }
 
 # Brew 서비스 종료 (fzf로 선택)
 function bstop() {
   # `grep started`: 실행 중인 서비스만 필터링합니다.
   local service_to_stop=$(brew services list | grep started | awk '{print $1}' | fzf)
 
   if [[ -n "$service_to_stop" ]]; then
     brew services stop "$service_to_stop"
   fi
 }

# bun completions
[ -s "/Users/oyunbog/.bun/_bun" ] && source "/Users/oyunbog/.bun/_bun"

# mise
eval "$(mise activate zsh)"

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
