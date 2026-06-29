# 기존에 쓰시던 오리지널 별칭 데이터 전체 유지
if [[ -n "${HOMEBREW_PREFIX:-}" && -x "$HOMEBREW_PREFIX/bin/python3" ]]; then
  alias python="$HOMEBREW_PREFIX/bin/python3"
elif command -v python3 >/dev/null 2>&1; then
  alias python='python3'
fi
alias vim='nvim'
alias vi='nvim'
alias cdh="cd $HOME"
alias cdp="cd $PROJECT_ROOT"
alias cdd="cd $PROJECT_ROOT/dev-init-setting/"
alias cdw="cd $PROJECT_ROOT/worktrees/"
alias cl="clear"
if command -v brew >/dev/null 2>&1; then
  alias b-maint='brew update && brew upgrade && brew cleanup --prune=all && brew doctor'
  alias bsl='brew services list'
fi
alias ncc='npm cache clean --force'
if [[ "$(uname -s)" == "Darwin" ]]; then
  alias kd='killall Dock'
fi
alias vds="cd $PROJECT_ROOT/dev-init-setting && vim ."
alias vt='vim ~/.tmux.conf'
if command -v mole >/dev/null 2>&1; then
  alias mc='mole clean --dry-run'
fi
alias vzh="vim $HOME/.zshrc"
alias szh="source $HOME/.zshrc"
if command -v colima >/dev/null 2>&1; then
  alias cs="colima start"
  alias ct="colima stop"
fi
alias gcgl="git config --global --list"

# Git shortcuts: oh-my-zsh git plugin에서 자주 쓰는 정적 별칭만 가볍게 유지
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gapa="git add --patch"
alias gau="git add --update"
alias gav="git add --verbose"
alias gap="git apply"
alias gapt="git apply --3way"
alias gb="git branch"
alias gba="git branch --all"
alias gbd="git branch --delete"
alias gbD="git branch --delete --force"
alias gbm="git branch --move"
alias gbnm="git branch --no-merged"
alias gbr="git branch --remote"
alias gbl="git blame -w"
alias gco="git checkout"
alias gcor="git checkout --recurse-submodules"
alias gcb="git checkout -b"
alias gcB="git checkout -B"
alias gcp="git cherry-pick"
alias gcpa="git cherry-pick --abort"
alias gcpc="git cherry-pick --continue"
alias gclean="git clean --interactive -d"
alias gcl="git clone --recurse-submodules"
alias gclf="git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules"
alias gc="git commit --verbose"
alias gc!="git commit --verbose --amend"
alias gca="git commit --verbose --all"
alias gca!="git commit --verbose --all --amend"
alias gcan!="git commit --verbose --all --no-edit --amend"
alias gcann!="git commit --verbose --all --date=now --no-edit --amend"
alias gcam="git commit --all --message"
alias gcas="git commit --all --signoff"
alias gcasm="git commit --all --signoff --message"
alias gcmsg="git commit --message"
alias gcsm="git commit --signoff --message"
alias gcn="git commit --verbose --no-edit"
alias gcn!="git commit --verbose --no-edit --amend"
alias gcs="git commit --gpg-sign"
alias gcss="git commit --gpg-sign --signoff"
alias gcssm="git commit --gpg-sign --signoff --message"
alias gcf="git config --list"
alias gcfu="git commit --fixup"
alias gd="git diff"
alias gdca="git diff --cached"
alias gdcw="git diff --cached --word-diff"
alias gds="git diff --staged"
alias gdw="git diff --word-diff"
alias gdt="git diff-tree --no-commit-id --name-only -r"
alias gdup="git diff @{upstream}"
alias gf="git fetch"
alias gfa="git fetch --all --tags --prune"
alias gfo="git fetch origin"
alias ghh="git help"
alias gl="git pull"
alias gpr="git pull --rebase"
alias gprv="git pull --rebase -v"
alias gpra="git pull --rebase --autostash"
alias gprav="git pull --rebase --autostash -v"
alias gp="git push"
alias gpd="git push --dry-run"
alias gpf!="git push --force"
alias gpf="git push --force-with-lease --force-if-includes"
alias gpv="git push --verbose"
alias gpoat="git push origin --all && git push origin --tags"
alias gpod="git push origin --delete"
alias gpu="git push upstream"
alias glg="git log --stat"
alias glgp="git log --stat --patch"
alias glgg="git log --graph"
alias glgga="git log --graph --decorate --all"
alias glgm="git log --graph --max-count=10"
alias glo="git log --oneline --decorate"
alias glog="git log --oneline --decorate --graph"
alias gloga="git log --oneline --decorate --graph --all"
alias gm="git merge"
alias gma="git merge --abort"
alias gmc="git merge --continue"
alias gmff="git merge --ff-only"
alias gms="git merge --squash"
alias gmtl="git mergetool --no-prompt"
alias gmtlvim="git mergetool --no-prompt --tool=vimdiff"
alias grb="git rebase"
alias grba="git rebase --abort"
alias grbc="git rebase --continue"
alias grbi="git rebase --interactive"
alias grbo="git rebase --onto"
alias grbs="git rebase --skip"
alias grf="git reflog"
alias gr="git remote"
alias gra="git remote add"
alias grrm="git remote remove"
alias grmv="git remote rename"
alias grset="git remote set-url"
alias grup="git remote update"
alias grv="git remote --verbose"
alias grh="git reset"
alias gru="git reset --"
alias grhh="git reset --hard"
alias grhk="git reset --keep"
alias grhs="git reset --soft"
alias grs="git restore"
alias grss="git restore --source"
alias grst="git restore --staged"
alias grev="git revert"
alias greva="git revert --abort"
alias grevc="git revert --continue"
alias grm="git rm"
alias grmc="git rm --cached"
alias gcount="git shortlog --summary --numbered"
alias gsh="git show"
alias gsps="git show --pretty=short --show-signature"
alias gsta="git stash push"
alias gstall="git stash --all"
alias gstaa="git stash apply"
alias gstc="git stash clear"
alias gstd="git stash drop"
alias gstl="git stash list"
alias gstp="git stash pop"
alias gsts="git stash show --patch"
alias gstu="git stash push --include-untracked"
alias gst="git status"
alias gss="git status --short"
alias gsb="git status --short --branch"
alias gsi="git submodule init"
alias gsu="git submodule update"
alias gsw="git switch"
alias gswc="git switch --create"
alias gta="git tag --annotate"
alias gts="git tag --sign"
alias gtv="git tag | sort -V"
alias gignore="git update-index --assume-unchanged"
alias gunignore="git update-index --no-assume-unchanged"
alias gwt="git worktree"
alias gwta="git worktree add"
alias gwtls="git worktree list"
alias gwtmv="git worktree move"
alias gwtrm="git worktree remove"

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

if [[ -n "${BAT_COMMAND:-}" ]]; then
  alias cat="$BAT_COMMAND"
fi
