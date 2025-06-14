" ~/.idea-lazy.vim

" Jetbrains IDE용 LazyVim 매핑

" 필수 플러그인. https://plugins.jetbrains.com/bundles/7-ideavim-bundle
"  IDEAVim
"  Which-Key
"  IdeaVim-Sneak

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
" 확장 매칭. Neovim 기본 플러그인.
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
let g:EasyMotion_do_mapping = 0

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
nmap <leader>ub :echo '자동 포맷 토글에 해당하는 매핑이 없습니다.'<cr>
" 자동 포맷 토글 (버퍼)
nmap <leader>uB :echo '자동 포맷 토글에 해당하는 매핑이 없습니다.'<cr>
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
nmap <leader>uc :echo 'Conceallevel 토글에 해당하는 매핑이 없습니다.'<cr>
" Treesitter 강조 토글
nmap <leader>uT :echo 'Treesitter 강조 토글에 해당하는 매핑이 없습니다.'<cr>
" 배경 토글
nmap <leader>ub <Action>(QuickChangeScheme)
" 인레이 힌트 토글
nmap <leader>uh :echo '인레이 힌트 토글에 해당하는 매핑이 없습니다.'<cr>
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
nmap <leader><tab>f <Action>(StoreDefaultLayout)<Action>(StoreNewLayout)
" 다음 탭
nmap <leader><tab>] <Action>(StoreDefaultLayout)<Action>(ChangeToolWindowLayout)
" 이전 탭
nmap <leader><tab>[ <Action>(StoreDefaultLayout)<Action>(ChangeToolWindowLayout)
" 탭 닫기
nmap <leader><tab>f <Action>(StoreDefaultLayout)<Action>(ChangeToolWindowLayout)

" LSP 키 매핑

" Lsp 정보
nmap <leader>cc :echo 'Lsp 정보에 해당하는 매핑이 없습니다.'<cr>
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
nmap <leader>cc :echo 'Codelens 실행에 해당하는 매핑이 없습니다.'<cr>
" Codelens 새로 고침 및 표시
nmap <leader>cC :echo 'Codelens 새로 고침 및 표시에 해당하는 매핑이 없습니다.'<cr>
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
nmap <leader>sa :echo '해당하는 매핑이 없습니다.'<cr>
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
nmap <leader>sR :echo '아직 구현되지 않았습니다.'<cr>
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
nmap <leader>dg :echo '아직 구현되지 않았습니다.'<cr>
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
nmap <leader>ds :echo '아직 구현되지 않았습니다.'<cr>
" 종료
nmap <leader>dt <Action>(Stop)
" 위젯
nmap <leader>dw :echo '위젯에 해당하는 매핑이 없습니다.'<cr>

" Todo-comments 키 매핑

" Todo
nmap <leader>st oTODO<esc>gcc
" Todo/Fix/Fixme
nmap <leader>sT :echo '아직 구현되지 않았습니다.'<cr>
" Todo (Trouble)
nmap <leader>xt :echo '아직 구현되지 않았습니다.'<cr>
" Todo/Fix/Fixme (Trouble)
nmap <leader>xT :echo '아직 구현되지 않았습니다.'<cr>
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
nmap <leader>to :echo '아직 구현되지 않았습니다.'<cr>
" 출력 패널 토글
nmap <leader>tO :echo '아직 구현되지 않았습니다.'<cr>
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
map s <Plug>(easymotion-s2)

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