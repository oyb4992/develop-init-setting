" init.vim - Neovim 설정 파일 for VSCode

" 1. 플러그인 관리 및 설치
let s:is_nvim = has('nvim')
let s:data_dir = s:is_nvim ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(s:data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.s:data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(s:is_nvim ? stdpath('data') . '/plugged' : '~/.vim/plugged')
  " 시각적 향상
  Plug 'machakann/vim-highlightedyank'
  Plug 'unblevable/quick-scope'
  " 이동 관련
  Plug 'phaazon/hop.nvim'
  Plug 'echasnovski/mini.nvim'
  " 날짜/시간 증감
  Plug 'tpope/vim-speeddating'
  " 반복 동작 강화
  Plug 'tpope/vim-repeat'
call plug#end()

" 2. 환경별 설정
let g:mapleader = "\<Space>"
let g:loaded_which_key = 1
source ~/Project/develop-init-setting/vscode-integration.vim

" 3. 기본 설정
set lazyredraw
set timeoutlen=300
syntax enable
filetype plugin on
filetype indent on
set incsearch
set hlsearch
set clipboard+=unnamed
set number
set relativenumber
set scrolloff=8
set sidescrolloff=8
set nowrap
set backspace=indent,eol,start
set formatoptions=tcqjro
set listchars=tab:>\ ,trail:-,nbsp:+
map Q gq
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" 4. 검색 설정
set ignorecase
set smartcase
set visualbell

" 5. 플러그인별 상세 설정
let g:highlightedyank_highlight_duration = 200
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
highlight QuickScopePrimary guifg='#ff0000' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#00ff00' gui=underline ctermfg=81 cterm=underline
let g:qs_disable_for_diffs = 1

lua << EOF
require('hop').setup({
  keys = 'etovxqpdygfblzhckisuran',
  jump_on_sole_occurrence = true,
  case_insensitive = true,
  multi_windows = false,
  uppercase_labels = true,
  trace_target = true
})
require('mini.comment').setup()
require('mini.surround').setup()
require('mini.ai').setup()
require('mini.align').setup()
EOF

" 6. 커스텀 키 매핑
nnoremap j gj
nnoremap k gk
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $
nnoremap <leader>f :HopChar1<CR>
nnoremap <leader>F :HopChar2<CR>
nnoremap <leader>L :HopLine<CR>
nnoremap <leader>/ :HopPattern<CR>
nnoremap <leader>x :registers<CR>
nnoremap <silent> <leader>M :marks<CR>

" vim-speeddating: 기본 키(<C-a>, <C-x>)로 날짜/시간 증감 지원

" vim-repeat: 플러그인 동작 반복 지원 (별도 설정 불필요)