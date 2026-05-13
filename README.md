# dev-init-setting

macOS와 Windows 개발 환경 설정을 한 저장소에서 관리하기 위한 개인용 dotfiles/bootstrap 저장소입니다. 터미널, 쉘, 에디터, 윈도우 매니저, 생산성 도구, 로컬 Docker 서비스 설정을 OS별로 나눠 보관합니다.

## 빠른 시작

```bash
git clone <repository-url>
cd dev-init-setting

chmod +x install.sh
./install.sh
```

macOS에서 패키지만 먼저 설치하려면 다음을 실행합니다.

```bash
brew bundle --file ./os/macos/packages/Brewfile
```

## 디렉토리 구조

```text
dev-init-setting/
├── README.md
├── docs/
│   └── README.md
├── install.sh
├── os/
│   ├── common/
│   │   ├── assets/
│   │   ├── config/
│   │   │   ├── editors/
│   │   │   ├── ghostty/
│   │   │   ├── git/
│   │   │   ├── kitty/
│   │   │   ├── system/
│   │   │   ├── tmux/
│   │   │   ├── zed/
│   │   │   └── zsh/
│   │   ├── scripts/
│   │   └── install.sh
│   ├── macos/
│   │   ├── config/
│   │   │   ├── aerospace
│   │   │   ├── hammerspoon
│   │   │   ├── karabiner
│   │   │   ├── popClip
│   │   │   └── raycast
│   │   ├── packages/
│   │   └── install.sh
│   └── windows/
│       ├── config/
│       └── packages/
└── services/
    └── n8n/
```

## 주요 설정

- `os/common/config/zsh/.zshrc`: zsh, mise, zplug, fzf, atuin, tmux 자동 시작
- `os/common/config/tmux/.tmux.conf`: tmux pane, copy-mode, Catppuccin, plugin 설정
- `os/common/config/ghostty/config.ghostty`: Ghostty 테마, 폰트, keybind, shell integration
- `os/common/config/zed/`: Zed Vim mode와 LazyVim 스타일 keymap
- `os/common/config/editors/`: Vim/IdeaVim/VS Code 연동 설정
- `os/macos/config/.aerospace.toml`: AeroSpace workspace, window rule, keybind 설정
- `os/macos/config/hammerspoon/`: macOS 자동화 Lua 스크립트
- `os/macos/config/karabiner/`: Karabiner-Elements 키 리매핑
- `os/macos/config/raycast/`: Raycast 백업과 script command
- `services/n8n/`: 로컬 n8n Docker Compose 환경

## 설치 후 확인

```bash
# Homebrew 상태
brew doctor

# 쉘 설정 문법 확인
zsh -n os/common/config/zsh/.zshrc

# tmux 설정 문법 확인
tmux source-file -n os/common/config/tmux/.tmux.conf

# AeroSpace 설정 확인
aerospace reload-config --dry-run
```

## 로컬 생성물 정리 기준

아래 항목은 repo 핵심 설정이 아니라 로컬 도구가 만드는 파일/디렉토리입니다. 필요하지 않으면 삭제해도 되지만, 실제 데이터가 들어 있는 항목은 먼저 확인합니다.

- `venv/`: Python 가상환경. 재생성 가능.
- `.serena/`: Serena 프로젝트 메타데이터. Serena를 쓰지 않으면 불필요.
- `.ruby-lsp/`: Ruby LSP 로컬 상태. Ruby 작업을 하지 않으면 불필요.
- `.claude/`: Claude Code 로컬 설정. 개인 설정이 필요 없으면 불필요.
- `.DS_Store`: macOS Finder 메타데이터. 삭제해도 프로젝트 동작에는 영향 없음.
- `services/n8n/data/`: n8n SQLite DB와 실행 로그. 워크플로/자격증명 데이터가 필요 없을 때만 삭제.
- `os/macos/config/hammerspoon/Spoons/`: Hammerspoon Spoon 설치본. bootstrap 방식에 따라 필요할 수 있으므로 삭제 전 확인.

ignored 파일 정리 후보는 dry-run으로 먼저 확인합니다.

```bash
git clean -ndX
```

## 유지보수

```bash
# Homebrew 패키지 업데이트
brew update
brew upgrade
brew cleanup --prune=all

# macOS 패키지 목록 갱신
brew bundle dump --file ./os/macos/packages/Brewfile --force

# Git 상태 확인
git status --short --ignored
```

## 원칙

- 공유 가능한 설정은 repo에 둡니다.
- 개인 토큰, `.env`, 런타임 DB, 캐시, 가상환경은 commit하지 않습니다.
- 설치 스크립트는 멱등적으로 유지합니다.
- OS 공통 설정은 `os/common`, 플랫폼 전용 설정은 `os/macos` 또는 `os/windows`에 둡니다.
