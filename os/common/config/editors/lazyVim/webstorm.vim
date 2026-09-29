" WebStorm 2025.1.7.2 / IdeaVim 2.27.1
" The common entry point loads this after common.vim.

" IdeaVim 2.27.1: case conversion requires StringManipulation plugin.
" The last three actions toggle the target style and camelCase.
xmap <leader>rs <Action>(StringManipulation.ToSnakeCase)
xmap <leader>rm <Action>(StringManipulation.ToPascalCase)
xmap <leader>rc <Action>(StringManipulation.ToCamelCase)
xmap <leader>ru <Action>(StringManipulation.ToScreamingSnakeCase)
xmap <leader>rk <Action>(StringManipulation.ToKebabCase)
xmap <leader>r. <Action>(StringManipulation.ToDotStyleAction)
xmap <leader>r<Space> <Action>(osmedile.intellij.stringmanip.styles.ToCamelCaseOrToWordLowercaseAction)
xmap <leader>rt <Action>(osmedile.intellij.stringmanip.ToCamelCaseAction)

" WebStorm ESLint fix action.
nmap <leader>cl <Action>(Javascript.Linters.EsLint.Fix)
vmap <leader>cl <Action>(Javascript.Linters.EsLint.Fix)
let g:WhichKeyDesc_cl = "<leader>cl ESLint Fix"

" Language implementation and type navigation.
nmap gI <Action>(GotoImplementation)
nmap gy <Action>(GotoTypeDeclaration)

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
" 세션
" nmap <leader>ds :echo '아직 구현되지 않았습니다.'<cr>
" 종료
nmap <leader>dt <Action>(Stop)
" 위젯
" nmap <leader>dw :echo '위젯에 해당하는 매핑이 없습니다.'<cr>

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
" 중지
nmap <leader>tS <Action>(Stop)
" 파일 실행
nmap <leader>tt <Action>(RunClass)

" nvim-dap
" 가장 가까운 디버그
nmap <leader>td <Action>(ChooseDebugConfiguration)

" ------------------------------------------------------------
" Debug: <leader>d
" ------------------------------------------------------------
let g:WhichKeyDesc_da = "<leader>da 실행 구성 선택"
let g:WhichKeyDesc_db = "<leader>db 중단점 토글"
let g:WhichKeyDesc_dB = "<leader>dB 조건부 중단점"
let g:WhichKeyDesc_dc = "<leader>dc 계속"
let g:WhichKeyDesc_dC = "<leader>dC 커서까지 실행"
let g:WhichKeyDesc_de_normal = "<leader>de 식 평가"
let g:WhichKeyDesc_de_visual = "<leader>de 식 평가"
let g:WhichKeyDesc_di = "<leader>di Step Into"
let g:WhichKeyDesc_dj = "<leader>dj 다음 항목"
let g:WhichKeyDesc_dk = "<leader>dk 이전 항목"
let g:WhichKeyDesc_dl = "<leader>dl 디버그"
let g:WhichKeyDesc_do = "<leader>do Step Out"
let g:WhichKeyDesc_dO = "<leader>dO Step Over"
let g:WhichKeyDesc_dp = "<leader>dp 일시 중지"
let g:WhichKeyDesc_dt = "<leader>dt 중지"
let g:WhichKeyDesc_du = "<leader>du 디버그 창"

" ------------------------------------------------------------
" Test: <leader>t
" ------------------------------------------------------------
let g:WhichKeyDesc_td = "<leader>td 디버그 구성 선택"
let g:WhichKeyDesc_tl = "<leader>tl 마지막 실행"
let g:WhichKeyDesc_tr = "<leader>tr 테스트 실행"
let g:WhichKeyDesc_tS = "<leader>tS 테스트 중지"
let g:WhichKeyDesc_tt = "<leader>tt 현재 테스트 실행"
