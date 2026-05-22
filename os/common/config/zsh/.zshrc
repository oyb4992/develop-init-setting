# 분할된 설정 파일들 순차적 소싱 (의존 관계 순서 준수)
ZSH_CONFIG_DIR="$HOME/.config/zsh"

[[ -f "$ZSH_CONFIG_DIR/env.zsh" ]]       && source "$ZSH_CONFIG_DIR/env.zsh"
[[ -f "$ZSH_CONFIG_DIR/plugins.zsh" ]]   && source "$ZSH_CONFIG_DIR/plugins.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]]   && source "$ZSH_CONFIG_DIR/aliases.zsh"
[[ -f "$ZSH_CONFIG_DIR/bindings.zsh" ]]  && source "$ZSH_CONFIG_DIR/bindings.zsh"
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"

# ------------------------------------------------------------------------------
# Runtime & External Tool Initializations
# ------------------------------------------------------------------------------
# 1. Editor 설정
if is_zed_terminal_session; then
  export EDITOR="zed --wait"
  export VISUAL="zed --wait"
fi

# 2. Runtime Manager (Mise)
if command -v mise >/dev/null 2>&1; then
  export MISE_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mise"
  eval "$(mise activate zsh)"
fi

# 3. FZF 기본 위젯 로드
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# 4. Atuin 초기화
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
fi

# 5. Bun Completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# 6. Local Overrides
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# 7. Theme (Starship 프롬프트) - 외부 프레임워크 의존성 없이 순수 구동되어 완벽 작동
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# 8. Tmux Auto Start - 순수 터미널 에뮬레이터 세션만 감지하여 무한 루프 완벽 방어
if command -v tmux &> /dev/null && \
   [ -z "$TMUX" ] && \
   [ -z "${TERMINAL_EMULATOR}" ] && \
   [ "${TERM_PROGRAM}" != "vscode" ] && \
   [ "${TERM_PROGRAM}" != "IntelliJ" ] && \
   [ -z "${INTELLIJ_ENVIRONMENT_READER}" ] && \
   [[ "$TERM" != "screen"* ]] && \
   [[ "$TERM" != "tmux"* ]]; then

  # main 세션이 이미 존재하면 연결(Attach), 없으면 신규 생성
  tmux attach-session -t main 2>/dev/null || tmux new-session -s main
fi