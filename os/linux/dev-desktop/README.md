# Ubuntu 데스크톱 개발 환경

이미 KDE Plasma가 설치된 Ubuntu 데스크톱에 개발 도구와 공통 dotfile만 적용하는 설치 흐름입니다.

```bash
LINUX_PROFILE=dev-desktop ./install.sh
```

기본 쉘을 zsh로 바꾸려면 명시적으로 켭니다.

```bash
LINUX_PROFILE=dev-desktop CHANGE_SHELL=1 ./install.sh
```

## 범위

- APT 기반 CLI/개발 도구 설치
- Wayland 클립보드 연동용 `wl-clipboard`
- 공통 zsh, tmux, Starship, Zed/Ghostty 설정 링크
- Linux 폰트 설치: `~/.local/share/fonts`

이 모드는 KDE Plasma, display manager, Flatpak 앱, Snap 앱을 설치하지 않습니다. 이미 설치된 Plasma 세션을 보존하는 목적입니다.

Ubuntu 24.04 기본 APT source에 없는 `starship`, `atuin`, `lazygit`은 이 목록에서 제외했습니다. 필요하면 각 프로젝트의 공식 설치 방법으로 별도 설치하세요.
