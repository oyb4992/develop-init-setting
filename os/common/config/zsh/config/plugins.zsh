# Zsh 완성(Completion) 시스템 초기화 (compdef 명령어 에러 해결)
autoload -Uz compinit
compinit

# 플러그인이 저장될 디렉토리 정의
ZPLUGINDIR="$HOME/.config/zsh/plugins"
mkdir -p "$ZPLUGINDIR"

# [경량화 핵심] 플러그인 매니저 없이 자동 다운로드 및 직접 로드하는 경량 함수
function zplug_light() {
    local repo=$1
    local plugin_name=${repo#*/}
    local init_file="$ZPLUGINDIR/$plugin_name/$plugin_name.plugin.zsh"

    if [[ ! -d "$ZPLUGINDIR/$plugin_name" ]]; then
        if command -v git >/dev/null 2>&1; then
            echo "📥 Installing plugin: $repo..."
            git clone --depth 1 "https://github.com/$repo.git" "$ZPLUGINDIR/$plugin_name" >/dev/null 2>&1 || return
        else
            return
        fi
    fi

    if [[ -f "$init_file" ]]; then
        source "$init_file"
    elif [[ -f "$ZPLUGINDIR/$plugin_name/$plugin_name.zsh" ]]; then
        source "$ZPLUGINDIR/$plugin_name/$plugin_name.zsh"
    elif [[ -f "$ZPLUGINDIR/$plugin_name/init.sh" ]]; then
        source "$ZPLUGINDIR/$plugin_name/init.sh"
    fi
}

# 순수 플러그인 직접 로드 (매니저 오버헤드 0%)
zplug_light "zsh-users/zsh-autosuggestions"
zplug_light "zsh-users/zsh-history-substring-search"
zplug_light "babarot/enhancd"
zplug_light "Aloxaf/fzf-tab"
zplug_light "zsh-users/zsh-syntax-highlighting" # 구문 강조는 항상 마지막에 로드

# 수동 플러그인 전체 업데이트 함수
function zplug_update() {
    for d in "$ZPLUGINDIR"/*/; do
        echo "Updating ${d:t}..."
        git -C "$d" pull
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
