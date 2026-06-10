# Ubuntu 26.04 GUI 데스크톱 환경

Ubuntu 26.04 Desktop에서 Sway 기반 Wayland 타일링 환경을 구성하는 별도 프로파일입니다. 기존 `os/linux/install.sh`의 VPS 설정은 기본값으로 유지하고, GUI 데스크톱은 명시적으로 선택할 때만 적용합니다.

## 설치

```bash
LINUX_PROFILE=desktop ./install.sh
```

기본 쉘을 zsh로 바꾸려면 명시적으로 켭니다.

```bash
LINUX_PROFILE=desktop CHANGE_SHELL=1 ./install.sh
```

## 포함 범위

- Sway, Waybar, Wofi, Mako
- Wayland 스크린샷/클립보드 도구: `grim`, `slurp`, `swappy`, `wl-clipboard`, `cliphist`
- 공통 zsh, tmux, Starship, Zed/Ghostty/Kitty 설정 링크
- Linux 폰트 설치: `~/.local/share/fonts`
- GUI 앱 설치: APT 우선, Flatpak/Snap 보조

## 키 바인딩

- `Alt+Enter`: 터미널
- `Alt+Space`: 앱 런처
- `Alt+Ctrl+v`: 클립보드 히스토리
- `Alt+Ctrl+e`: 파일 관리자
- `Alt+h/j/k/l`: 포커스 이동
- `Alt+Shift+h/j/k/l`: 창 이동
- `Alt+a/b/c/d/f/i/n/t/w/z`: 워크스페이스 이동
- `Alt+Shift+a/b/c/d/f/i/n/t/w/z`: 창을 워크스페이스로 이동
- `Alt+Shift+s`: 영역 스크린샷
- `Alt+Shift+Space`: 플로팅 토글
- `Alt+Ctrl+q`: 창 닫기
- `Alt+Shift+r`: Sway 설정 다시 로드

## 패키지 정책

APT 패키지는 `packages/apt.txt`에서 현재 apt source에 있는 항목만 설치합니다. Flatpak은 Flathub를 `--if-not-exists`로 등록한 뒤 `packages/flatpak.txt`를 설치합니다. Snap은 `packages/snap.txt`를 순서대로 설치하되 실패한 앱은 경고만 출력합니다.

Ubuntu 26.04 패키지 구성은 설치 시점의 source에 따라 달라질 수 있으므로, 설치 스크립트는 없는 패키지를 건너뛰고 경고를 남기는 방식으로 유지합니다.

## 설치 후 확인

로그아웃한 뒤 디스플레이 매니저에서 Sway 세션을 선택합니다. 세션 진입 후 터미널, Wofi, Waybar, 스크린샷, 클립보드 히스토리를 한 번씩 확인하세요.
