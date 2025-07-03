" ~/.idea-lazy.vim

" Jetbrains IDE용 LazyVim 매핑

" 필수 플러그인. https://plugins.jetbrains.com/bundles/7-ideavim-bundle
"  IDEAVim
"  Which-Key

" 설치하려면 ~/.ideavimrc 상단에 다음을 추가하세요:
" source ~/.idea-lazy.vim

" 이 파일은 다음 위치에 호스팅됩니다:
" https://gist.github.com/mikeslattery/d2f2562e5bbaa7ef036cf9f5a13deff5

" 초보자는 기본 매핑을 배우려면 다음을 실행하세요:
" nvim --clean +Tutor

" 유용한 Jetbrains 도구 창 매핑:
" <esc>       편집기로 돌아가기
" <S-esc>     도구 창 숨기기
" <F12>       도구 창으로 이동
" <C-S-quote> 도구 창 최대화/복원 토글
" <C-M-y>     파일 다시 로드. Neovim 또는 CL에서 편집한 후 유용합니다.
" <M-left>    이전 탭
" <M-right>   다음 탭
" <C-F4>      탭 닫기
" <M-3>       찾기 도구 창 활성화
" <M-6>       문제 보기 도구 창 활성화
" <c-s-a>     액션 찾기

" LazyVim의 Java 추가 기능: https://www.lazyvim.org/extras/lang/java

" LazyVim 기본 설정
" https://www.lazyvim.org/configuration/general
let mapleader=" "
let maplocalleader="\\"

set clipboard+=ideaput,unnamed
" 줄 번호 표시
set number
" 상대 줄 번호
set relativenumber
" 문맥 줄 수
set scrolloff=4
" " 반올림 들여쓰기
" set shiftround
" 문맥 열 수
set sidescrolloff=8
" which-key에서는 높게 설정하거나 notimeout을 설정하라고 합니다.
set notimeout
" 줄 바꿈 비활성화
set nowrap

" 커서를 줄 끝 다음 칸까지 이동 허용
set virtualedit=onemore
set incsearch
set hls
set ignorecase
set smartcase
set ideajoin
set idearefactormode=keep
set list
set showcmd
set showmode
set history=1000
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
set colorcolumn=80
set cursorline
set breakindent
set wrap

" Vim과 다른 Neovim 설정
" https://neovim.io/doc/user/diff.html
" https://github.com/mikeslattery/nvim-defaults.vim/blob/main/plugin/.vimrc

" set backspace=indent,eol,start
" set formatoptions=tcqj
" set listchars=tab:>\ ,trail:-,nbsp:+
" set shortmess=filnxtToOF

" 플러그인 동작 활성화

" https://github.com/JetBrains/ideavim/wiki/IdeaVim-Plugins
" https://www.lazyvim.org/plugins

set commentary
" s 액션, 예: cs"' ("를 '로 바꾸기), ds" (따옴표 제거)
set surround
" flash.nvim과 유사
set easymotion
" Jetbrains 마켓플레이스에서 사용 가능한 whichkey 플러그인 활성화
set which-key
set matchit
set highlightedyank
set multiple-cursors
set peekaboo
set mini-ai
set quickscope
set vim-paragraph-motion
set textobj-entire
set functiontextobj
set argtextobj

let g:highlightedyank_highlight_duration = 200

let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
let g:qs_primary_color = '#ff0000'
let g:qs_secondary_color = '#00ff00'
let g:qs_disable_for_diffs = 1

let g:EasyMotion_smartcase = 1
let g:EasyMotion_do_mapping = 1
let g:EasyMotion_startofline = 0
let g:EasyMotion_verbose = 0

" 키 매핑

" https://www.lazyvim.org/configuration/keymaps

" 액션 ID를 추적하려면
" :action VimFindActionIdAction

" 일반 키 매핑

" 왼쪽 창으로 이동
nmap <C-h> <C-w>h
" 아래쪽 창으로 이동
nmap <C-j> <C-w>j
" 위쪽 창으로 이동
nmap <C-k> <C-w>k
" 오른쪽 창으로 이동
nmap <C-l> <C-w>l
" 창 높이 늘리기
nmap <C-Up> <Action>(IncrementWindowHeight)
" 창 높이 줄이기
nmap <C-Down> <Action>(DecrementWindowHeight)
" 창 너비 줄이기
nmap <C-Left> <Action>(DecrementWindowWidth)
" 창 너비 늘리기
nmap <C-Right> <Action>(IncrementWindowWidth)
" 아래로 이동
" nmap <A-j> <Action>(MoveLineDown)
" imap <A-j> <Esc><Action>(MoveLineDown)i
" vmap <A-j> <Action>(MoveLineDown)
vmap <S-j> <Action>(MoveLineDown)
" 위로 이동
" nmap <A-k> <Action>(MoveLineUp)
" imap <A-k> <Esc><Action>(MoveLineUp)i
" vmap <A-k> <Action>(MoveLineUp)
vmap <S-k> <Action>(MoveLineUp)
" 이전 버퍼
nmap <S-h> <Action>(PreviousTab)
" 다음 버퍼
nmap <S-l> <Action>(NextTab)
" 이전 버퍼 (대안)
nmap [b <Action>(PreviousTab)
" 다음 버퍼 (대안)
nmap ]b <Action>(NextTab)
" 다른 버퍼로 전환
nnoremap <leader>bb <C-^>
" 다른 버퍼로 전환 (대안)
nnoremap <leader>` <C-^>
" 버퍼 삭제
nmap <leader>bd <Action>(CloseContent)
" 버퍼 및 창 삭제
nmap <leader>bD <Action>(CloseContent)
" 다른 버퍼 삭제
nmap <leader>bo <Action>(CloseAllEditorsButActive)
" 수정하지 않은 버퍼 삭제
nmap <leader>bu <Action>(CloseAllUnmodifiedEditors)
" 모든 버퍼 삭제 
nmap <leader>ba <Action>(CloseAllEditors)
" 분할 창 이동
nmap <leader>bm <Action>(MoveEditorToOppositeTabGroup)
" IntelliJ 액션 'Change Splitter Orientation' 호출
nmap <leader>bc <Action>(ChangeSplitOrientation)
" Escape 및 hlsearch 지우기
nmap <esc> :nohlsearch<CR>
nmap <leader>ur :nohlsearch<CR>
" Keywordprg
nmap <leader>K :help<space><C-r><C-w><CR>
" 아래에 주석 추가
nmap gco o<c-o>gcc
" 위에 주석 추가
nmap gcO O<c-o>gcc
" Lazy
nmap <leader>l <Action>(WelcomeScreen.Plugins)
" 새 파일
nmap <leader>fn Action(NewElementSamePlace)
" 위치 목록
nmap <leader>xl <Action>(ActivateProblemsViewToolWindow)
" 빠른 수정 목록
nmap <leader>xq <Action>(ActivateProblemsViewToolWindow)
" 이전 빠른 수정
nmap [q <Action>(GotoPreviousError)
" 다음 빠른 수정
nmap ]q <Action>(GotoNextError)
" 포맷
nmap <leader>cf <Action>(ReformatCode)
vmap <leader>cf <Action>(ReformatCode)
" 줄 진단
nmap <leader>cd <Action>(ActivateProblemsViewToolWindow)
" 다음 진단
nmap ]d <Action>(GotoNextError)
" 이전 진단
nmap [d <Action>(GotoPreviousError)
" 다음 오류
nmap ]e <Action>(GotoNextError)
" 이전 오류
nmap [e <Action>(GotoPreviousError)
" 다음 경고
nmap ]w <Action>(GotoNextError)
" 이전 경고
nmap [w <Action>(GotoPreviousError)
" 자동 포맷 토글 (전역)
" nmap <leader>ub :echo '자동 포맷 토글에 해당하는 매핑이 없습니다.'<cr>
" 자동 포맷 토글 (버퍼)
" nmap <leader>uB :echo '자동 포맷 토글에 해당하는 매핑이 없습니다.'<cr>
" 맞춤법 검사 토글
nmap <leader>us :setlocal spell!<CR>
" 줄 바꿈 토글
nmap <leader>uw :setlocal wrap!<CR>
" 상대 줄 번호 토글
nmap <leader>uL :set relativenumber!<CR>
" 진단 토글
nmap <leader>ud <Action>(ActivateProblemsViewToolWindow)
" 줄 번호 토글
nmap <leader>ul :set number!<CR>
" conceallevel 토글
" nmap <leader>uc :echo 'Conceallevel 토글에 해당하는 매핑이 없습니다.'<cr>
" Treesitter 강조 토글
" nmap <leader>uT :echo 'Treesitter 강조 토글에 해당하는 매핑이 없습니다.'<cr>
" 배경 토글
nmap <leader>ub <Action>(QuickChangeScheme)
" 인레이 힌트 토글
" nmap <leader>uh :echo '인레이 힌트 토글에 해당하는 매핑이 없습니다.'<cr>
" Lazygit (루트 디렉토리)
nmap <leader>gg <Action>(ActivateCommitToolWindow)
" Lazygit (현재 작업 디렉토리)
nmap <leader>gG <Action>(ActivateCommitToolWindow)
" Git Blame 줄
nmap <leader>gb <Action>(Annotate)
" Git Browse
nmap <leader>gB <Action>(Vcs.Show.Log)
" Lazygit 현재 파일 기록
nmap <leader>gf <Action>(Vcs.ShowTabbedFileHistory)
" Lazygit 로그
nmap <leader>gl <Action>(Vcs.Show.Log)
" Lazygit 로그 (현재 작업 디렉토리)
nmap <leader>gL <Action>(Vcs.Show.Log)
" 모두 종료
nmap <leader>qq <Action>(Exit)
" 위치 검사
nmap <leader>ui <Action>(ActivateStructureToolWindow)
" 트리 검사
nmap <leader>uI <Action>(ActivateStructureToolWindow)
" LazyVim 변경 로그
nmap <leader>L <Action>(WhatsNewAction)
" 터미널 (루트 디렉토리)
nmap <leader>ft <Action>(ActivateTerminalToolWindow)
" 터미널 (현재 작업 디렉토리)
nmap <leader>fT <Action>(ActivateTerminalToolWindow)
" 터미널 (루트 디렉토리)
nmap <C-/> <Action>(ActivateTerminalToolWindow)
" nmap <C-_> ' <c-_>에 해당하는 매핑이 없습니다.'<cr>
" 터미널 숨기기 - 터미널 모드 매핑 불가능
" 아래에 창 분할. :split<cr>은 작동하지 않습니다.
nmap <leader>- <c-w>s
" 오른쪽에 창 분할
nmap <leader><bar> <c-w>v
" 창 삭제
nmap <leader>wd <Action>(CloseContent)
" 최대화 토글
nmap <leader>wm <Action>(ToggleDistractionFreeMode)

" 탭은 저장된 레이아웃으로 처리됩니다.

" 마지막 탭
nmap <leader><tab>l <Action>(StoreDefaultLayout)<Action>(ChangeToolWindowLayout)
" 다른 탭 닫기
nmap <leader><tab>o :<cr>
" 첫 번째 탭
nmap <leader><tab>f <Action>(StoreDefaultLayout)<Action>(ChangeToolWindowLayout)
" 새 탭
nmap <leader><tab>n <Action>(StoreDefaultLayout)<Action>(StoreNewLayout)
" 다음 탭
nmap <leader><tab>] <Action>(StoreDefaultLayout)<Action>(ChangeToolWindowLayout)
" 이전 탭
nmap <leader><tab>[ <Action>(StoreDefaultLayout)<Action>(ChangeToolWindowLayout)
" 탭 닫기
nmap <leader><tab>c <Action>(StoreDefaultLayout)<Action>(ChangeToolWindowLayout)

" LSP 키 매핑

" Lsp 정보
" nmap <leader>cc :echo 'Lsp 정보에 해당하는 매핑이 없습니다.'<cr>
" 정의로 이동
nmap gd <Action>(GotoDeclaration)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 참조
nmap gR <Action>(FindUsages)
" 사용으로 바로 이동
nmap gU <Action>(ShowUsages)
" 구현으로 이동
nmap gI <Action>(GotoImplementation)
" 타입 정의로 이동
nmap gy <Action>(GotoTypeDeclaration)
" 선언으로 이동
nmap gD <Action>(GotoDeclaration)
" 시그니처 도움말
nmap gK <Action>(ParameterInfo)
" 삽입 모드에서 시그니처 도움말
imap <C-k> <C-o><Action>(ParameterInfo)
" 코드 액션
nmap <leader>ca <Action>(RefactoringMenu)
vmap <leader>ca <Action>(RefactoringMenu)
" Codelens 실행
" nmap <leader>cc :echo 'Codelens 실행에 해당하는 매핑이 없습니다.'<cr>
" Codelens 새로 고침 및 표시
" nmap <leader>cC :echo 'Codelens 새로 고침 및 표시에 해당하는 매핑이 없습니다.'<cr>
" 파일 이름 바꾸기
nmap <leader>cR <Action>(RenameFile)
" 이름 바꾸기
nmap <leader>cr <Action>(RenameElement)
" 소스 액션
nmap <leader>cA <Action>(ShowIntentionActions)
" 다음 참조
nmap ]] <Action>(GotoNextError)
" 이전 참조
nmap [[ <Action>(GotoPreviousError)
" 다음 참조 (대안)
nmap <a-n> <Action>(GotoNextError)
" 이전 참조 (대안)
nmap <a-p> <Action>(GotoPreviousError)

" Bufferline

" 왼쪽 버퍼 삭제
nmap <leader>bl <Action>(CloseAllToTheLeft)
" 핀 토글
nmap <leader>bp <Action>(PinActiveTabToggle)
" 고정되지 않은 버퍼 삭제
nmap <leader>bP <Action>(CloseAllUnpinnedEditors)
" 오른쪽 버퍼 삭제
nmap <leader>br <Action>(CloseAllToTheRight)

" Neo-tree 키 매핑

" 버퍼 탐색기
nmap <leader>be <Action>(ActivateProjectToolWindow)
" 탐색기 NeoTree (루트 디렉토리)
nmap <leader>e <Action>(FileStructurePopup)
" 탐색기 NeoTree (현재 작업 디렉토리)
nmap <leader>E <Action>(SelectInProjectView)
" 탐색기 NeoTree (루트 디렉토리) (대안)
nmap <leader>fe <Action>(ActivateProjectToolWindow)
" 탐색기 NeoTree (현재 작업 디렉토리) (대안)
nmap <leader>fE <Action>(ActivateProjectToolWindow)
" Git 탐색기
nmap <leader>ge <Action>(ActivateVersionControlToolWindow)

" 알림 (noice, snacks)

nmap <leader>snd <Action>(ClearAllNotifications)
nmap <leader>un <Action>(ClearAllNotifications)

" Telescope 키 매핑

" 파일 찾기 (루트 디렉토리)
nmap <leader><space> <Action>(GotoFile)
" 버퍼 전환
nmap <leader>, <Action>(Switcher)
" Grep (루트 디렉토리)
nmap <leader>/ <Action>(FindInPath)
" 명령 기록
nmap <leader>: :history<cr>
" 버퍼
nmap <leader>fb <Action>(Switcher)
" 구성 파일 찾기
nmap <leader>fc <Action>(GotoFile)
" 파일 찾기 (루트 디렉토리) (대안)
nmap <leader>ff <Action>(GotoFile)
" 파일 찾기 (현재 작업 디렉토리)
nmap <leader>fF <Action>(GotoFile)
" 파일 찾기 (git-files)
nmap <leader>fg <Action>(GotoFile)
" 최근
nmap <leader>fr <Action>(RecentFiles)
" 최근 (현재 작업 디렉토리)
nmap <leader>fR <Action>(RecentFiles)
" 커밋
nmap <leader>gc <Action>(Vcs.Show.Log)
" 상태
nmap <leader>gs <Action>(Vcs.Show.Log)
" 레지스터
nmap <leader>s" :registers<cr>
" 자동 명령
" nmap <leader>sa :echo '해당하는 매핑이 없습니다.'<cr>
" 버퍼
nmap <leader>sb <Action>(Switcher)
" 명령 기록 (대안)
nmap <leader>sc :history<cr>
" 명령
nmap <leader>sC <Action>(GotoAction)
" 문서 진단
nmap <leader>sd <Action>(ActivateProblemsViewToolWindow)
" 작업 공간 진단
nmap <leader>sD <Action>(ActivateProblemsViewToolWindow)
" Grep (루트 디렉토리) (대안)
nmap <leader>sg <Action>(FindInPath)
" Grep (현재 작업 디렉토리)
nmap <leader>sG <Action>(FindInPath)
" 도움말 페이지
nmap <leader>sh <Action>(HelpTopics)
" 강조 그룹 검색
nmap <leader>sH <Action>(HighlightUsagesInFile)
" 점프 목록
nmap <leader>sj <Action>(RecentLocations)
" 키 매핑
nmap <leader>sk :map<cr>
" 위치 목록
nmap <leader>sl <Action>(ActivateProblemsViewToolWindow)
" 마크로 점프
nmap <leader>sm :marks<cr>
" Man 페이지
nmap <leader>sM <Action>(ShowDocumentation)
" 옵션
nmap <leader>so <Action>(ShowSettings)
" 빠른 수정 목록
nmap <leader>sq <Action>(ActivateProblemsViewToolWindow)
" 재개
" nmap <leader>sR :echo '아직 구현되지 않았습니다.'<cr>
" 심볼로 이동
nmap <leader>ss <Action>(GotoSymbol)
" 심볼로 이동 (작업 공간)
nmap <leader>sS <Action>(GotoSymbol)
" 단어 (루트 디렉토리)
nmap <leader>sw <Action>(FindWordAtCaret)
" 단어 (현재 작업 디렉토리)
nmap <leader>sW <Action>(FindWordAtCaret)
" 선택 (루트 디렉토리)
vmap <leader>sw <Action>(FindWordAtCaret)
" 선택 (현재 작업 디렉토리)
vmap <leader>sW <Action>(FindWordAtCaret)
" 미리보기로 색 구성표
nmap <leader>uC <Action>(QuickChangeScheme)

" DAP 키 매핑

" 인수로 실행
nmap <leader>da <Action>(ChooseRunConfiguration)
" 중단점 토글
nmap <leader>db <Action>(ToggleLineBreakpoint)
" 중단점 조건
nmap <leader>dB <Action>(AddConditionalBreakpoint)
" 계속
nmap <leader>dc <Action>(Resume)
" 커서까지 실행
nmap <leader>dC <Action>(ForceRunToCursor)
" 줄로 이동 (실행 안 함)
" nmap <leader>dg :echo '아직 구현되지 않았습니다.'<cr>
" 단계 안으로
nmap <leader>di <Action>(StepInto)
" 아래로
nmap <leader>dj <Action>(GotoNextError)
" 위로
nmap <leader>dk <Action>(GotoPreviousError)
" 마지막 실행
nmap <leader>dl <Action>(Debug)
" 단계 밖으로
nmap <leader>do <Action>(StepOut)
" 단계 건너뛰기
nmap <leader>dO <Action>(StepOver)
" 일시 중지
nmap <leader>dp <Action>(Pause)
" REPL 토글
nmap <leader>dr <Action>(JShell.Console)
" 세션
" nmap <leader>ds :echo '아직 구현되지 않았습니다.'<cr>
" 종료
nmap <leader>dt <Action>(Stop)
" 위젯
" nmap <leader>dw :echo '위젯에 해당하는 매핑이 없습니다.'<cr>

" Todo-comments 키 매핑

" Todo
nmap <leader>st oTODO<esc>gcc
" Todo/Fix/Fixme
" nmap <leader>sT :echo '아직 구현되지 않았습니다.'<cr>
" Todo (Trouble)
" nmap <leader>xt :echo '아직 구현되지 않았습니다.'<cr>
" Todo/Fix/Fixme (Trouble)
" nmap <leader>xT :echo '아직 구현되지 않았습니다.'<cr>
" 이전 Todo 주석
nmap [t ?TODO<cr>
" 다음 Todo 주석
nmap ]t /TODO<cr>

" DAP UI 키 매핑

" 평가
nmap <leader>de <Action>(EvaluateExpression)
vmap <leader>de <Action>(EvaluateExpression)
" Dap UI
nmap <leader>du <Action>(ActivateDebugToolWindow)

" Neotest 키 매핑

" 마지막 실행
nmap <leader>tl <Action>(Run)
" 출력 표시
" nmap <leader>to :echo '아직 구현되지 않았습니다.'<cr>
" 출력 패널 토글
" nmap <leader>tO :echo '아직 구현되지 않았습니다.'<cr>
" 가장 가까운 실행
nmap <leader>tr <Action>(RunClass)
" 요약 토글
nmap <leader>ts <Action>(ShowTestSummary)
" 중지
nmap <leader>tS <Action>(Stop)
" 파일 실행
nmap <leader>tt <Action>(RunClass)
" 모든 테스트 파일 실행
nmap <leader>tT <Action>(RunAllTests)
" 감시 토글
nmap <leader>tw <Action>(ToggleTestWatch)

" nvim-dap
" 가장 가까운 디버그
nmap <leader>td <Action>(ChooseDebugConfiguration)

" Neovim 매핑
" https://neovim.io/doc/user/vim_diff.html#_default-mappings

nnoremap Y y$
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

" Q는 정확히 같지 않습니다.
nnoremap Q @@

" OS에 따라 아래 설정이 불필요할 수 있음. 해당 설정은 Windows 기준
" Normal mode: Explicitly map Ctrl+V to Visual Block mode start - Non-recursive conversion
nnoremap <C-v> <C-v>

" Insert mode: Map Ctrl+V to IDE's 'Paste' action (<Action> excluded from conversion)
imap <C-v> <Action>(EditorPaste)

" Visual mode: Map Ctrl+V to IDE's 'Paste' action (replaces selection) (<Action> excluded from conversion)
vmap <C-v> <Action>(EditorPaste)

" Command-line mode: Map Ctrl+V to paste from '+' register (system clipboard) - Non-recursive conversion
cnoremap <C-v> <C-R>+

" EasyMotion mappings - Actions using <Plug> are not converted
nmap s <Plug>(easymotion-s2)

" 다중 커서 관련 매핑 - Actions using <Plug> are not converted
nmap <C-n> <Plug>NextWholeOccurrence
xmap <C-n> <Plug>NextWholeOccurrence
nmap g<C-n> <Plug>NextOccurrence
xmap g<C-n> <Plug>NextOccurrence
xmap <C-x> <Plug>SkipOccurrence
xmap <C-p> <Plug>RemoveOccurrence
nmap <leader><C-n> <Plug>AllWholeOccurrences
xmap <leader><C-n> <Plug>AllWholeOccurrences
nmap <leader>g<C-n> <Plug>AllOccurrences
xmap <leader>g<C-n> <Plug>AllOccurrences

" 현재 설정에 추가할 surround 단축키들
nmap <leader>s' ysiw'
nmap <leader>s" ysiw"
nmap <leader>s( ysiw(
nmap <leader>s{ ysiw{
nmap <leader>s[ ysiw[
nmap <leader>s` ysiw`

" 줄 전체 감싸기
nmap <leader>S' yss'
nmap <leader>S" yss"
nmap <leader>S( yss(
nmap <leader>S{ yss{

" 경로/참조 복사
" <leader>y 를 사용하여 복사 기능과 유사하게 매핑
nmap <leader>y <Action>(CopyReferencePopupGroup)

" 확장 매칭. Neovim 기본 플러그인.
let g:WhichKey_ShowVimActions = "true"

" `IdeaVim-Which-Key` 플러그인용 매핑 설명
" 다음 변수들은 `set which-key` 옵션이 활성화된 경우 키 매핑에 대한 설명을 제공합니다.

" ' ' (스페이스) 리더 키 매핑 그룹 설명
let g:WhichKeyDesc_ = "<leader> 액션 목록"
let g:WhichKeyDesc_L = "<leader>L LazyVim 변경 로그"
let g:WhichKeyDesc_u = "<leader>u 토글/유틸리티"
let g:WhichKeyDesc_f = "<leader>f 파일/터미널"
let g:WhichKeyDesc_g = "<leader>g Git"
let g:WhichKeyDesc_c = "<leader>c 코드/LSP"
let g:WhichKeyDesc_b = "<leader>b 버퍼"
let g:WhichKeyDesc_s = "<leader>s 검색/정보"
let g:WhichKeyDesc_d = "<leader>d 디버그 (DAP)"
let g:WhichKeyDesc_t = "<leader>t 테스트"
let g:WhichKeyDesc_tab = "<leader><tab> 탭/레이아웃"
let g:WhichKeyDesc_x = "<leader>x 문제/Todo"
let g:WhichKeyDesc_l = "<leader>l LazyVim 플러그인 설정"
let g:WhichKeyDesc_K = "<leader>K 단어 도움말"
let g:WhichKeyDesc_qq = "<leader>qq 모두 종료"
let g:WhichKeyDesc_minus = "<leader>- 아래 창 분할"
let g:WhichKeyDesc_vbar = "<leader>| 오른쪽 창 분할"
let g:WhichKeyDesc_wd = "<leader>wd 창 삭제"
let g:WhichKeyDesc_wm = "<leader>wm 최대화 토글"
let g:WhichKeyDesc_C_forward_slash = "<C-/> 터미널 (루트)" " 이 매핑은 특수키 포함으로 제외될 수 있으나, 편의상 포함

" --- 리더 키 (`<leader>`) 시작 매핑 (이전과 동일하게 유지) ---
" 전역 리더 키 매핑 (추가됨)
let g:WhichKeyDesc_space = "<leader><space> 파일 열기 (GotoFile)"
let g:WhichKeyDesc_comma = "<leader>, 빠르게 버퍼 전환 (Switcher)"
let g:WhichKeyDesc_backtick = "<leader>` 다른 버퍼로 전환 (대안)"

" 토글/유틸리티 매핑 (`<leader>u`)
let g:WhichKeyDesc_uC = "<leader>uC 색 구성표 미리보기"
let g:WhichKeyDesc_uL = "<leader>uL 상대 줄 번호 토글"
let g:WhichKeyDesc_ub = "<leader>ub 배경 토글"
let g:WhichKeyDesc_uB = "<leader>uB 자동 포맷 토글 (버퍼)" " 현재 매핑 없음
let g:WhichKeyDesc_uc = "<leader>uc conceallevel 토글" " 현재 매핑 없음
let g:WhichKeyDesc_ud = "<leader>ud 진단 토글"
let g:WhichKeyDesc_uh = "<leader>uh 인레이 힌트 토글" " 현재 매핑 없음
let g:WhichKeyDesc_uI = "<leader>uI 트리 검사"
let g:WhichKeyDesc_ui = "<leader>ui 위치 검사"
let g:WhichKeyDesc_ul = "<leader>ul 줄 번호 토글"
let g:WhichKeyDesc_us = "<leader>us 맞춤법 검사 토글"
let g:WhichKeyDesc_uT = "<leader>uT Treesitter 강조 토글" " 현재 매핑 없음
let g:WhichKeyDesc_uw = "<leader>uw 줄 바꿈 토글"
let g:WhichKeyDesc_un = "<leader>un 알림 지우기"
let g:WhichKeyDesc_snd = "<leader>snd 알림 지우기"


" 파일/터미널 매핑 (`<leader>f`)
let g:WhichKeyDesc_fn = "<leader>fn 새 파일"
let g:WhichKeyDesc_ft = "<leader>ft 터미널 (루트)"
let g:WhichKeyDesc_fT = "<leader>fT 터미널 (현재)"
let g:WhichKeyDesc_fb = "<leader>fb 버퍼 전환"
let g:WhichKeyDesc_fc = "<leader>fc 구성 파일 찾기"
let g:WhichKeyDesc_fe = "<leader>fe 탐색기 (루트)"
let g:WhichKeyDesc_fE = "<leader>fE 탐색기 (현재)"
let g:WhichKeyDesc_ff = "<leader>ff 파일 찾기 (루트)"
let g:WhichKeyDesc_fF = "<leader>fF 파일 찾기 (현재)"
let g:WhichKeyDesc_fg = "<leader>fg Git 파일 찾기"
let g:WhichKeyDesc_fr = "<leader>fr 최근 파일 (모든 프로젝트)"
let g:WhichKeyDesc_fR = "<leader>fR 최근 파일 (현재 프로젝트)"
let g:WhichKeyDesc_e = "<leader>e 현재 파일 구조 팝업"
let g:WhichKeyDesc_E = "<leader>E 현재 파일 위치"


" Git 매핑 (`<leader>g`)
let g:WhichKeyDesc_gb = "<leader>gb Git Blame 줄"
let g:WhichKeyDesc_gB = "<leader>gB Git Browse (로그)"
let g:WhichKeyDesc_gc = "<leader>gc Git 커밋 (Telescope)"
let g:WhichKeyDesc_gf = "<leader>gf Git 현재 파일 기록"
let g:WhichKeyDesc_gg = "<leader>gg Lazygit (루트)"
let g:WhichKeyDesc_gG = "<leader>gG Lazygit (현재)"
let g:WhichKeyDesc_gl = "<leader>gl Lazygit 로그 (Telescope)"
let g:WhichKeyDesc_gL = "<leader>gL Lazygit 로그 (현재)"
let g:WhichKeyDesc_gs = "<leader>gs Git 상태 (Telescope)"
let g:WhichKeyDesc_ge = "<leader>ge Git 탐색기"


" 코드/LSP 매핑 (`<leader>c`)
let g:WhichKeyDesc_ca = "<leader>ca 코드 액션"
let g:WhichKeyDesc_cA = "<leader>cA 소스 액션 (Intention)"
let g:WhichKeyDesc_cc = "<leader>cc Codelens 실행" " 현재 매핑 없음
let g:WhichKeyDesc_cC = "<leader>cC Codelens 새로 고침 및 표시" " 현재 매핑 없음
let g:WhichKeyDesc_cd = "<leader>cd 줄 진단"
let g:WhichKeyDesc_cf = "<leader>cf 코드 포맷"
let g:WhichKeyDesc_cR = "<leader>cR 파일 이름 바꾸기"
let g:WhichKeyDesc_cr = "<leader>cr 이름 바꾸기"


" 버퍼 매핑 (`<leader>b`)
let g:WhichKeyDesc_bb = "<leader>bb 다른 버퍼 전환"
let g:WhichKeyDesc_bd = "<leader>bd 버퍼 삭제"
let g:WhichKeyDesc_bD = "<leader>bD 버퍼 및 창 삭제"
let g:WhichKeyDesc_bl = "<leader>bl 왼쪽 버퍼 삭제"
let g:WhichKeyDesc_bm = "<leader>bm 분할 창 이동"
let g:WhichKeyDesc_bo = "<leader>bo 다른 버퍼 삭제"
let g:WhichKeyDesc_bp = "<leader>bp 핀 토글"
let g:WhichKeyDesc_bP = "<leader>bP 고정되지 않은 버퍼 삭제"
let g:WhichKeyDesc_br = "<leader>br 오른쪽 버퍼 삭제"
let g:WhichKeyDesc_bu = "<leader>bu 수정되지 않은 버퍼 삭제"
let g:WhichKeyDesc_ba = "<leader>ba 모든 버퍼 삭제"
let g:WhichKeyDesc_bc = "<leader>bc 분할 방향 변경"
let g:WhichKeyDesc_be = "<leader>be 버퍼 탐색기"


" 검색/정보 매핑 (`<leader>s`)
let g:WhichKeyDesc_s_double_quote = "<leader>s\" 레지스터 표시"
let g:WhichKeyDesc_sa = "<leader>sa 자동 명령" " 현재 매핑 없음
let g:WhichKeyDesc_sb = "<leader>sb 버퍼 선택"
let g:WhichKeyDesc_sc = "<leader>sc 명령 기록"
let g:WhichKeyDesc_sC = "<leader>sC 명령 찾기 (Action)"
let g:WhichKeyDesc_sd = "<leader>sd 문서 진단"
let g:WhichKeyDesc_sD = "<leader>sD 작업 공간 진단"
let g:WhichKeyDesc_sg = "<leader>sg 프로젝트에서 Grep"
let g:WhichKeyDesc_sG = "<leader>sG 현재 파일에서 Grep"
let g:WhichKeyDesc_sh = "<leader>sh 도움말 페이지 (HelpTopics)"
let g:WhichKeyDesc_sH = "<leader>sH 강조 그룹 검색 (HighlightUsages)"
let g:WhichKeyDesc_sj = "<leader>sj 점프 목록 (RecentLocations)"
let g:WhichKeyDesc_sk = "<leader>sk 키 매핑 표시"
let g:WhichKeyDesc_sl = "<leader>sl 위치 목록"
let g:WhichKeyDesc_sm = "<leader>sm 마크로 점프"
let g:WhichKeyDesc_sM = "<leader>sM Man 페이지 (ShowDocumentation)"
let g:WhichKeyDesc_so = "<leader>so 옵션 (설정)"
let g:WhichKeyDesc_sq = "<leader>sq 빠른 수정 목록"
let g:WhichKeyDesc_sR = "<leader>sR 재개 마지막 검색" " 현재 매핑 없음
let g:WhichKeyDesc_ss = "<leader>ss 현재 파일에서 심볼"
let g:WhichKeyDesc_sS = "<leader>sS 작업 공간에서 심볼"
let g:WhichKeyDesc_sw_normal = "<leader>sw 단어 검색 (루트), 일반모드"
let g:WhichKeyDesc_sW_normal = "<leader>sW 단어 검색 (현재), 일반모드"
let g:WhichKeyDesc_sw_visual = "<leader>sw 단어 검색 (루트), 비주얼모드"
let g:WhichKeyDesc_sW_visual = "<leader>sW 단어 검색 (현재), 비주얼모드"
let g:WhichKeyDesc_st = "<leader>st Todo 주석 추가"


" 디버그 (DAP) 매핑 (`<leader>d`)
let g:WhichKeyDesc_da = "<leader>da 인수로 실행"
let g:WhichKeyDesc_db = "<leader>db 중단점 토글"
let g:WhichKeyDesc_dB = "<leader>dB 조건부 중단점"
let g:WhichKeyDesc_dc = "<leader>dc 계속"
let g:WhichKeyDesc_dC = "<leader>dC 커서까지 강제 실행"
let g:WhichKeyDesc_de_normal = "<leader>de 식 평가 (일반모드)"
let g:WhichKeyDesc_de_visual = "<leader>de 식 평가 (비주얼모드)"
let g:WhichKeyDesc_dg = "<leader>dg 줄로 이동 (실행 안 함)" " 현재 매핑 없음
let g:WhichKeyDesc_di = "<leader>di 단계 안으로"
let g:WhichKeyDesc_dj = "<leader>dj 디버그 다음 항목"
let g:WhichKeyDesc_dk = "<leader>dk 디버그 이전 항목"
let g:WhichKeyDesc_dl = "<leader>dl 마지막 실행 디버그"
let g:WhichKeyDesc_do = "<leader>do 단계 밖으로"
let g:WhichKeyDesc_dO = "<leader>dO 단계 건너뛰기"
let g:WhichKeyDesc_dp = "<leader>dp 일시 중지"
let g:WhichKeyDesc_dr = "<leader>dr REPL 토글"
let g:WhichKeyDesc_ds = "<leader>ds 세션" " 현재 매핑 없음
let g:WhichKeyDesc_dt = "<leader>dt 디버거 종료"
let g:WhichKeyDesc_du = "<leader>du 디버그 UI 열기"
let g:WhichKeyDesc_dw = "<leader>dw 디버그 위젯" " 현재 매핑 없음


" 테스트 매핑 (`<leader>t`)
let g:WhichKeyDesc_td = "<leader>td 가장 가까운 디버그"
let g:WhichKeyDesc_tl = "<leader>tl 마지막 테스트 실행"
let g:WhichKeyDesc_to = "<leader>to 테스트 출력 표시" " 현재 매핑 없음
let g:WhichKeyDesc_tO = "<leader>tO 테스트 출력 패널 토글" " 현재 매핑 없음
let g:WhichKeyDesc_tr = "<leader>tr 가장 가까운 테스트 실행"
let g:WhichKeyDesc_ts = "<leader>ts 테스트 요약 토글"
let g:WhichKeyDesc_tS = "<leader>tS 테스트 중지"
let g:WhichKeyDesc_tt = "<leader>tt 현재 파일 테스트 실행"
let g:WhichKeyDesc_tT = "<leader>tT 모든 테스트 파일 실행"
let g:WhichKeyDesc_tw = "<leader>tw 테스트 감시 토글"


" 탭/레이아웃 매핑 (`<leader><tab>`)
" NOTE: <leader><tab> 키 자체에 대한 설명은 `g:WhichKeyDesc_tab`으로 상단에 정의됨
let g:WhichKeyDesc_tabl = "<leader><tab>l 마지막 탭"
let g:WhichKeyDesc_tabo = "<leader><tab>o 다른 탭 닫기"
let g:WhichKeyDesc_tabf = "<leader><tab>f 첫 번째 탭"
let g:WhichKeyDesc_tabn = "<leader><tab>n 새 탭"
let g:WhichKeyDesc_tabc = "<leader><tab>c 탭 닫기"
let g:WhichKeyDesc_tab_square_right = "<leader><tab>] 다음 탭"
let g:WhichKeyDesc_tab_square_left = "<leader><tab>[ 이전 탭"
let g:WhichKeyDesc_tabc = "<leader><tab>c 탭 닫기" " 이전에 매핑 정의는 없었으나, 설명을 위해 추가


" 문제/Todo 매핑 (`<leader>x`)
let g:WhichKeyDesc_xl = "<leader>xl 위치 목록 (문제 툴 창)"
let g:WhichKeyDesc_xq = "<leader>xq 빠른 수정 목록 (문제 툴 창)"
let g:WhichKeyDesc_xt = "<leader>xt Todo (Trouble)" " 현재 매핑 없음
let g:WhichKeyDesc_xT = "<leader>xT Todo/Fix/Fixme (Trouble)" " 현재 매핑 없음

" 추가된 검색/정보 매핑
let g:WhichKeyDesc_slash = "<leader>/ 프로젝트에서 Grep (FindInPath)"
let g:WhichKeyDesc_colon = "<leader>: 명령 기록 (:history)"


" --- 2개 이상 키가 필요한 Vim 기본 액션 (특수키 제외) ---
" (리더 키를 사용하지 않으면서 2개 이상의 연속된 일반 키 시퀀스)
" 예: gd, [[, [b 등

let g:WhichKeyDesc_gd = "gd 정의로 이동"
let g:WhichKeyDesc_gR = "gR 참조 찾기"
let g:WhichKeyDesc_gU = "gU 사용으로 바로 이동"
let g:WhichKeyDesc_gI = "gI 구현으로 이동"
let g:WhichKeyDesc_gy = "gy 타입 정의로 이동"
let g:WhichKeyDesc_gD = "gD 선언으로 이동"
let g:WhichKeyDesc_gK = "gK 시그니처 도움말"
let g:WhichKeyDesc_gco = "gco 아래에 주석 추가"
let g:WhichKeyDesc_gcO = "gcO 위에 주석 추가"

let g:WhichKeyDesc_square_left_b = "[b 이전 버퍼"
let g:WhichKeyDesc_square_right_b = "]b 다음 버퍼"

let g:WhichKeyDesc_square_left_left = "[[ 이전 참조"
let g:WhichKeyDesc_square_right_right = "]] 다음 참조"

let g:WhichKeyDesc_square_left_q = "[q 이전 빠른 수정"
let g:WhichKeyDesc_square_right_q = "]q 다음 빠른 수정"

let g:WhichKeyDesc_square_left_d = "[d 이전 진단"
let g:WhichKeyDesc_square_right_d = "]d 다음 진단"

let g:WhichKeyDesc_square_left_e = "[e 이전 오류"
let g:WhichKeyDesc_square_right_e = "]e 다음 오류"

let g:WhichKeyDesc_square_left_w = "[w 이전 경고"
let g:WhichKeyDesc_square_right_w = "]w 다음 경고"

let g:WhichKeyDesc_square_left_t = "[t 이전 Todo 주석"
let g:WhichKeyDesc_square_right_t = "]t 다음 Todo 주석"

" EasyMotion
let g:WhichKeyDesc_s = "s EasyMotion 시작" " 단일 키지만, 다음 시퀀스를 유도하므로 포함 (편의상)

" Multiple-cursors
let g:WhichKeyDesc_C_n_normal = "<C-n> 다음 전체 일치 선택" " nmap
let g:WhichKeyDesc_C_n_visual = "<C-n> 다음 전체 일치 선택" " xmap
let g:WhichKeyDesc_gC_n = "g<C-n> 다음 일치 선택" " nmap
let g:WhichKeyDesc_gC_n_visual = "g<C-n> 다음 일치 선택" " xmap
let g:WhichKeyDesc_C_x_visual = "<C-x> 일치 건너뛰기" " xmap
let g:WhichKeyDesc_C_p_visual = "<C-p> 일치 제거" " xmap
let g:WhichKeyDesc_leaderC_n = "<leader><C-n> 모든 전체 일치 선택" " nmap
let g:WhichKeyDesc_leaderC_n_visual = "<leader><C-n> 모든 전체 일치 선택" " xmap
let g:WhichKeyDesc_leadergC_n = "<leader>g<C-n> 모든 일치 선택" " nmap
let g:WhichKeyDesc_leadergC_n_visual = "<leader>g<C-n> 모든 일치 선택" " xmap

" Surround 관련 추가 매핑
let g:WhichKeyDesc_s_single_quote = "<leader>s' 단어를 '로 감싸기"
let g:WhichKeyDesc_s_double_quote_surround = '<leader>s" 단어를 "로 감싸기'
let g:WhichKeyDesc_s_paren = "<leader>s( 단어를 ()로 감싸기"
let g:WhichKeyDesc_s_brace = "<leader>s{ 단어를 {}로 감싸기"
let g:WhichKeyDesc_s_bracket = "<leader>s[ 단어를 []로 감싸기"
let g:WhichKeyDesc_s_backtick = "<leader>s` 단어를 ``로 감싸기"

let g:WhichKeyDesc_S_single_quote = "<leader>S' 줄을 '로 감싸기"
let g:WhichKeyDesc_S_double_quote_surround = '<leader>S" 줄을 "로 감싸기'
let g:WhichKeyDesc_S_paren = "<leader>S( 줄을 ()로 감싸기"
let g:WhichKeyDesc_S_brace = "<leader>S{ 줄을 {}로 감싸기"

let g:WhichKeyDesc_leader_y = "<leader>y 경로/참조 복사"

" 포팅해야 할 Neovim 매핑이 몇 가지 더 있습니다. 링크 참조.

" Jetbrains 충돌
" https://github.com/JetBrains/ideavim/blob/master/doc/sethandler.md
" 아직 없음. 가능한 충돌: ctrl -6befhjklorsvw

" 참고 및 주의 사항:
" 탭은 JB 저장 레이아웃에 매핑됩니다.
" 모든 것이 테스트되지는 않았습니다.

" TODO:
" Jetbrains 충돌
" Todo-comments 개선
" github 프로젝트로 변환
" which-key 라벨
" 모든 맵 테스트. 나란히.
" 모든 which-key 팝업 비교
" 고려 사항:
"   flash, grub-far, noice, trouble, mini.diff, oversear, copilotchat,
"   dial, outline, md preview, harpoon, octo
