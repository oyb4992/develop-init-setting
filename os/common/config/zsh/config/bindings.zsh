# Atuin 및 FZF 기본 히스토리 바인딩 구조
if (( ${+widgets[atuin-search]} )); then
  bindkey -M emacs '^R' atuin-search
  bindkey -M viins '^R' atuin-search
fi

if (( ${+widgets[fzf-history-widget]} )); then
  bindkey -M emacs '^X^R' fzf-history-widget
  bindkey -M viins '^X^R' fzf-history-widget
fi

# ------------------------------------------------------------------------------
# [영상 반영] FZF + FD + BAT Advanced Key Bindings
# ------------------------------------------------------------------------------
# Ctrl + T : 현재 폴더 하위의 모든 소스코드를 프리뷰 창과 함께 실시간 매핑 탐색
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range=:500 {} 2>/dev/null || eza --tree --level=1 --icons=auto --color=always {} 2>/dev/null || ls -la {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=auto --color=always {} 2>/dev/null || ls -la {}'"
fi

bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget # Alt + C (또는 Option + C)