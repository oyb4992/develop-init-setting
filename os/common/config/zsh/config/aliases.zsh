# 기존에 쓰시던 오리지널 별칭 데이터 전체 유지
alias python="$HOMEBREW_PREFIX/bin/python3"
alias vim='nvim'
alias vi='nvim'
alias cdh="cd $HOME"
alias cdp="cd $PROJECT_ROOT"
alias cdd="cd $PROJECT_ROOT/dev-init-setting/"
alias cdw="cd $PROJECT_ROOT/worktrees/"
alias cl="clear"
alias b-maint='brew update && brew upgrade && brew cleanup --prune=all && brew doctor'
alias ncc='npm cache clean --force'
alias kd='killall Dock'
alias bsl='brew services list'
alias vds="cd $PROJECT_ROOT/dev-init-setting && vim ."
alias vt='vim ~/.tmux.conf'
alias mc='mole clean --dry-run'
alias vzh="vim $HOME/.zshrc"
alias szh="source $HOME/.zshrc"
alias cs="colima start"
alias ct="colima stop"
alias gcgl="git config --global --list"
alias soc="ssh -i ~/Documents/KEY/2026/02/ssh-key-2026-02-17.key ubuntu@168.107.22.152"
alias n8ns="ssh -i ~/Documents/KEY/2026/02/ssh-key-2026-02-17.key -N -L 5678:127.0.0.1:5678 ubuntu@168.107.22.152"

# [영상 반영] zoxide 초기화 및 점프 활성화
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cdi='zi' # 인트랙티브 모드로 전체 히스토리 탐색 이동
fi

# Modern CLI 도구 맵핑
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -al --icons=auto --group-directories-first --git'
  alias la='eza -a --icons=auto --group-directories-first'
  alias lt='eza -al --tree --level=2 --icons=auto --group-directories-first --git'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

if command -v fd >/dev/null 2>&1; then
  alias find='fd'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi