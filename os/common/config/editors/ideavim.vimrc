" IdeaVim Configuration
" Basic settings
set number
set relativenumber
set ignorecase
set smartcase
set incsearch
set hlsearch

" Key mappings
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Plugin emulation
set surround
set commentary
set multiple-cursors
set argtextobj
set textobj-entire

" IDE specific mappings
map <leader>f <Action>(GotoFile)
map <leader>g <Action>(FindInPath)
map <leader>r <Action>(RenameElement)
map <leader>e <Action>(ShowErrorDescription)