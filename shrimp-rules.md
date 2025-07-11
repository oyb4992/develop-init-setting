# 개발 가이드라인

## 프로젝트 개요

이 프로젝트는 다양한 개발 도구 및 애플리케이션의 초기 설정을 관리합니다. 주요 기술 스택은 셸 스크립트, Vim 스크립트, Lua, JavaScript, TypeScript, Ruby, Swift, AutoHotkey 등 다양합니다.

## 프로젝트 아키텍처

각 도구의 설정 파일은 해당 도구의 이름을 딴 디렉토리에 포함되어 있습니다.

- **.aerospace.toml**: AeroSpace 윈도우 매니저 설정
- **.idea-lazy.vim**: JetBrains IDE용 LazyVim 키맵 설정
- **.ideavimrc**: IdeaVim 플러그인 설정
- **.skhdrc**: skhd 단축키 데몬 설정 (yabai와 함께 사용)
- **.yabairc**: yabai 창 관리자 설정
- **Brewfile**: Homebrew 패키지 목록 (구버전)
- **NewBrewfile**: Homebrew 패키지 목록 (현재 사용)
- **init.vim**: Neovim 설정 (VSCode 연동)
- **install.sh**: 전체 개발 환경 설치 및 설정 스크립트
- **vscode-integration.vim**: VSCode Neovim 확장 키맵 설정
- **vscode/**: VSCode 설정
- **sublime_text/**: Sublime Text 설정
- **karabiner/**: Karabiner-Elements 설정 (`karabiner.json`)
- **kitty/**: kitty 터미널 에뮬레이터 설정 (`kitty.conf`)
- **lazyVim/**: Neovim용 LazyVim 설정
  - **lazyVim/config/autocmds.lua**: LazyVim 자동 명령 설정
  - **lazyVim/config/keymaps.lua**: LazyVim 키맵 설정
  - **lazyVim/config/lazy.lua**: LazyVim 플러그인 관리 및 로드 설정
  - **lazyVim/config/options.lua**: LazyVim 옵션 설정
  - **lazyVim/plugins/cmp.lua**: nvim-cmp 자동 완성 플러그인 설정
  - **lazyVim/plugins/copilotchat.lua**: CopilotChat 플러그인 설정
  - **lazyVim/plugins/example.lua**: LazyVim 플러그인 설정 예시
- **raycast/**: Raycast 스크립트 및 설정
  - **raycast/raycast_command/parse.rb**: Raycast 명령을 위한 Ruby 스크립트 (자연어 날짜/시간 파싱)
  - **raycast/raycast_command/app-cleaner/**: Raycast App Cleaner 확장 프로그램
  - **raycast/raycast_command/Appstore/**: Raycast App Store 검색 확장 프로그램
  - **raycast/raycast_command/FindAnyFile/**: Raycast Find Any File 확장 프로그램
  - **raycast/raycast_command/iterm/**: Raycast iTerm2 셸 명령 실행 확장 프로그램
  - **raycast/raycast_command/kakaomap/**: Raycast 카카오맵 검색/길찾기 확장 프로그램
  - **raycast/raycast_command/Naver-Dictionary-Raycast-main/**: Raycast 네이버 사전 확장 프로그램
  - **raycast/raycast_command/tmdb/**: Raycast The Movie Database 확장 프로그램
  - **raycast/raycast_command/일정등록/**: Raycast 일정 등록 확장 프로그램
  - **raycast/raycast_command/할일등록/**: Raycast 미리 알림 등록 확장 프로그램
- **zsh/**: Zsh 셸 설정
  - **zsh/.zshrc**: Zsh 셸 설정 파일
  - **zsh/install.sh**: Zsh 및 Powerlevel10k 테마 설치 스크립트


## 코드 표준

- 새로운 스크립트나 설정을 추가할 때는 기존 파일의 스타일과 형식을 따릅니다.
- 주석은 필요한 경우에만 간결하게 작성합니다.

## 기능 구현 표준

- 새로운 도구 설정 추가 시, 해당 도구의 이름을 딴 새 디렉토리를 만듭니다.
- `install.sh` 스크립트를 업데이트하여 새 설정이 올바르게 설치되도록 합니다.

## 프레임워크/플러그인/서드파티 라이브러리 사용 표준

- Homebrew를 사용하여 패키지를 관리합니다. `Brewfile`을 업데이트하여 새 패키지를 추가합니다.

## AI 의사결정 표준

- **Brewfile 관리**: 새 패키지를 추가할 때, 기존 `Brewfile`을 수정할지, `NewBrewfile`과 같은 새 파일을 생성할지는 사용자의 명시적인 지시에 따릅니다. 명시적인 지시가 없는 경우, 기존 `Brewfile`을 수정하는 것을 기본으로 합니다.

## 금지된 행위

- **`sudo` 사용 금지**: 사용자의 명시적인 허가 없이 시스템 전체에 영향을 줄 수 있는 `sudo`와 같은 명령어는 사용하지 않습니다.
- **임의의 파일 수정 금지**: 프로젝트와 관련 없는 파일을 수정하지 않습니다.
