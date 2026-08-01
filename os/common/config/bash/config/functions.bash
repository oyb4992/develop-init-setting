is_zed_terminal_session() {
  [[ "${IN_ZED_TERMINAL:-}" == "1" || "${ZED_TERM:-}" == "true" ]] && return 0
  case "${TERM_PROGRAM:-}" in
    [Zz][Ee][Dd]) return 0 ;;
  esac
  return 1
}

is_plain_terminal_session() {
  [[ "${TERM_PROGRAM:-}" != "vscode" &&
     "${TERM_PROGRAM:-}" != "IntelliJ" &&
     "${TERMINAL_EMULATOR:-}" != "JetBrains-JediTerm" &&
     -z "${JEDI_TERM:-}" &&
     -z "${IDEA_INITIAL_DIRECTORY:-}" ]] || return 1
  ! is_zed_terminal_session
}

if [[ -f "$HOME/git-wrapper.sh" ]]; then
  git() { "$HOME/git-wrapper.sh" "$@"; }
fi

fzf-view() {
  fzf --preview 'file --mime {} | grep -q binary &&
                 echo {} is a binary file ||
                 (bat --color=always {} || batcat --color=always {} || cat {}) 2>/dev/null | head -500'
}

bstart() {
  local service_to_start
  service_to_start=$(brew services list | awk 'NR>1 {print $1}' | fzf)
  [[ -n "$service_to_start" ]] && brew services start "$service_to_start"
}

bstop() {
  local service_to_stop
  service_to_stop=$(brew services list | grep started | awk '{print $1}' | fzf)
  [[ -n "$service_to_stop" ]] && brew services stop "$service_to_stop"
}

wta() {
  if [[ -z "${1:-}" ]]; then echo "Usage: wta <branch> [base]"; return 1; fi
  local branch="$1"
  local base="${2:-origin/feat/$branch}"
  local repo_name="${PWD##*/}"
  local safe_branch="${branch//\//-}"
  local base_dir="$PROJECT_ROOT/worktrees"
  local dir="${base_dir}/${repo_name}-${safe_branch}"
  mkdir -p "$base_dir"
  git fetch origin || return 1
  if git worktree list --porcelain | grep -q "^branch refs/heads/$branch$"; then
    echo "Branch already checked out in another worktree: $branch"
    git worktree list
    return 1
  fi
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Using existing local branch: $branch"
    git worktree add "$dir" "$branch" || return 1
  else
    echo "Creating local branch: $branch from $base"
    git worktree add -b "$branch" "$dir" "$base" || return 1
  fi
  echo "Created: $dir"
}

wtr() {
  if [[ -z "${1:-}" ]]; then echo "Usage: wtr <branch>"; return 1; fi
  local branch="$1"
  local target=""
  local current_wt=""
  while IFS= read -r line; do
    case "$line" in
      worktree\ *) current_wt="${line#worktree }" ;;
      branch\ refs/heads/*)
        if [[ "${line#branch refs/heads/}" == "$branch" ]]; then target="$current_wt"; break; fi ;;
    esac
  done < <(git worktree list --porcelain)
  if [[ -z "$target" ]]; then echo "No worktree found for branch: $branch"; return 1; fi
  git worktree remove "$target" || return 1
  echo "Removed: $target"
}

wtrf() {
  if [[ -z "${1:-}" ]]; then echo "Usage: wtrf <branch>"; return 1; fi
  local branch="$1"
  local target=""
  local current_wt=""
  while IFS= read -r line; do
    case "$line" in
      worktree\ *) current_wt="${line#worktree }" ;;
      branch\ refs/heads/*)
        if [[ "${line#branch refs/heads/}" == "$branch" ]]; then target="$current_wt"; break; fi ;;
    esac
  done < <(git worktree list --porcelain)
  if [[ -z "$target" ]]; then echo "No worktree found for branch: $branch"; return 1; fi
  git worktree remove --force "$target" || return 1
  echo "Force removed: $target"
}

wtl() { git worktree list; }

gco-all() {
  if [[ -z "${1:-}" ]]; then echo "Usage: gco-all <branch>"; return 1; fi
  local branch="$1"
  local dir
  for dir in */; do
    if [[ -d "$dir/.git" ]]; then
      echo "==> $dir"
      (
        cd "$dir" || exit
        git fetch origin
        if git show-ref --verify --quiet "refs/heads/$branch"; then
          git switch "$branch"
        elif git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
          git switch -c "$branch" "origin/$branch"
        else
          echo "   branch not found: $branch"
        fi
      )
    fi
  done
}
