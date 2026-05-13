# LazyVim 스타일 IdeaVim 설정

이 디렉토리는 Neovim LazyVim 자체 설정이 아니라, LazyVim에서 쓰는 조작감을 JetBrains IdeaVim 쪽으로 맞추기 위한 설정을 보관합니다.

## 파일

- `.idea-lazy.vim`: JetBrains IDE에서 사용할 IdeaVim 설정

## 사용 방법

JetBrains IDE의 IdeaVim 설정에서 이 파일을 참조하거나, 개인 `~/.ideavimrc`에서 source해서 사용합니다.

```vim
source /Users/oyunbog/IdeaProjects/dev-init-setting/os/common/config/editors/lazyVim/.idea-lazy.vim
```

## 참고

Zed는 Vimscript를 직접 읽지 않으므로 `os/common/config/zed/`에 별도 `settings.json`, `keymap.json`으로 포팅한 설정을 둡니다.
