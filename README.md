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

## Docker MCP 설치 (macOS/Colima)

이 저장소의 Brewfile은 Docker CLI와 Colima를 설치하지만, `docker mcp` CLI 플러그인은
별도로 설치합니다. 먼저 설치 여부를 확인합니다.

```bash
docker mcp version
```

명령을 찾을 수 없으면 Docker MCP Gateway의 공식 소스를 빌드해 Docker CLI 플러그인
경로(`~/.docker/cli-plugins/docker-mcp`)에 설치합니다.

```bash
brew install go
git clone https://github.com/docker/mcp-gateway.git ~/src/docker-mcp-gateway
cd ~/src/docker-mcp-gateway
make docker-mcp

docker mcp version
```

Docker Desktop 4.59 이상에서 MCP Toolkit을 활성화한 경우에는 플러그인이 이미 포함될 수
있습니다. Colima처럼 Docker Desktop 없이 사용하거나 플러그인이 없을 때만 위 설치 절차를
실행합니다.

Ubuntu VPS에서 방화벽과 기본 쉘 변경까지 함께 적용하려면 다음처럼 실행합니다.

```bash
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
```

Ubuntu 26.04 GUI 데스크톱에서 KDE Plasma 환경을 설치하려면 Linux 데스크톱 설치 모드를 명시합니다.

```bash
LINUX_PROFILE=desktop ./install.sh
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
│   │   ├── desktop/
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

- `os/common/config/zsh/.zshrc`: zsh, mise, 직접 로드하는 zsh 플러그인, fzf, atuin, tmux 자동 시작
- `os/common/config/zsh/.zshrc.local.example`: 개인 서버 alias처럼 repo에 넣지 않을 로컬 전용 설정 예시
- `os/common/config/tmux/.tmux.conf`: tmux pane, copy-mode, Catppuccin, plugin 설정
- `os/common/config/ghostty/config.ghostty`: Ghostty 테마, 폰트, keybind, shell integration
- `os/common/config/zed/`: Zed Vim mode와 LazyVim 스타일 keymap
- `os/common/config/editors/`: Vim/IdeaVim/VS Code 연동 설정
- `os/macos/config/.aerospace.toml`: AeroSpace workspace, window rule, keybind 설정
- `os/macos/config/hammerspoon/`: macOS 자동화 Lua 스크립트와 필요한 Spoon 패치
- `os/macos/config/karabiner/`: Karabiner-Elements 키 리매핑
- `os/macos/config/raycast/`: Raycast 백업과 script command
- `os/macos/config/mcp/docker-gateway.sh`: Colima에서 GitHub와 Filesystem MCP를 제공하는 Docker MCP Gateway 실행 래퍼
- `os/macos/config/docker/mcp/config.yaml`: Filesystem MCP의 접근 허용 경로 (`~/IdeaProjects`)
- `os/linux/`: OpenClaw 운영용 Ubuntu VPS zsh, tmux, apt 패키지, SSH hardening 예시
- `os/linux/desktop/`: Ubuntu 26.04 GUI용 KDE Plasma, 공통 dotfile, Flatpak/Snap 패키지
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

# Docker MCP Gateway (GitHub 토큰을 ~/.config/mcp/github.env에 설정한 뒤)
~/.config/mcp/docker-gateway.sh --dry-run
```

Docker MCP Gateway는 macOS 설치 시 `~/.config/mcp/docker-gateway.sh`와
`~/.docker/mcp/config.yaml`으로 링크됩니다. `github.env`는 추적하지 않으며,
`GITHUB_PERSONAL_ACCESS_TOKEN`은 별도로 보관합니다. GitHub 카탈로그에는 쓰기 도구도
표시되므로 Fine-grained PAT에는 필요한 최소 권한만 부여합니다. Filesystem MCP는
`~/IdeaProjects`만 접근하도록 제한됩니다.

### GitHub 인증 파일 만들기

GitHub의 Fine-grained personal access token을 생성할 때 리소스 소유자와 접근할 저장소를
제한하고, 필요한 읽기 권한만 선택합니다. 토큰을 셸 히스토리에 남기지 않도록 아래 명령으로
숨김 입력받아 `github.env`를 만듭니다.

```bash
mkdir -p ~/.config/mcp
chmod 700 ~/.config/mcp

printf 'GitHub fine-grained PAT: '
read -r -s github_pat
printf '\n'
printf 'GITHUB_PERSONAL_ACCESS_TOKEN=%s\n' "$github_pat" > ~/.config/mcp/github.env
unset github_pat
chmod 600 ~/.config/mcp/github.env
```

파일에는 다음 한 줄만 들어갑니다. 실제 토큰은 저장소, 스크린샷, 채팅에 공유하지 않습니다.

```dotenv
GITHUB_PERSONAL_ACCESS_TOKEN=github_pat_...
```

Gateway를 실행하기 전에는 변수 이름과 파일 권한만 확인합니다. 토큰 값 자체를 출력하지
않습니다.

```bash
cut -d= -f1 ~/.config/mcp/github.env
stat -f '%Sp %N' ~/.config/mcp/github.env
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

Ubuntu 데스크톱 설치 모드에서는 다음을 확인합니다.

```bash
# 설치 스크립트 문법 확인
bash -n os/linux/desktop/install.sh
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
- 개인 서버 접속 alias처럼 노출되면 곤란한 값은 `~/.zshrc.local`에 둡니다.
- 설치 스크립트는 멱등적으로 유지합니다.
- OS 공통 설정은 `os/common`, 플랫폼 전용 설정은 `os/macos` 또는 `os/windows`에 둡니다.
