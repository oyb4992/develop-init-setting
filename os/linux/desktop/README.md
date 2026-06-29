# Ubuntu KDE Plasma 데스크톱 환경

Ubuntu Desktop에서 KDE Plasma 기반 GUI 환경을 구성하는 설치 흐름입니다. 기존 `os/linux/install.sh`의 VPS 설정은 기본값으로 유지하고, GUI 데스크톱 구성은 명시적으로 선택할 때만 적용합니다.

이미 KDE Plasma가 설치된 환경에 개발 도구와 공통 dotfile만 적용하려면 이 모드 대신 `LINUX_PROFILE=dev-desktop ./install.sh`를 사용하세요.

## 설치

```bash
LINUX_PROFILE=desktop ./install.sh
```

기본 쉘을 zsh로 바꾸려면 명시적으로 켭니다.

```bash
LINUX_PROFILE=desktop CHANGE_SHELL=1 ./install.sh
```

## 포함 범위

- KDE Plasma, Dolphin, Konsole, Spectacle, KRunner
- KDE portal: `xdg-desktop-portal-kde`
- Wayland 클립보드 도구: `wl-clipboard`
- 공통 zsh, tmux, Starship, Zed/Ghostty 설정 링크
- Linux 폰트 설치: `~/.local/share/fonts`
- GUI 앱 설치: APT 우선, Flatpak/Snap 보조
- Brewfile의 Linux 호환 CLI/개발 도구

## KDE 기본 흐름

- 앱 실행: KRunner (`Alt+Space` 기본값)
- 터미널: Konsole 또는 공통 설정의 Ghostty
- 파일 관리자: Dolphin
- 스크린샷: Spectacle
- 패널/알림/단축키: Plasma 기본 설정에서 관리

KDE는 단축키와 패널 상태를 여러 사용자 설정 파일에 저장하므로 설치 스크립트가 이를 symlink하지 않습니다. AeroSpace 스타일 단축키가 필요하면 설치 후 System Settings에서 직접 조정하세요.

## 패키지 정책

APT 패키지는 `packages/apt.txt`에서 현재 apt source에 있는 항목만 설치합니다. Flatpak은 Flathub를 `--if-not-exists`로 등록한 뒤 `packages/flatpak.txt`를 설치합니다. Snap은 `packages/snap.txt`를 순서대로 설치하되 실패한 앱은 경고만 출력합니다.

Ubuntu 패키지 구성은 설치 시점의 source에 따라 달라질 수 있으므로, 설치 스크립트는 없는 패키지를 건너뛰고 경고를 남기는 방식으로 유지합니다.

기능이 겹치면 KDE 기본 앱을 우선합니다. 미디어 재생은 Haruna, 압축 파일은 Ark, Flatpak 관리는 Discover, 오디오는 Plasma 설정, 프로세스 모니터링은 Plasma System Monitor와 btop을 사용합니다.

설치하지 않을 앱은 각 목록에서 해당 줄 맨 앞에 `#`을 붙입니다. 줄 끝 주석은 패키지 이름으로 해석되므로 사용하지 않습니다.

```text
# dev.zed.Zed
md.obsidian.Obsidian
```

## macOS 앱 대응

| macOS 앱 | Ubuntu/KDE 대응 |
| --- | --- |
| Raycast | KRunner |
| IINA | Haruna |
| Keka | Ark |
| Boop, DevToys | Dev Toolbox |
| ClipGrab | Parabolic |
| Google Drive | Dolphin + KIO GDrive |
| OneDrive | onedrive |
| iShot | Spectacle |
| Keynote, Numbers, Pages | LibreOffice |
| Chrome, Ghostty, Obsidian, Postman, Telegram, Zed | Linux용 동일 앱 |

ChatGPT와 DeepL은 패키지 목록에 포함하지 않고 브라우저로 사용합니다. CloudMounter 기능이 추가로 필요하면 rclone을 수동 구성합니다. JetBrains Toolbox와 LM Studio는 이 설치기가 관리하지 않으므로 각 프로젝트의 공식 배포 파일로 수동 설치합니다. `ast-grep`, `bfg`, `grpcurl`, `mise`, `oci-cli`, `tectonic`, `uv`, `viu`, `websocat`, `yazi`는 Ubuntu APT에 없을 수 있어 각 프로젝트의 공식 설치 방법을 사용합니다. BetterTouchTool, Hammerspoon, Homerow, PopClip, LuLu 등 macOS 전용 앱은 포함하지 않습니다.

## 설치 후 확인

로그아웃한 뒤 디스플레이 매니저에서 Plasma 세션을 선택합니다. 세션 진입 후 KRunner, Konsole, Dolphin, Spectacle, tmux 클립보드를 한 번씩 확인하세요.
