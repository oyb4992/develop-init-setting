# LazyVim 스타일 IdeaVim 설정

JetBrains IDE에서 LazyVim 스타일 키를 쓰기 위한 IdeaVim 설정입니다.

| 파일 | 대상 |
| --- | --- |
| `.idea-lazy.vim` | `~/.ideavimrc` 진입점. `&ide`로 IDE를 구분해 아래 파일을 읽습니다. |
| `common.vim` | 세 IDE의 공통 옵션과 키 매핑 |
| `intellij.vim` | IntelliJ IDEA 2026.2.3, IdeaVim 2.47.1 |
| `webstorm.vim` | WebStorm 2025.1.7.2, IdeaVim 2.27.1 |
| `datagrip.vim` | DataGrip 2025.1.7.2, IdeaVim 2.27.1 |

공통 설치기는 진입점을 `~/.ideavimrc`와 `~/.idea-lazy.vim`에 연결하고, 나머지 파일을 `~/.config/ideavim/`에 연결합니다. 수동 설치 시에도 이 경로에 파일을 두어야 `source`가 작동합니다. IDE에서 `:echo &ide`로 인식된 제품명을 확인하고 `:source ~/.ideavimrc`로 다시 읽을 수 있습니다.

IntelliJ 설정의 `inccommand`, `indentwise`, `abolish`는 최신 IdeaVim에서만 활성화합니다. WebStorm과 DataGrip은 2.27.1에 없는 기능 대신 StringManipulation 플러그인의 case 변환 액션을 사용합니다.

공통 설정의 Which-Key, Vim Flash, Vim AnyObject, Vim Dial, Vim Peekaboo는 각 IDE에 별도로 설치해야 합니다. WebStorm과 DataGrip에는 StringManipulation, IntelliJ의 `VimEverywhere`에는 AceJump가 필요합니다. 제품별 액션은 설치된 IDE 플러그인과 실행 문맥에 따라 사용 가능 여부가 달라질 수 있습니다.

`<leader>gg`와 `<leader>gG`는 Lazygit 플러그인이 필요합니다. `<leader>tr`와 `<leader>tt`의 `RunClass`는 이름과 달리 현재 위치의 실행 구성을 찾는 액션이므로, 해당 파일에 실행 구성이 있을 때만 동작합니다. 원본 파일의 `ShowTestSummary`, `RunAllTests`, `ToggleTestWatch` 매핑은 세 IDE에서 확인된 액션 ID가 없어 제외했습니다.

DataGrip에는 Java 디버그·테스트, ESLint, 구현/타입 정의 이동 매핑을 넣지 않았습니다. SQL과 공통 편집 기능의 액션은 `common.vim`에 남겼습니다.

IDE에서 액션 ID를 검증하려면 `:actionlist {ID}`를 실행하거나 **IdeaVim: Track Action IDs**를 켜고 해당 메뉴를 실행하세요. 설정을 다시 읽은 뒤 실제 키 동작까지 확인해야 합니다.

Zed는 Vimscript를 읽지 않으므로 `os/common/config/zed/`에 별도 설정을 둡니다.
