# Ubuntu VPS zsh profile
# Keep this profile small: fast SSH startup, tmux-friendly, and safe for servers.

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history
setopt auto_cd

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
compinit -d "$HOME/.zcompdump"

# Debian/Ubuntu package names differ from command names.
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    alias fd='fdfind'
fi

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    alias bat='batcat'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status --short --branch'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gdc='git diff --cached'

alias dfh='df -h'
alias duh='du -h --max-depth=1'
alias ports='ss -tulpen'
alias jxe='journalctl -xeu'
alias reload-zsh='source ~/.zshrc'

# OpenClaw operation helpers. Set OPENCLAW_DIR if the repo lives elsewhere.
export OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/openclaw}"
alias oc='cd "$OPENCLAW_DIR"'
alias ocps='cd "$OPENCLAW_DIR" && docker compose ps'
alias oclogs='cd "$OPENCLAW_DIR" && docker compose logs -f --tail=200'
alias ocrestart='cd "$OPENCLAW_DIR" && docker compose restart'
alias ocdeploy='cd "$OPENCLAW_DIR" && git pull --ff-only && docker compose pull && docker compose up -d'
alias octmux='tmux new-session -A -s openclaw -c "$OPENCLAW_DIR"'

if command -v fzf >/dev/null 2>&1; then
    if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi
    if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
        source /usr/share/doc/fzf/examples/completion.zsh
    fi
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:git:*' formats ' (%b)'
    PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f %# '
fi
