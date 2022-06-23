; Shift + space takes toggle Hangul/English
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
#CapsLock::CapsLock

; Remap CapsLock to LCtrl in a way compatible with IME.
*CapsLock::
    Send {Blind}{LCtrl DownR}
    SendSuppressedKeyUp("LCtrl")
    return
*CapsLock up::
    Send {Blind}{LCtrl Up}
    return

; Disable Mouse keys
XButton1::Return
XButton2::Return

; Photoshop
; Reset brush smoothing (0%)
!`::
  Send, !0!0
Return
; Control + Right mouse button (Select Layer)
^Pause::^RButton

; Disable Microsoft Text Input Application
#h::
MsgBox Kill Microsoft Text Input Application.
return

; Macros
~ScrollLock & t::
  ; 수고하셨습니다
  Send, {Raw}tnrhgktuTtmqslek
  Return
~ScrollLock & r::
  ; 감사합니다
  Send, {Raw}rkatkgkqslek
  Return
~ScrollLock & d::
  ; 안녕하세요
  Send, {Raw}dkssudgktpdy
  Return
~ScrollLock & z::
  ; ㅋㅋㅋㅋㅋㅋㅋㅋㅋ 
  Send, {Raw}zzzzzzzzz
  Return