# Ubuntu Linux 환경

Linux 설정은 기본 VPS 프로파일과 Ubuntu 26.04 GUI 데스크톱 프로파일로 나뉩니다. 기본값은 OpenClaw 운영용 개인 VPS를 위한 가벼운 터미널 설정이며, GUI 데스크톱은 명시적으로 선택할 때만 적용합니다.

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

## Ubuntu 26.04 GUI 데스크톱 설치

Sway 기반 Wayland 타일링 데스크톱은 별도 프로파일입니다. macOS의 AeroSpace/Raycast/상태바 흐름을 Sway/Wofi/Waybar 조합으로 옮깁니다.

```bash
LINUX_PROFILE=desktop ./install.sh
```

데스크톱 프로파일은 `os/common/install.sh`도 함께 실행해서 공통 zsh, tmux, Starship, 에디터 설정과 폰트를 재사용합니다. 자세한 내용은 `desktop/README.md`를 참고하세요.

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

GUI 데스크톱은 APT를 기본으로 사용하고, 앱 성격에 따라 Flatpak과 Snap을 보조로 사용합니다. Ubuntu 26.04 패키지 availability가 설치 시점의 source에 따라 달라질 수 있으므로 apt 패키지는 현재 source에 없는 항목을 건너뛰고 경고만 출력합니다.
