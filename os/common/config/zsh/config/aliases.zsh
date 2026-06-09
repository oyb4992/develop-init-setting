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

# Git shortcuts: oh-my-zsh git plugin에서 자주 쓰는 별칭만 가볍게 유지
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gb="git branch"
alias gba="git branch --all"
alias gbd="git branch --delete"
alias gbl="git blame -b -w"
alias gc="git commit --verbose"
alias gc!="git commit --verbose --amend"
alias gca="git commit --verbose --all"
alias gcam="git commit --all --message"
alias gcmsg="git commit --message"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcl="git clone --recurse-submodules"
alias gclean="git clean --interactive -d"
alias gd="git diff"
alias gds="git diff --staged"
alias gf="git fetch"
alias gfa="git fetch --all --prune"
alias gl="git pull"
alias gp="git push"
alias gpf!="git push --force"
alias gpf="git push --force-with-lease --force-if-includes"
alias gst="git status"
alias gss="git status --short"
alias gsb="git status --short --branch"
alias glg="git log --stat"
alias glgg="git log --graph"
alias glgga="git log --graph --decorate --all"
alias glo="git log --oneline --decorate"
alias glog="git log --oneline --decorate --graph"
alias gloga="git log --oneline --decorate --graph --all"

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
