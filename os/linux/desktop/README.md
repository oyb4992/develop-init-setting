# Ubuntu 26.04 KDE Plasma 데스크톱 환경

Ubuntu 26.04 Desktop에서 KDE Plasma 기반 GUI 환경을 구성하는 설치 흐름입니다. 기존 `os/linux/install.sh`의 VPS 설정은 기본값으로 유지하고, GUI 데스크톱은 명시적으로 선택할 때만 적용합니다.

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
- 공통 zsh, tmux, Starship, Zed/Ghostty/Kitty 설정 링크
- Linux 폰트 설치: `~/.local/share/fonts`
- GUI 앱 설치: APT 우선, Flatpak/Snap 보조

## KDE 기본 흐름

- 앱 실행: KRunner (`Alt+Space` 기본값)
- 터미널: Konsole 또는 공통 설정의 Ghostty/Kitty
- 파일 관리자: Dolphin
- 스크린샷: Spectacle
- 패널/알림/단축키: Plasma 기본 설정에서 관리

KDE는 단축키와 패널 상태를 여러 사용자 설정 파일에 저장하므로 설치 스크립트가 이를 symlink하지 않습니다. AeroSpace 스타일 단축키가 필요하면 설치 후 System Settings에서 직접 조정하세요.

## 패키지 정책

APT 패키지는 `packages/apt.txt`에서 현재 apt source에 있는 항목만 설치합니다. Flatpak은 Flathub를 `--if-not-exists`로 등록한 뒤 `packages/flatpak.txt`를 설치합니다. Snap은 `packages/snap.txt`를 순서대로 설치하되 실패한 앱은 경고만 출력합니다.

Ubuntu 26.04 패키지 구성은 설치 시점의 source에 따라 달라질 수 있으므로, 설치 스크립트는 없는 패키지를 건너뛰고 경고를 남기는 방식으로 유지합니다.

## 설치 후 확인

로그아웃한 뒤 디스플레이 매니저에서 Plasma 세션을 선택합니다. 세션 진입 후 KRunner, Konsole, Dolphin, Spectacle, tmux 클립보드를 한 번씩 확인하세요.
