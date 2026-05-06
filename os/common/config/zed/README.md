# Zed Vim 설정

이 디렉토리는 `os/common/config/editors/lazyVim/.idea-lazy.vim`의 IdeaVim/LazyVim 스타일을 Zed용으로 옮긴 설정을 포함합니다.

## 파일

- `settings.json`: Zed Vim mode 활성화, JetBrains base keymap, 줄 번호/스크롤/검색/클립보드 설정
- `keymap.json`: Zed action 기반 LazyVim 리더 키 매핑

## 설치

공통 설치 스크립트가 다음 위치로 심볼릭 링크를 만듭니다.

```bash
~/.config/zed/settings.json
~/.config/zed/keymap.json
```

수동으로 적용하려면 다음을 실행하세요.

```bash
mkdir -p ~/.config/zed
ln -sf "$PWD/os/common/config/zed/settings.json" ~/.config/zed/settings.json
ln -sf "$PWD/os/common/config/zed/keymap.json" ~/.config/zed/keymap.json
```

## 포팅 기준

Zed는 `.vimrc`나 IdeaVim의 `<Action>(...)` 문법을 직접 읽지 않습니다. 따라서 공통 Vim 옵션은 `settings.json`으로, IDE 동작은 Zed의 `keymap.json` action 이름으로 변환했습니다.

Zed Vim mode가 이미 제공하는 기능은 기본 동작을 우선 사용합니다.

- surround: `ys`, `cs`, `ds`
- comment: `gcc`, visual `gc`
- LSP 이동: `gd`, `gD`, `gy`, `gI`
- diagnostics: `]d`, `[d`
- multiple cursor: Zed 선택/멀티커서 action
- anyobject/mini.ai 계열: `q`, `b`, `Q`, `B` text object로 연결

## 제한

IdeaVim 전용 플러그인과 JetBrains 전용 액션은 Zed에 같은 기능이 없으면 가장 가까운 Zed action으로 매핑했습니다. 예를 들어 `DialIncrement`, JetBrains tool window layout, 일부 DAP/test runner 세부 동작, Which-Key 설명 변수는 그대로 재현할 수 없습니다.
