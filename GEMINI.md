# GEMINI.md

이 파일은 Gemini가 이 저장소의 코드를 사용할 때 필요한 지침을 제공합니다.

## 프로젝트 개요

macOS 및 Windows 시스템을 위한 포괄적인 개발 환경 구성 저장소입니다. 이 저장소는 터미널 구성, 편집기, 창 관리 및 생산성 도구를 포함한 완벽한 개발자 워크스테이션을 설정하기 위한 인프라를 코드로 제공하며, dotfiles 및 자동 설치 스크립트를 통해 이러한 설정을 지원합니다.

## 아키텍처

### 핵심 구성 요소

- **마스터 설치 스크립트**(`install.sh`): 초기 설정을 시작하고 OS별 스크립트를 호출합니다.
- **OS별 구성**(`os/`):
    - **macOS**(`os/macos/`): macOS 전용 설정, 패키지 및 설치 스크립트가 포함됩니다.
    - **Common**(`os/common/`): 크로스 플랫폼 또는 공유 가능한 설정(터미널, 편집기 등)이 포함됩니다.
- **패키지 관리**(`os/macos/packages/Brewfile`): 모든 CLI 도구 및 애플리케이션이 포함된 Homebrew 번들 파일입니다.
- **구성 디렉터리**:
    - **공통 구성**(`os/common/config/`): AeroSpace, Hammerspoon, iTerm2, Kitty, Neovim(editors), Zsh 등
    - **시스템 구성**(`os/common/config/system/`): Fastfetch, MCP 서버 설정 등

### 개발 도구 스택

이 저장소는 다음을 구성합니다.
- **창 관리(macOS)**: **AeroSpace** (타일링 창 관리자)
- **편집기**: LazyVim 배포판이 포함된 Neovim, VS Code 통합, IntelliJ 계열 IDE 설정
- **터미널**: **Kitty** (메인), iTerm2 (보조)
- **셸**: Oh-My-Zsh, powerlevel10k 테마, 구문 강조 표시가 포함된 Zsh
- **생산성**: Raycast (런처), PopClip, BetterTouchTool, Hammerspoon
- **시스템 정보**: Fastfetch
- **버전 관리**: GitFlow가 포함된 Git
- **컨테이너**: Docker, OrbStack/Colima

### 플랫폼별 기능

**macOS:**
- **AeroSpace**: i3/sway 스타일의 타일링 창 관리자
- **Karabiner-Elements**: 고급 키 리매핑
- **Hammerspoon**: 시스템 자동화 및 유틸리티
- **Raycast**: 워크플로 자동화 및 확장 프로그램

## 필수 명령어

### 초기 설정
```bash
# 전체 환경 설정 (루트 디렉토리에서)
./install.sh

# 개별 구성 요소 설치 (예시)
./os/macos/install.sh # macOS 전용 설정 수행
```

### 패키지 관리
```bash
# 모든 패키지 설치/업데이트
brew bundle --file=./os/macos/packages/Brewfile

# 기타 Homebrew 명렁어는 동일
```

### 개발 도구

**Raycast 확장 프로그램 개발:**
`os/common/config/raycast/raycast_command/` 내에 위치하며, 각 확장 프로그램별로 `npm run build`, `npm run dev` 등을 사용합니다.

**Neovim 설정:**
LazyVim을 기반으로 하며, `os/common/config/editors/nvim` (보통 `~/.config/nvim`에 심볼릭 링크됨)에서 관리합니다.

### 설정 관리
주요 설정 파일들은 `os/common/config` 또는 `os/macos/config`에 위치하며, 설치 스크립트를 통해 시스템 경로(`~/.config/` 등)로 심볼릭 링크됩니다.

```bash
# AeroSpace 설정 (macOS 창 관리)
nvim ~/.aerospace.toml # 또는 os/macos/config/.aerospace.toml

# Kitty 설정
nvim ~/.config/kitty/kitty.conf # 또는 os/common/config/kitty/kitty.conf
```

## 키 설정 세부 정보 (AeroSpace & macOS)

### 기본 조작 (GlazeWM/i3 스타일)
- **Alt + [H/J/K/L]**: 창 포커스 이동 (좌/하/상/우)
- **Alt + Shift + [H/J/K/L]**: 창 위치 이동 (Swap)
- **Alt + R**: 리사이즈 모드 진입
- **Alt + Shift + Space**: 플로팅/타일링 모드 전환
- **Alt + F**: 전체화면 토글 (`macos-native-fullscreen`)

### 워크스페이스
- **Alt + [A-Z]**: 해당 워크스페이스로 이동
  - **A**: AI
  - **B**: Browser (Web)
  - **C**: Chat/Communication
  - **D**: Documents
  - **F**: Finder
  - **I**: IDE (Development)
  - **N**: Notes (Obsidian)
  - **T**: Terminal
  - **W**: Windows/VM
- **Alt + Shift + [A-Z]**: 현재 창을 해당 워크스페이스로 이동

### 유틸리티
- **Alt + Enter**: 터미널 열기 (설정에 따라 다름)
- **Alt + Shift + R**: 설정 리로드

## 아키텍처 참고 사항

### 파일 구성 원칙
- **OS 분리**: macOS 전용 설정과 공통 설정을 분리하여 관리합니다.
- **심볼릭 링크**: `install.sh` 스크립트는 저장소의 설정 파일을 시스템의 표준 설정 위치로 심볼릭 링크하여, 저장소에서 변경 사항을 바로 반영할 수 있도록 합니다.

### 설정 파일 위치

**저장소 구조:**
- **터미널**: `os/common/config/kitty`, `os/common/config/iterm2`
- **편집기**: `os/common/config/editors/`
- **창 관리**: `os/macos/config/.aerospace.toml`
- **생산성**: `os/common/config/raycast`, `os/common/config/hammerspoon`