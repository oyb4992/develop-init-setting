# BetterTouchTool 워크플로우

이 디렉토리는 BetterTouchTool 관련 설정을 보관하기 위한 자리입니다.

현재 repo에는 실제 `.bttpreset` 파일이 없고 README만 있습니다. 워크플로우를 repo로 관리하려면 BetterTouchTool에서 preset을 export한 뒤 이 디렉토리에 추가합니다.

## 관리 기준

- 공유 가능한 preset만 commit합니다.
- 개인 앱 경로, 계정, 민감한 스크립트 값이 들어 있으면 commit 전에 제거합니다.
- macOS가 만든 `.DS_Store`는 commit하지 않습니다.

## 가져오기

BetterTouchTool에서 preset을 export/import해 관리합니다. 새 preset을 추가한 뒤에는 충돌하는 단축키나 제스처가 없는지 확인합니다.
