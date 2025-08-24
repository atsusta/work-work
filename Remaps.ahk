; Shift + Space takes toggle Hangul/English
; Win10 | 설정 -> 시간 및 언어 -> 언어 -> 기본 설정 언어 -> [한국어]옵션 -> 하드웨어 키보드 레이아웃 / 키보드 레이아웃: 한글 키보드(101키) 종류 3
<+space::Send "{vk15sc138}"

; AppsKey (Context menu)
>#\::AppsKey

; CapsLock
; https://www.autohotkey.com/docs/misc/Remap.htm
^+CapsLock::CapsLock
CapsLock::Ctrl

; Disable extra mouse buttons
XButton1::Return
XButton2::Return

; Photoshop
#HotIf WinActive("ahk_exe Photoshop.exe")
; Reset brush smoothing (0%)
!`::Send "!0!0"

; Ctrl + Right mouse button (Select Layer)
Insert::Send "{Ctrl down}{RButton}"
Insert Up::Send "{Ctrl up}"

Pause::Send "{RButton}"
#HotIf

; Disable Microsoft Text Input Application
#h::Return

; Macros
;AppsKey & Esc::Send "{F12}"
F12 & t::Send "수고하셨습니다"
F12 & r::Send "감사합니다"
F12 & d::Send "안녕하세요"