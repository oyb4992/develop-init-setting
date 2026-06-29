# Ubuntu Linux 환경

Linux 설정은 기본 VPS 설치 흐름, 기존 GUI 데스크톱용 개발환경 설정 흐름, KDE Plasma 데스크톱 구성 설치 흐름으로 나뉩니다. 기본값은 OpenClaw 운영용 개인 VPS를 위한 가벼운 터미널 설정이며, 데스크톱 관련 흐름은 명시적으로 선택할 때만 적용합니다.

## VPS 설치

루트 설치 스크립트는 Linux에서 기본적으로 이 디렉토리의 VPS 설치 스크립트를 실행합니다.

```bash
./install.sh
LINUX_PROFILE=vps ./install.sh
```

기본 설치는 패키지 설치와 dotfile 링크만 수행합니다. 방화벽과 기본 쉘 변경은 명시적으로 켤 때만 실행합니다.

```bash
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
```

## 기존 Ubuntu/KDE Plasma 데스크톱 개발환경

이미 KDE Plasma가 설치된 Ubuntu 24.04 같은 GUI 데스크톱에서 개발 도구와 공통 터미널/에디터 설정만 적용합니다. KDE Plasma, display manager, Flatpak 앱, Snap 앱은 설치하지 않습니다.

```bash
LINUX_PROFILE=dev-desktop ./install.sh
```

기본 쉘을 zsh로 바꾸려면 명시적으로 켭니다.

```bash
LINUX_PROFILE=dev-desktop CHANGE_SHELL=1 ./install.sh
```

Ubuntu 24.04 기본 APT source에 없는 `starship`, `atuin`, `lazygit`은 이 모드의 APT 목록에서 제외했습니다. 필요하면 각 프로젝트의 공식 설치 방법으로 별도 설치하세요.

## KDE Plasma 데스크톱 구성 설치

KDE Plasma 기반 데스크톱 구성 설치 흐름입니다. macOS의 공통 터미널/에디터 설정은 재사용하되, 런처와 패널, 알림, 스크린샷은 Plasma 기본 도구를 사용합니다.

```bash
LINUX_PROFILE=desktop ./install.sh
```

데스크톱 구성 설치 흐름은 `os/common/install.sh`도 함께 실행해서 공통 zsh, tmux, Starship, 에디터 설정과 폰트를 재사용합니다. 자세한 내용은 `desktop/README.md`를 참고하세요.

## VPS 포함 도구

- `zsh`, `tmux`, `neovim`
- `fzf`, `ripgrep`, `fd-find`, `jq`, `bat`
- `btop`, `duf`, `ncdu`, `htop`, `lnav`
- `ufw`, `fail2ban`, `unattended-upgrades`
- `httpie`, `rsync`

## OpenClaw 운영 alias

서버용 `.zshrc`는 `OPENCLAW_DIR`를 기준으로 Docker Compose 운영 alias를 제공합니다.

```bash
export OPENCLAW_DIR="$HOME/openclaw"
oc        # OpenClaw 디렉토리로 이동
ocps      # docker compose ps
oclogs    # docker compose logs -f --tail=200
ocrestart # docker compose restart
ocdeploy  # git pull --ff-only && docker compose pull && docker compose up -d
```

## 보안 설정

`APPLY_SECURITY=1`을 지정하면 다음을 수행합니다.

- `ufw allow OpenSSH`
- `ufw --force enable`
- `fail2ban` 활성화
- `unattended-upgrades` noninteractive 설정

SSH daemon 설정은 자동으로 덮어쓰지 않습니다. 먼저 `config/ssh/sshd_config.example`를 검토한 뒤 서버 상황에 맞게 `/etc/ssh/sshd_config`에 반영하세요.

## 데스크톱 패키지 정책

`dev-desktop`은 APT 기반 개발 도구와 공통 dotfile만 적용합니다. 기존 Plasma 세션 보존을 위해 KDE Plasma, display manager, Flatpak, Snap 패키지를 설치하지 않습니다.

`desktop`은 KDE 데스크톱 구성을 위해 APT를 기본으로 사용하고, 앱 성격에 따라 Flatpak과 Snap을 보조로 사용합니다. 패키지 availability가 설치 시점의 source에 따라 달라질 수 있으므로 apt 패키지는 현재 source에 없는 항목을 건너뛰고 경고만 출력합니다.
