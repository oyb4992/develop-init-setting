#HotIf WinActive("ahk_exe Code.exe") or WinActive("ahk_exe Trae.exe") or WinActive("ahk_exe Cursor.exe") or WinActive("ahk_exe idea64.exe") or WinActive("ahk_exe Obsidian.exe")
$Esc::
{
    ; 현재 활성 창("A")의 IME 상태 확인 (한글이면 0x1 반환)
    if (IME_CHECK("A"))
    {
        Send "{vk15}"  ; 한/영 전환 키 보내기 (시스템에 따라 "{Hangul}" 시도)
    }
    Send "{Escape}" ; Escape 키 보내기
    return ; Hotkey 종료
}

#HotIf ; Hotkey 조건 적용 범위 종료

/*
IME check 함수 (v1 로직 기반 v2 변환)
WinTitle: 대상 창 식별자 (예: "A"는 활성 창)
반환값: IME 상태 (한글 모드 등 특정 상태일 때 0x1 반환)
*/
IME_CHECK(WinTitle) {
    local hWnd
    ; 창 제목/식별자로 창 핸들(hWnd) 가져오기
    hWnd := WinGetID(WinTitle)
    ; 기본 IME 창 핸들을 가져와 Send_ImeControl 호출 후 결과 반환
    return Send_ImeControl(ImmGetDefaultIMEWnd(hWnd), 0x005, "") ; IMC_GETCONVERSIONMODE (0x005)
}

/*
IME 제어 메시지 전송 함수 (v1 로직 기반 v2 변환)
DefaultIMEWnd: 대상 IME 창 핸들
wParam: 메시지 파라미터 (예: 0x005는 IMC_GETCONVERSIONMODE)
lParam: 메시지 파라미터
반환값: SendMessage 결과 (ErrorLevel에 해당)
*/
Send_ImeControl(DefaultIMEWnd, wParam, lParam) {
    local DetectSave, Result
    ; 현재 숨겨진 창 감지 설정 백업
    DetectSave := A_DetectHiddenWindows
    ; 숨겨진 창 감지 활성화 (IME 창이 숨겨져 있을 수 있음)
    A_DetectHiddenWindows := true
    ; IME 제어 메시지(WM_IME_CONTROL = 0x283) 전송 및 결과 저장
    Result := SendMessage(0x283, wParam, lParam, , "ahk_id " DefaultIMEWnd)
    ; 원래 숨겨진 창 감지 설정으로 복원
    A_DetectHiddenWindows := DetectSave
    ; SendMessage 결과 반환
    return Result
}

/*
기본 IME 창 핸들 가져오는 함수 (v1 로직 기반 v2 변환)
hWnd: 대상 창 핸들
반환값: 기본 IME 창 핸들
*/
ImmGetDefaultIMEWnd(hWnd) {
    ; DllCall을 사용하여 ImmGetDefaultIMEWnd API 호출
    return DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hWnd, "Ptr")
}

; --- Ctrl + h/j/k/l 를 방향키로 사용 ---
; $ 접두사: Send 명령어가 이 Hotkey를 다시 트리거하는 것을 방지합니다.
; ^ 기호: Ctrl 키를 의미합니다.

$^!h::Send "{Left}"   ; Ctrl + h -> 왼쪽 방향키
$^!j::Send "{Down}"   ; Ctrl + j -> 아래쪽 방향키
$^!k::Send "{Up}"     ; Ctrl + k -> 위쪽 방향키
$^!l::Send "{Right}"  ; Ctrl + l -> 오른쪽 방향키