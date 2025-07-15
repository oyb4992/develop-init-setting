# Path and environment variables
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH=$HOMEBREW_PREFIX/bin:$PATH
export PATH=$HOMEBREW_PREFIX/sbin:$PATH
export PATH="$PATH:/Users/oyunbog/.dotnet/tools"
export PATH=$HOMEBREW_PREFIX/opt/luajit/bin:$PATH
export DOTNET_ROOT="$HOMEBREW_PREFIX/Cellar/dotnet@8/8.0.13/libexec"
export LANG=en_US.UTF-8

# Run fastfetch
#fastfetch
flashfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Initialize zplug
export ZPLUG_HOME=$HOMEBREW_PREFIX/opt/zplug
if [[ -f $ZPLUG_HOME/init.zsh ]]; then
  source $ZPLUG_HOME/init.zsh
fi

# zplug plugins
zplug "romkatv/powerlevel10k", as:theme, depth:1
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/macos", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/mise", from:oh-my-zsh
zplug "plugins/fzf", from:oh-my-zsh
zplug "plugins/aws", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", defer:2

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Load plugins
zplug load

# Aliases
alias python="$HOMEBREW_PREFIX/bin/python3"
alias ls='lsd'
alias ll='ls -alhF'
alias vim='nvim'
alias vi='nvim'
alias cat="bat"

# ============= VIM MODE CONFIGURATION =============
# vim 모드 활성화
bindkey -v

# 모드 전환 시간 단축 (기본값 0.4초 → 0.1초)
export KEYTIMEOUT=1

# 현재 모드 표시를 위한 커서 변경
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'  # 블록 커서 (normal 모드)
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} == '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'  # 빔 커서 (insert 모드)
  fi
}
zle -N zle-keymap-select

# 라인 에디터 시작 시 insert 모드
function zle-line-init() {
    echo -ne "\e[5 q"
}
zle -N zle-line-init

# normal 모드에서 v로 에디터 열기 
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
# ================================================

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
function fzf-view() {
    fzf --preview '[[ $(file --mime {}) =~ binary ]] &&
                  echo {} is a binary file ||
                  (bat --color=always {} ||
                  cat {}) 2> /dev/null | head -500'
}

eval "$(mise activate zsh)"

export PATH="$PATH:/usr/local/bin"  # 시스템 바이너리 오버라이드 방지

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2025-06-04 14:24:46
export PATH="$PATH:/Users/oyunbog/.local/bin"
