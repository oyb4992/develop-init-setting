path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_append() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX=$(brew --prefix)
  export HOMEBREW_PREFIX
  path_prepend "$HOMEBREW_PREFIX/sbin"
  path_prepend "$HOMEBREW_PREFIX/bin"
fi
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.antigravity/antigravity/bin"

if [[ "$(uname -s)" == "Darwin" ]]; then
  export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
else
  export PNPM_HOME="${PNPM_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/pnpm}"
fi
path_prepend "$PNPM_HOME"
path_append "$HOME/.dotnet/tools"
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  if [[ -d "$HOMEBREW_PREFIX/opt/dotnet@8/libexec" ]]; then
    export DOTNET_ROOT="$HOMEBREW_PREFIX/opt/dotnet@8/libexec"
  fi
  path_prepend "$HOMEBREW_PREFIX/opt/luajit/bin"
fi
path_append "$HOME/.lmstudio/bin"
export PROJECT_ROOT="$HOME/IdeaProjects/"
export PATH
unset -f path_prepend path_append

export LANG=en_US.UTF-8
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
mkdir -p "$(dirname "$HISTFILE")"
shopt -s histappend cmdhist
if (( BASH_VERSINFO[0] >= 4 )); then
  shopt -s autocd
fi

export ENHANCD_FILTER="fzf --height 40% --reverse --border"
export ENHANCD_DOT_SHOW_FULLPATH=1
export ENHANCD_ENABLE_HOME=0
export ATUIN_NOBIND="true"
export DOCKER_MCP_USE_CE=true
export DOCKER_MCP_IN_CONTAINER=1

if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
fi

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fdfind --type d --strip-cwd-prefix --hidden --follow --exclude .git'
fi
