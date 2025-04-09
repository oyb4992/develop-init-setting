" init.vim - Neovim 설정 파일 for VSCode

" ** 1. 플러그인 관리 최적화 **
" ----------------------------------
" vim-plug 플러그인 매니저 설정 (없는 경우 자동 설치)
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" 플러그인 섹션. 최초 설정시 :PlugInstall로 플러그인 설치 필요.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
  " IdeaVim에서 가져온 플러그인들
  " 기능별 그룹화 제안
  " 1. 코어 기능
  Plug 'tpope/vim-surround'    " 텍스트 감싸기
  Plug 'tpope/vim-commentary'  " 주석 처리
  
  " 2. 시각적 향상
  Plug 'machakann/vim-highlightedyank'  " 복사 하이라이트
  Plug 'unblevable/quick-scope'         " f/F/t/T 강조
  
  " 3. 이동 관련
  Plug 'phaazon/hop.nvim'       " 점프 이동
  
  " 4. 검색 도구
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  
  " 5. VSCode 제외 플러그인
  if !exists('g:vscode')
    Plug 'liuchengxu/vim-which-key'  " 키 맵핑 도우미
  endif
call plug#end()

" ** 2. 환경별 설정 그룹화 **
" ----------------------------------
let g:mapleader = "\<Space>"
if exists('g:vscode')
  let g:loaded_which_key = 1
  if has('win32') || has('win64')
    source $LOCALAPPDATA/nvim/vscode-integration.vim
  elseif has('macunix')
    source $HOME/.config/nvim/vscode-integration.vim
  elseif has('unix') " Linux 등 다른 Unix 계열
    source $HOME/.config/nvim/vscode-integration.vim " 또는 다른 경로
  endif
else
  " Native Neovim 설정
" ** 3. Which-Key 완전 분리 **
  nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
  vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
  
  " which-key 그룹 정의
  let g:which_key_map = {
  \ 'r': 'Format document',
  \ 't': {
  \   'name': '+tabs',
  \   'x': 'Close tab',
  \   'a': 'Close all tabs',
  \   'o': 'Close others',
  \   ']': 'Next tab',
  \   '[': 'Previous tab',
  \   'u': 'Close unmodified'
  \ },
  \ 'd': {
  \   'name': '+debug',
  \   'd': 'Start debugging',
  \   's': 'Stop debugging',
  \   'b': 'Toggle breakpoint'
  \ },
  \ ',': 'Quick open',
  \ 'e': 'Show explorer',
  \ 'E': 'Reveal in explorer',
  \ '-': 'Split down',
  \ '<bar>': 'Split right',
  \ 'm': 'Zen mode',
  \ 'g': {
  \   'name': '+goto',
  \   'd': 'Go to definition',
  \   'i': 'Go to implementation',
  \   'u': 'Find references',
  \   'h': 'Show call hierarchy'
  \ },
  \ 'n': 'Add next match',
  \ 'N': 'Select all matches',
  \ 'f': 'Hop char1',
  \ 'F': 'Hop char2',
  \ 'L': 'Hop line',
  \ '/': 'Hop pattern',
  \ 'x': 'Show registers'
  \}
  
  autocmd VimEnter * silent! call which_key#register('<Space>', 'g:which_key_map')
endif

" ** 4. 기본 설정 (Basic Settings) **
" ----------------------------------
set lazyredraw     " 화면 리프레시 최적화
set timeoutlen=300 " 키 입력 대기 시간 단축
" Syntax highlighting
syntax enable
filetype plugin on
filetype indent on
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
set scrolloff=8
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
" 소프트 탭 설정 (IdeaVim과 동일하게)
set softtabstop=4

" ** 5. 검색 설정 (Search Settings) **
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

" ** 6. 플러그인 설정 **
" ----------------------------------
" vim-highlightedyank 설정 (IdeaVim과 동일하게)
let g:highlightedyank_highlight_duration = 200

" QuickScope 설정
" 이 키를 누를 때만 하이라이트 표시
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
" 첫 번째 문자 하이라이트 색상 (VSCode 호환성 향상)
highlight QuickScopePrimary guifg='#ff0000' gui=underline ctermfg=155 cterm=underline
" 두 번째 문자 하이라이트 색상 (VSCode 호환성 향상)
highlight QuickScopeSecondary guifg='#00ff00' gui=underline ctermfg=81 cterm=underline
" 차이점 편집기에서 강조 표시 제거
let g:qs_disable_for_diffs = 1

" Hop 설정
" Hop 초기화
lua << EOF
require('hop').setup({
  keys = 'etovxqpdygfblzhckisuran',
  jump_on_sole_occurrence = true,
  case_insensitive = true,
  multi_windows = false,
  uppercase_labels = true, 
  trace_target = true       
})
EOF

" vim-highlightedyank 설정
let g:highlightedyank_highlight_duration = 200

" --- fzf 및 외부 도구 연동 설정 ---
" fzf 레이아웃 설정 (선택 사항, 예: 팝업 창 사용)
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

" :Files 명령에 fd 사용 (숨김 파일 및 .gitignore 포함)
" 실행 파일이 있는지 확인 후 설정
if executable('fd')
  let g:fzf_files_command = 'fd --type f --hidden --follow --exclude .git'
endif

" :Rg 또는 :Grep 명령에 ripgrep (rg) 사용
" fzf.vim은 rg가 있으면 자동으로 :Rg 명령을 제공합니다.
" 기본 Grep 명령도 rg를 사용하도록 설정 (선택 사항)
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
  set grepformat=%f:%l:%c:%m
endif

" fzf 미리보기 창에 bat 사용 (구문 강조)
" 실행 파일이 있는지 확인 후 설정
if executable('bat')
  " fzf.vim은 종종 자동으로 bat을 감지하지만, 명시적으로 설정할 수도 있습니다.
  " :Rg 등 fzf.vim 명령의 미리보기 창에서 사용됩니다.
  let g:fzf_preview_command = 'bat --style=numbers,changes --color=always {-1} --theme=OneHalfDark'
  " 또는 FZF_DEFAULT_OPTS 환경 변수를 쉘 설정(.zshrc, .bashrc)에서 설정하는 방법도 있습니다:
  " export FZF_DEFAULT_OPTS='--preview "bat --style=numbers,changes --color=always {}"'
endif

" 커스텀 키 매핑
nnoremap j gj
nnoremap k gk
nnoremap H ^
nnoremap L $
nnoremap <leader>f :HopChar1<CR>
nnoremap <leader>F :HopChar2<CR>
nnoremap <leader>L :HopLine<CR>
" 정규식으로 검색
nnoremap <leader>/ :HopPattern<CR>

" ** 7. 레지스터 확인 **
" ----------------------------------
" 레지스터 내용 확인 (필요시 활성화)
nnoremap <leader>x :registers<CR>

" --- fzf 키 매핑 ---
" 파일 검색 (:Files 또는 fd를 사용하도록 설정된 명령)
nnoremap <silent> <leader>p :Files<CR>
" 열려있는 버퍼 검색
nnoremap <silent> <leader>b :Buffers<CR>
" 현재 디렉토리 내용 검색 (ripgrep 사용)
nnoremap <silent> <leader>g :Rg<CR>
" Vim 히스토리 검색
nnoremap <silent> <leader>h :History<CR>
" 현재 버퍼의 라인 검색
nnoremap <silent> <leader>l :Lines<CR>
" --------------------
" ** 8. 북마크 (마크) 설정 (Bookmark/Mark Settings) **
" ----------------------------------
" Vim의 마크 기능을 북마크처럼 사용합니다.
"
" 기본 사용법:
"   m{a-z} : 현재 파일 내 위치 저장 (소문자 마크)
"   m{A-Z} : 파일 경로 포함 위치 저장 (대문자/전역 마크)
"   `{a-zA-Z}` : 저장된 정확한 위치(줄, 열)로 이동
"   '{a-zA-Z} : 저장된 줄의 첫 글자로 이동
"   :marks   : 저장된 마크 목록 보기
"   :delmarks {marks} : 특정 마크 삭제 (예: :delmarks a b C)
"   :delmarks a-z A-Z : 모든 마크 삭제

" <leader>M : 마크 목록 보기 (View Marks)
nnoremap <silent> <leader>M :marks<CR>