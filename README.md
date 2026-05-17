# dev-init-setting

macOS, Linux VPS, Windows 개발 환경 설정을 한 저장소에서 관리하기 위한 개인용 dotfiles/bootstrap 저장소입니다. 터미널, 쉘, 에디터, 윈도우 매니저, 생산성 도구, 로컬 Docker 서비스 설정을 OS별로 나눠 보관합니다.

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

Ubuntu VPS에서 방화벽과 기본 쉘 변경까지 함께 적용하려면 다음처럼 실행합니다.

```bash
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
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
│   ├── linux/
│   │   ├── config/
│   │   │   ├── ssh/
│   │   │   ├── tmux/
│   │   │   └── zsh/
│   │   ├── packages/
│   │   ├── README.md
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
- `os/macos/config/hammerspoon/`: macOS 자동화 Lua 스크립트와 필요한 Spoon 패치
- `os/macos/config/karabiner/`: Karabiner-Elements 키 리매핑
- `os/macos/config/raycast/`: Raycast 백업과 script command
- `os/linux/`: OpenClaw 운영용 Ubuntu VPS zsh, tmux, apt 패키지, SSH hardening 예시
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

Ubuntu VPS에서는 다음을 확인합니다.

```bash
# 쉘 설정 문법 확인
zsh -n os/linux/config/zsh/.zshrc

# tmux 설정 문법 확인
tmux source-file -n os/linux/config/tmux/.tmux.conf

# 보안 서비스 상태
systemctl status fail2ban
sudo ufw status
```

## 로컬 생성물 정리 기준

아래 항목은 repo 핵심 설정이 아니라 로컬 도구가 만드는 파일/디렉토리입니다. 필요하지 않으면 삭제해도 되지만, 실제 데이터가 들어 있는 항목은 먼저 확인합니다.

- `venv/`: Python 가상환경. 재생성 가능.
- `.serena/`: Serena 프로젝트 메타데이터. Serena를 쓰지 않으면 불필요.
- `.ruby-lsp/`: Ruby LSP 로컬 상태. Ruby 작업을 하지 않으면 불필요.
- `.claude/`: Claude Code 로컬 설정. 개인 설정이 필요 없으면 불필요.
- `.DS_Store`: macOS Finder 메타데이터. 삭제해도 프로젝트 동작에는 영향 없음.
- `services/n8n/data/`: n8n SQLite DB와 실행 로그. 워크플로/자격증명 데이터가 필요 없을 때만 삭제.

주의: `os/macos/config/hammerspoon/Spoons/` 아래에 repo가 추적하는 Spoon 패치가 있을 수 있습니다. 예를 들어 `HSKeybindings.spoon`은 단축키 목록 표시를 현재 설정에 맞게 보정하기 위해 설치 스크립트가 `~/.hammerspoon/Spoons/`로 링크합니다. 추적되지 않는 Spoon 설치본만 정리 대상으로 봅니다.

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
