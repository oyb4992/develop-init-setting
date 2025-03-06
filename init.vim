" init.vim - Neovim 설정 파일 for VSCode

" vim-plug 플러그인 매니저 설정 (없는 경우 자동 설치)
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" 플러그인 섹션
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
  " IdeaVim에서 가져온 플러그인들
  Plug 'machakann/vim-highlightedyank'  " 복사한 텍스트 하이라이트
  Plug 'tpope/vim-commentary'           " 주석 처리 기능
  Plug 'tpope/vim-surround'             " 텍스트 둘러싸기 기능
call plug#end()

" ** 1. 기본 설정 (Basic Settings) **
" ----------------------------------
" 점진적 검색 활성화
set incsearch
" 검색어 하이라이트
set hlsearch
" 시스템 클립보드 공유
set clipboard+=unnamed
" 줄 번호 표시
set number
" 상대 줄 번호 표시
set relativenumber
" 하이브리드 라인 넘버 모드 (현재 줄은 절대 번호, 다른 줄은 상대 번호)
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
" 커서 주변 문맥 줄 수 (상하)
set scrolloff=4
" 커서 주변 문맥 열 수 (좌우)
set sidescrolloff=8
" 줄 바꿈 비활성화
set nowrap
" 백스페이스 동작 설정
set backspace=indent,eol,start
" 텍스트 포맷 옵션
set formatoptions=tcqj
" 특수 문자 표시 설정
set listchars=tab:>\ ,trail:-,nbsp:+
" Ex 모드 비활성화, Q를 formatting으로 매핑
map Q gq

" ** 2. 들여쓰기 설정 (Indentation Settings) **
" ----------------------------------
" 자동 들여쓰기
set autoindent
" 스마트 들여쓰기
set smartindent
" 탭 너비: 4칸
set tabstop=4
" 들여쓰기/내어쓰기 단위: 4칸
set shiftwidth=4
" 탭을 스페이스로 치환
set expandtab

" ** 3. 검색 설정 (Search Settings) **
" ----------------------------------
" 검색 시 대소문자 무시
set ignorecase
" 검색 패턴에 대문자 있을 때만 대소문자 구별
set smartcase
" 시각적 벨 효과
set visualbell
" 주석 줄 자동 줄 바꿈
set formatoptions+=r
" 주석 삽입 시 현재 줄과 동일 접두사 사용
set formatoptions+=o

" ** 4. Leader 키 설정 **
" ----------------------------------
let mapleader=" "

" ** 5. VSCode Neovim 통합 키 매핑 **
" ----------------------------------
" 코드 formatting
nnoremap <leader>r <Cmd>call VSCodeCall('editor.action.formatDocument')<CR>

" 탭 관리
nnoremap <leader>tx <Cmd>call VSCodeCall('workbench.action.closeActiveEditor')<CR>
nnoremap <leader>ta <Cmd>call VSCodeCall('workbench.action.closeAllEditors')<CR>
nnoremap <leader>to <Cmd>call VSCodeCall('workbench.action.closeOtherEditors')<CR>
nnoremap <leader>t] <Cmd>call VSCodeCall('workbench.action.nextEditor')<CR>
nnoremap <leader>t[ <Cmd>call VSCodeCall('workbench.action.previousEditor')<CR>
nnoremap <leader>tu <Cmd>call VSCodeCall('workbench.action.closeUnmodifiedEditors')<CR>

" 디버깅
nnoremap <leader>dd <Cmd>call VSCodeCall('workbench.action.debug.start')<CR>
nnoremap <leader>ds <Cmd>call VSCodeCall('workbench.action.debug.stop')<CR>
nnoremap <leader>db <Cmd>call VSCodeCall('editor.debug.action.toggleBreakpoint')<CR>

" 탐색 및 Search
nnoremap <leader>, <Cmd>call VSCodeCall('workbench.action.quickOpen')<CR>
nnoremap <leader>e <Cmd>call VSCodeCall('workbench.view.explorer')<CR>
nnoremap <leader>E <Cmd>call VSCodeCall('workbench.files.action.showActiveFileInExplorer')<CR>

" 창 분할 및 최대화
nnoremap <leader>- <Cmd>call VSCodeCall('workbench.action.splitEditorDown')<CR>
nnoremap <leader><bar> <Cmd>call VSCodeCall('workbench.action.splitEditorRight')<CR>
nnoremap <leader>m <Cmd>call VSCodeCall('workbench.action.toggleZenMode')<CR>

" 코드 탐색 (Go To...)
nnoremap <leader>gd <Cmd>call VSCodeCall('editor.action.revealDefinition')<CR>
nnoremap <leader>gi <Cmd>call VSCodeCall('editor.action.goToImplementation')<CR>
nnoremap <leader>gu <Cmd>call VSCodeCall('editor.action.referenceSearch.trigger')<CR>
nnoremap <leader>th <Cmd>call VSCodeCall('editor.showCallHierarchy')<CR>
nnoremap <leader>rn <Cmd>call VSCodeCall('editor.action.rename')<CR>

" ** 6. 일반 기능 키 매핑 (General Key Mappings) **
" ----------------------------------
" 창 이동
nnoremap <C-h> <Cmd>call VSCodeCall('workbench.action.navigateLeft')<CR>
nnoremap <C-l> <Cmd>call VSCodeCall('workbench.action.navigateRight')<CR>
nnoremap <C-k> <Cmd>call VSCodeCall('workbench.action.navigateUp')<CR>
nnoremap <C-j> <Cmd>call VSCodeCall('workbench.action.navigateDown')<CR>

" 줄 이동: 키 충돌로 인해 leader키와 설정
nnoremap <leader>j  <Cmd>call VSCodeCall('editor.action.moveLinesDownAction')<CR>
inoremap <leader>j  <Cmd>call VSCodeCall('editor.action.moveLinesDownAction')<CR>
vnoremap <leader>j  <Cmd>call VSCodeCall('editor.action.moveLinesDownAction')<CR>
nnoremap <leader>k  <Cmd>call VSCodeCall('editor.action.moveLinesUpAction')<CR>
inoremap <leader>k  <Cmd>call VSCodeCall('editor.action.moveLinesUpAction')<CR>
vnoremap <leader>k  <Cmd>call VSCodeCall('editor.action.moveLinesUpAction')<CR>

" ** 7. 추가 VSCode 통합 기능 **
" ----------------------------------
" 다중 커서 기능 (VSCode 내장 기능 사용)
nnoremap <C-n> <Cmd>call VSCodeCall('editor.action.addSelectionToNextFindMatch')<CR>
xnoremap <C-n> <Cmd>call VSCodeCall('editor.action.addSelectionToNextFindMatch')<CR>
nnoremap <leader><C-n> <Cmd>call VSCodeCall('editor.action.selectHighlights')<CR>
xnoremap <leader><C-n> <Cmd>call VSCodeCall('editor.action.selectHighlights')<CR>

" ** 8. 레지스터 확인 **
" ----------------------------------
" 레지스터 내용 확인 (필요시 활성화)
" nnoremap <leader>x :registers<CR>