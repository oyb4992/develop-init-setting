  " ** 5. VSCode Neovim 통합 키 매핑 **
  " ----------------------------------
  " 코드 formatting (변경)
  nnoremap <leader>r <Cmd>call VSCodeNotify('editor.action.formatDocument')<CR>

  " 탭 관리 (전체 변경)
  nnoremap <leader>tx <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
  nnoremap <leader>ta <Cmd>call VSCodeNotify('workbench.action.closeAllEditors')<CR>
  nnoremap <leader>to <Cmd>call VSCodeNotify('workbench.action.closeOtherEditors')<CR>
  nnoremap <leader>t] <Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>
  nnoremap <leader>t[ <Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>
  nnoremap <leader>tu <Cmd>call VSCodeNotify('workbench.action.closeUnmodifiedEditors')<CR>

  " 디버깅 (전체 변경)
  nnoremap <leader>dd <Cmd>call VSCodeNotify('workbench.action.debug.start')<CR>
  nnoremap <leader>ds <Cmd>call VSCodeNotify('workbench.action.debug.stop')<CR>
  nnoremap <leader>db <Cmd>call VSCodeNotify('editor.debug.action.toggleBreakpoint')<CR>

  " 탐색 및 Search (전체 변경)
  nnoremap <leader>, <Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>
  nnoremap <leader>e <Cmd>call VSCodeNotify('workbench.view.explorer')<CR>
  nnoremap <leader>E <Cmd>call VSCodeNotify('workbench.files.action.showActiveFileInExplorer')<CR>

  " 창 분할 및 최대화 (전체 변경)
  nnoremap <leader>- <Cmd>call VSCodeNotify('workbench.action.splitEditorDown')<CR>
  nnoremap <leader><bar> <Cmd>call VSCodeNotify('workbench.action.splitEditorRight')<CR>
  nnoremap <leader>m <Cmd>call VSCodeNotify('workbench.action.toggleZenMode')<CR>

  " 코드 탐색 (전체 변경)
  nnoremap <leader>gd <Cmd>call VSCodeNotify('editor.action.revealDefinition')<CR>
  nnoremap <leader>gi <Cmd>call VSCodeNotify('editor.action.goToImplementation')<CR>
  nnoremap <leader>gu <Cmd>call VSCodeNotify('editor.action.referenceSearch.trigger')<CR>
  nnoremap <leader>gh <Cmd>call VSCodeNotify('editor.showCallHierarchy')<CR>

  " ** 6. 일반 기능 키 매핑 (전체 변경) **
  " ----------------------------------
  " 창 이동
  nnoremap <C-h> <Cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>
  nnoremap <C-l> <Cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>
  nnoremap <C-k> <Cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>
  nnoremap <C-j> <Cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>

  " 줄 이동 (변경)
  nnoremap <C-S-j> <Cmd>call VSCodeNotify('editor.action.moveLinesDownAction')<CR>
  inoremap <C-S-j> <Cmd>call VSCodeNotify('editor.action.moveLinesDownAction')<CR>
  vnoremap <C-S-j> <Cmd>call VSCodeNotify('editor.action.moveLinesDownAction')<CR>
  nnoremap <C-S-k> <Cmd>call VSCodeNotify('editor.action.moveLinesUpAction')<CR>
  inoremap <C-S-k> <Cmd>call VSCodeNotify('editor.action.moveLinesUpAction')<CR>
  vnoremap <C-S-k> <Cmd>call VSCodeNotify('editor.action.moveLinesUpAction')<CR>

  " ** 7. 추가 VSCode 통합 기능 (변경) **
  " ----------------------------------
  " 다중 커서 기능
  nnoremap <leader>n <Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>
  xnoremap <leader>n <Cmd>call VSCodeNotify('editor.action.addSelectionToNextFindMatch')<CR>
  nnoremap <leader>N <Cmd>call VSCodeNotify('editor.action.selectHighlights')<CR>
  xnoremap <leader>N <Cmd>call VSCodeNotify('editor.action.selectHighlights')<CR>
  
  nnoremap <leader>gl <Cmd>call VSCodeNotify('gitlens.views.fileHistory.focus')<CR>
