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
alias buuc='brew update && brew upgrade && brew cleanup'

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

# bun completions
[ -s "/Users/oyunbog/.bun/_bun" ] && source "/Users/oyunbog/.bun/_bun"

# mise
eval "$(mise activate zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh