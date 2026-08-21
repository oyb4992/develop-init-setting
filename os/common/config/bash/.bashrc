BLESH_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh"
if [[ $- == *i* && -r "$BLESH_PATH" ]]; then
  source -- "$BLESH_PATH" --attach=none
fi

BASH_CONFIG_DIR="$HOME/.config/bash"

[[ -f "$BASH_CONFIG_DIR/env.bash" ]] && source "$BASH_CONFIG_DIR/env.bash"
[[ $- == *i* ]] || return 0
[[ -f "$BASH_CONFIG_DIR/plugins.bash" ]] && source "$BASH_CONFIG_DIR/plugins.bash"
[[ -f "$BASH_CONFIG_DIR/aliases.bash" ]] && source "$BASH_CONFIG_DIR/aliases.bash"
[[ -f "$BASH_CONFIG_DIR/bindings.bash" ]] && source "$BASH_CONFIG_DIR/bindings.bash"
[[ -f "$BASH_CONFIG_DIR/functions.bash" ]] && source "$BASH_CONFIG_DIR/functions.bash"

if is_zed_terminal_session; then
  export EDITOR="zed --wait"
  export VISUAL="zed --wait"
fi

if command -v mise >/dev/null 2>&1; then
  export MISE_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mise"
  eval "$(mise activate bash)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash --disable-up-arrow --disable-ctrl-r)"
fi

[[ -f "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
  alias cdi='zi'
fi

if command -v herdr >/dev/null 2>&1 && \
   [[ -z "${HERDR_ENV:-}" ]] && \
   [[ -z "${SKIP_HERDR_AUTO_START:-}" ]] && \
   [[ -z "${TMUX:-}" ]] && \
   ! is_zed_terminal_session && \
   [[ -z "${TERMINAL_EMULATOR:-}" ]] && \
   [[ "${TERM_PROGRAM:-}" != "vscode" ]] && \
   [[ "${TERM_PROGRAM:-}" != "IntelliJ" ]] && \
   [[ -z "${INTELLIJ_ENVIRONMENT_READER:-}" ]] && \
   [[ "${TERM:-}" != screen* ]] && \
   [[ "${TERM:-}" != tmux* ]]; then
  herdr
fi

[[ -z "${BLE_VERSION:-}" ]] || ble-attach
