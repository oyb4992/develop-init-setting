# Ubuntu VPS 터미널 환경

OpenClaw 운영용 개인 VPS를 위한 가벼운 터미널 설정입니다. macOS 데스크톱 설정을 그대로 쓰지 않고, SSH 세션 안정성, 로그 확인, Docker Compose 운영, 기본 보안 설정에 맞춰 분리했습니다.

## 설치

루트 설치 스크립트는 Linux에서 이 디렉토리의 설치 스크립트를 실행합니다.

```bash
./install.sh
```

기본 설치는 패키지 설치와 dotfile 링크만 수행합니다. 방화벽과 기본 쉘 변경은 명시적으로 켤 때만 실행합니다.

```bash
APPLY_SECURITY=1 CHANGE_SHELL=1 ./install.sh
```

## 포함 도구

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
