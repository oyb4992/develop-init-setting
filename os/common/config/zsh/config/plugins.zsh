# 플러그인이 저장될 디렉토리 정의
ZSH_PLUGIN_DIR="$HOME/.config/zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

# fpath 중복 방지
typeset -U fpath

# 플러그인 매니저 없이 GitHub 저장소를 직접 다운로드
function clone_zsh_plugin() {
    local repo=$1
    local plugin_name=${repo#*/}
    local plugin_dir="$ZSH_PLUGIN_DIR/$plugin_name"

    if [[ -d "$plugin_dir" ]]; then
        return
    fi

    if ! command -v git >/dev/null 2>&1; then
        return
    fi

    echo "Installing zsh plugin: $repo..."
    git clone --depth 1 "https://github.com/$repo.git" "$plugin_dir" >/dev/null 2>&1
}

# source 기반 플러그인 로드
function load_zsh_plugin() {
    local repo=$1
    local plugin_name=${repo#*/}
    local plugin_dir="$ZSH_PLUGIN_DIR/$plugin_name"

    clone_zsh_plugin "$repo" || return

    if [[ -f "$plugin_dir/$plugin_name.plugin.zsh" ]]; then
        source "$plugin_dir/$plugin_name.plugin.zsh"
    elif [[ -f "$plugin_dir/$plugin_name.zsh" ]]; then
        source "$plugin_dir/$plugin_name.zsh"
    elif [[ -f "$plugin_dir/init.sh" ]]; then
        source "$plugin_dir/init.sh"
    fi
}

# Completion-only 플러그인은 compinit 전에 fpath에 등록해야 함
clone_zsh_plugin "zsh-users/zsh-completions"
if [[ -d "$ZSH_PLUGIN_DIR/zsh-completions/src" ]]; then
    fpath=("$ZSH_PLUGIN_DIR/zsh-completions/src" $fpath)
fi

# Zsh 완성(Completion) 시스템 초기화
autoload -Uz compinit
compinit

# source 기반 플러그인 로드
load_zsh_plugin "zsh-users/zsh-autosuggestions"
load_zsh_plugin "zsh-users/zsh-history-substring-search"
load_zsh_plugin "babarot/enhancd"
load_zsh_plugin "Aloxaf/fzf-tab"
load_zsh_plugin "zsh-users/zsh-syntax-highlighting" # 구문 강조는 항상 마지막에 로드

# 수동 플러그인 전체 업데이트 함수
function zsh_plugins_update() {
    local plugin_dir

    for plugin_dir in "$ZSH_PLUGIN_DIR"/*(/N); do
        if [[ -d "$plugin_dir/.git" ]]; then
            echo "Updating ${plugin_dir:t}..."
            git -C "$plugin_dir" pull --ff-only
        fi
    done
}

# fzf-tab 설정 적용 (기존 최적화 설정 유지)
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:complete:*' fzf-preview '
  if [[ -d "$realpath" ]]; then
    eza --icons=auto --group-directories-first --color=always "$realpath" 2>/dev/null || ls -la "$realpath"
  elif [[ -f "$realpath" ]]; then
    if file --mime "$realpath" | grep -q "text/"; then
      bat --color=always --style=numbers --line-range=:200 "$realpath" 2>/dev/null || sed -n "1,200p" "$realpath"
    else
      file "$realpath"
    fi
  fi
'
setopt extendedglob
