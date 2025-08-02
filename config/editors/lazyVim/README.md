# LazyVim 설정

이 디렉토리는 Neovim용 LazyVim 전용 설정들을 포함합니다.

## 파일 구조
- `lua/` - LazyVim 설정 파일들
- `plugins/` - 사용자 정의 플러그인 설정
- `config/` - 추가 설정 파일들

## 설치 및 설정
LazyVim 설정은 메인 init.vim 파일에 의해 자동으로 로드됩니다.

## 사용법
1. Neovim 실행 후 `:Lazy` 명령어로 플러그인 관리자 열기
2. `:LazyHealth` 명령어로 LazyVim 상태 확인
3. 필요에 따라 `plugins/` 디렉토리에 개인 플러그인 설정 추가

## 참고 문서
자세한 정보는 공식 문서를 참조하세요: https://www.lazyvim.org/