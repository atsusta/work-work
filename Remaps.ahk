; Shift + Space takes toggle Hangul/English
<+space::
  Send, {vk15sc138}
Return

; AppsKey (Context menu)
>#/::AppsKey
Return

; Disable main context menu
;!space::Return

; Disable toggling keyboard language
;^#space::Return
;#space::Return
;+#space::Return

; CapsLock
; https://www.autohotkey.com/docs/misc/Remap.htm
;^<+::CapsLock
;Ctrl::CapsLock
;CapsLock::Ctrl
#InstallKeybdHook
SendSuppressedKeyUp(key) {
    DllCall("keybd_event"
        , "char", GetKeyVK(key)
        , "char", GetKeySC(key)
        , "uint", KEYEVENTF_KEYUP := 0x2
        , "uptr", KEY_BLOCK_THIS := 0xFFC3D450)
}
; Disable Alt+key shortcuts for the IME.
~LAlt::SendSuppressedKeyUp("LAlt")

; Test hotkey:
;!CapsLock::MsgBox % A_ThisHotkey

; Remap CapsLock to LCtrl in a way compatible with IME.
*CapsLock::
    Send {Blind}{LCtrl DownR}
    SendSuppressedKeyUp("LCtrl")
    return
*CapsLock up::
    Send {Blind}{LCtrl Up}
    return
!#CapsLock::CapsLock

; Disable extra mouse buttons
XButton1::Return
XButton2::Return

; Photoshop
; Reset brush smoothing (0%)
!`::
  Send, !0!0
Return
; Ctrl + Right mouse button (Select Layer)
^Pause::^RButton

; Disable Microsoft Text Input Application
#h::
MsgBox Kill Microsoft Text Input Application.
return

; Open Terminal like Linux
^!t::ToggleTerminal()

ShowAndPositionTerminal()
{
    WinShow ahk_class CASCADIA_HOSTING_WINDOW_CLASS
    WinActivate ahk_class CASCADIA_HOSTING_WINDOW_CLASS

    SysGet, WorkArea, MonitorWorkArea
    ;TerminalWidth := A_ScreenWidth * 0.9
    ;if (A_ScreenWidth / A_ScreenHeight) > 1.5 {
    ;    TerminalWidth := A_ScreenWidth * 0.6
    ;}
    WinMove, ahk_class CASCADIA_HOSTING_WINDOW_CLASS,, (A_ScreenWidth - TerminalWidth) / 2, WorkAreaTop - 2, TerminalWidth, A_ScreenHeight * 0.5,
}

ToggleTerminal()
{
    WinMatcher := "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"

    DetectHiddenWindows, On

    if WinExist(WinMatcher)
    ; Window Exists
    {
        DetectHiddenWindows, Off

        ; Check if its hidden
        if !WinExist(WinMatcher) || !WinActive(WinMatcher)
        {
            ShowAndPositionTerminal()
        }
        else if WinExist(WinMatcher)
        {
            ; Script sees it without detecting hidden windows, so..
            WinHide ahk_class CASCADIA_HOSTING_WINDOW_CLASS
            Send !{Esc}
        }
    }
    else
    {
        Run *RunAs "c:\Users\SMTST\AppData\Local\Microsoft\WindowsApps\wt.exe"
        Sleep, 1000
        ShowAndPositionTerminal()
    }
}

; Macros
AppsKey & Esc up::
  Send, {F12}
  Return
F12 & t Up::
  ; 수고하셨습니다
  Send, {Raw}tnrhgktuTtmqslek
  Return
F12 & r Up::
  ; 감사합니다
  Send, {Raw}rkatkgkqslek
  Return
F12 & d Up::
  ; 안녕하세요
  Send, {Raw}dkssudgktpdy
  Return
F12 & z Up::
  ; ㅋㅋㅋㅋㅋㅋㅋㅋㅋ 
  Send, {Raw}zzzzzzzzz
  Return