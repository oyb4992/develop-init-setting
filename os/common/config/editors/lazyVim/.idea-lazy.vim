" IdeaVim entry point. Installed as ~/.ideavimrc and ~/.idea-lazy.vim.
" The common installer links the sourced files under ~/.config/ideavim/.
source ~/.config/ideavim/common.vim

if &ide =~? 'intellij idea'
  source ~/.config/ideavim/intellij.vim
elseif &ide =~? 'webstorm'
  source ~/.config/ideavim/webstorm.vim
elseif &ide =~? 'datagrip'
  source ~/.config/ideavim/datagrip.vim
endif
