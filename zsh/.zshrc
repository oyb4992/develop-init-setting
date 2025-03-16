# Run neofetch
fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path and environment variables
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH=$HOMEBREW_PREFIX/bin:$PATH
export ASDF_DATA_DIR="/Users/oyunbog/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
export PATH="$PATH:/Users/oyunbog/.dotnet/tools"
export DOTNET_ROOT="$HOMEBREW_PREFIX/Cellar/dotnet@8/8.0.13/libexec"
export LANG=en_US.UTF-8

# Rancher Desktop path
### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/mz01-ohyunbok/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh My Zsh plugins
plugins=(
  git
  macos
  autojump
  asdf
  fzf
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load plugin sources
source $HOMEBREW_PREFIX/Cellar/autojump/22.5.3_3/share/autojump/autojump.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Aliases
alias python="/usr/bin/python3"
alias ls='lsd'
alias ll='ls -alhF'

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
function fzf-view() {
    fzf --preview '[[ $(file --mime {}) =~ binary ]] &&
                  echo {} is a binary file ||
                  (highlight -O ansi -l {} ||
                  coderay {} ||
                  rougify {} ||
                  cat {}) 2> /dev/null | head -500'
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh