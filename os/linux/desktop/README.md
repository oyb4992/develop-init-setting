# Ubuntu 26.04 KDE Plasma 데스크톱 환경

Ubuntu 26.04 Desktop에서 KDE Plasma 기반 GUI 환경을 구성하는 설치 흐름입니다. 기존 `os/linux/install.sh`의 VPS 설정은 기본값으로 유지하고, GUI 데스크톱은 명시적으로 선택할 때만 적용합니다.

## 설치

```bash
LINUX_PROFILE=desktop ./install.sh
```

기본 명령은 Krohnkite를 설치하지만 KDE가 함께 사용하는 설정 파일은 변경하지 않습니다. Krohnkite 설정과 AeroSpace 스타일 단축키를 병합하려면 다음처럼 명시적으로 선택합니다.

```bash
LINUX_PROFILE=desktop APPLY_KROHNKITE_CONFIG=1 ./install.sh
```

기본 쉘을 zsh로 바꾸려면 명시적으로 켭니다.

```bash
LINUX_PROFILE=desktop CHANGE_SHELL=1 ./install.sh
```

## 포함 범위

- KDE Plasma, Dolphin, Konsole, Spectacle, KRunner
- Krohnkite KWin 동적 타일링 스크립트
- KDE portal: `xdg-desktop-portal-kde`
- Wayland 클립보드 도구: `wl-clipboard`
- 공통 zsh, tmux, Starship, Zed/Ghostty 설정 링크
- Linux 폰트 설치: `~/.local/share/fonts`
- GUI 앱 설치: APT 우선, Flatpak/Snap 보조
- Brewfile의 Linux 호환 CLI/개발 도구

## KDE 기본 흐름

- 앱 실행: KRunner (`Alt+Space` 기본값)
- 창 타일링: Krohnkite
- 터미널: Konsole 또는 공통 설정의 Ghostty
- 파일 관리자: Dolphin
- 스크린샷: Spectacle
- 패널/알림/단축키: Plasma 기본 설정에서 관리

KDE는 단축키와 패널 상태를 여러 사용자 설정 파일에 저장하므로 설치 스크립트가 이 파일들을 symlink하지 않습니다. 기본 설치에서는 Krohnkite를 `System Settings > Window Management > KWin Scripts`에서 활성화하고 필요한 설정과 단축키를 직접 조정합니다. `APPLY_KROHNKITE_CONFIG=1`을 지정한 경우에만 아래 추적 설정을 기존 KDE 상태에 병합합니다.

## Krohnkite 설정 병합

옵트인 설정은 `~/.config/kwinrc`와 `~/.config/kglobalshortcutsrc`가 이미 있으면 각각 타임스탬프가 붙은 백업을 만든 뒤, 추적한 그룹과 키만 병합합니다. 추적 조각으로 사용자 파일 전체를 덮어쓰거나 symlink하지 않으며 관련 없는 KDE 설정은 유지합니다. 두 병합 결과를 모두 임시 파일로 렌더링한 뒤 대상 파일을 원자적으로 교체하고, 교체에 실패하면 백업으로 복구합니다.

동시에 실행된 병합 명령은 `~/.config/.krohnkite-config-merge.lock`으로 직렬화됩니다. 이 mode `0600` 숨김 파일은 KDE 설정 상태가 아닌 병합 조정용 메타데이터이며 실행 후에도 안전하게 재사용하도록 삭제하지 않습니다. KWin, KGlobalAccel 또는 System Settings가 병합 도중 대상 파일을 변경하면 스크립트는 동시 KDE 설정 변경을 감지해 안전하게 중단합니다. 첫 번째 파일을 교체한 뒤 KDE가 그 파일을 다시 변경하고 이후 단계가 실패한 경우에도 그 변경은 덮어쓰거나 삭제하지 않으며, 경고에 표시된 백업으로 수동 복구해야 할 수 있습니다. 적용 중에는 System Settings에서 KDE 설정을 편집하지 말고, 이런 오류가 발생하면 편집을 멈춘 뒤 다시 실행하세요. 각 검사와 파일 교체 사이의 극히 짧은 경쟁 구간이나 두 대상 파일을 하나의 crash-atomic 단위로 만드는 것까지 보장하지는 않습니다.

설정 병합이 성공하면 KWin과 KGlobalAccel이 새 상태를 읽도록 **즉시 재부팅**하세요. Krohnkite를 껐다 켜거나 KWin을 강제로 재시작하는 방식은 사용하지 않습니다.

주요 단축키 매핑은 다음과 같습니다.

| 동작 | 단축키 |
| --- | --- |
| 방향 포커스 | `Alt+H/J/K/L` |
| 창 이동 | `Alt+Shift+H/J/K/L` |
| Tile 레이아웃 | `Alt+/` |
| Spread 레이아웃 | `Alt+,` |
| 플로팅 전환 | `Alt+Shift+Space` |
| 포커스 창 닫기 | `Alt+Ctrl+Q` |
| 의미 기반 데스크톱 전환 | `Alt+A/B/C/D/F/I/N/T/W/Z` |
| 의미 기반 데스크톱으로 창 이동 | `Alt+Shift+A/B/C/D/F/I/N/T/W/Z` |

가상 데스크톱은 `A`, `B`, `C`, `D`, `F`, `I`, `N`, `T`, `W`, `Z` 순서입니다. 각 데스크톱 UUID는 `~/.config/kwinrc`의 `[Desktops]` 그룹에 있는 `Id_1`부터 `Id_10`까지에서 확인합니다. 기존 UUID는 보존하고 새로 필요한 데스크톱에만 UUID를 생성합니다.

## 애플리케이션 규칙

Linux 창 클래스는 `System Settings > Window Management > Window Rules > Add New > Detect Window Properties`에서 확인합니다.

`config/krohnkite/kwinrulesrc.example`은 의미 기반 데스크톱 라우팅을 만들기 위한 참고 자료일 뿐입니다. 이 파일을 사용자 `~/.config/kwinrulesrc` 전체에 복사하지 마세요. 필요한 규칙만 골라 실제 창 클래스와 `[Desktops]` UUID를 확인한 뒤 System Settings에서 다시 만들거나 기존 규칙에 병합합니다.

항상 플로팅할 창 클래스는 먼저 실제 값을 확인합니다. 확인된 클래스는 추적 중인 `config/krohnkite/kwinrc` 조각의 주석 처리된 `floatingClass` 예시에 추가하고 `APPLY_KROHNKITE_CONFIG=1`로 다시 적용할 수 있습니다.

## 패키지 정책

APT 패키지는 `packages/apt.txt`에서 현재 apt source에 있는 항목만 설치합니다. Flatpak은 Flathub를 `--if-not-exists`로 등록한 뒤 `packages/flatpak.txt`를 설치합니다. Snap은 `packages/snap.txt`를 순서대로 설치하되 실패한 앱은 경고만 출력합니다.

Ubuntu 26.04 패키지 구성은 설치 시점의 source에 따라 달라질 수 있으므로, 설치 스크립트는 없는 패키지를 건너뛰고 경고를 남기는 방식으로 유지합니다.

Krohnkite는 공식 Codeberg 릴리스 `0.9.9.2`의 `.kwinscript` 파일을 내려받아 SHA-256을 검증한 뒤 사용자 범위에 설치합니다. 설치된 패키지 경로의 `metadata.json`에서 `KPlugin.Version`이 정확히 `0.9.9.2`로 확인될 때만 건너뛰고, 버전이 다르거나 경로 또는 메타데이터를 읽고 해석할 수 없으면 체크섬으로 고정한 공식 파일로 업그레이드합니다.

`APPLY_KROHNKITE_CONFIG=1`을 지정해도 설정 병합은 설치 메타데이터가 정확히 `0.9.9.2`이거나, 체크섬을 검증한 설치 또는 업그레이드가 성공한 뒤에만 실행됩니다. 다운로드, 체크섬, 임시 파일 생성, 설치 또는 업그레이드가 실패하면 필요한 Krohnkite 버전이 준비되지 않았다는 경고와 함께 설정 병합을 건너뜁니다. 이 실패는 경고로만 처리되어 나머지 Flatpak, Snap, 쉘 설정은 계속 진행됩니다.

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

ChatGPT와 DeepL은 패키지 목록에 포함하지 않고 브라우저로 사용합니다. CloudMounter 기능이 추가로 필요하면 rclone을 수동 구성합니다. JetBrains Toolbox와 LM Studio는 이 설치기가 관리하지 않으므로 각 프로젝트의 공식 배포 파일로 수동 설치합니다. `ast-grep`, `bfg`, `grpcurl`, `mise`, `oci-cli`, `tectonic`, `uv`, `viu`, `websocat`, `yazi`는 Ubuntu 26.04 APT에 없어 각 프로젝트의 공식 설치 방법을 사용합니다. BetterTouchTool, Hammerspoon, Homerow, PopClip, LuLu 등 macOS 전용 앱은 포함하지 않습니다.

## 설치 후 확인

수동 QA는 다음 순서로 진행합니다.

1. 기본 명령에서는 Krohnkite 설치 후 설정 병합을 건너뛴다는 메시지가 나오고 기존 KDE 설정이 변경되지 않는지 확인합니다.
2. 옵트인 명령에서는 정확한 `0.9.9.2` 메타데이터 또는 성공한 고정 버전 설치/업그레이드 뒤에만 기존 `kwinrc`와 `kglobalshortcutsrc`의 백업 경로와 병합 성공 메시지가 나오는지 확인합니다.
3. Krohnkite 설치나 업그레이드가 실패한 경우 설정 미적용 안내가 나오고 Flatpak, Snap, 쉘 단계가 계속되는지 확인한 뒤 문제를 해결하고 옵트인 명령을 다시 실행합니다.
4. 병합했다면 즉시 재부팅하고 디스플레이 매니저에서 Plasma 세션을 선택합니다. 병합하지 않았다면 System Settings에서 Krohnkite를 활성화하고 설정합니다.
5. Krohnkite가 활성화되고 초기 Spread 레이아웃과 5픽셀 간격이 적용되는지 확인합니다.
6. 방향 포커스, 창 이동, Tile/Spread, 플로팅, 닫기 단축키를 각각 실행합니다.
7. 열 개의 데스크톱 이름, `Id_1`부터 `Id_10`까지의 UUID, 데스크톱 전환과 창 이동 단축키를 확인합니다.
8. 필요한 경우 창 속성을 감지해 예시 규칙 하나를 System Settings에서 다시 만들고 새 창이 지정한 데스크톱에서 열리는지 확인합니다.
9. KRunner, Konsole, Dolphin, Spectacle, tmux 클립보드를 한 번씩 확인합니다.
