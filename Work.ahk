TimerActive = 1
IniRead, IdleTime, timer.ini, section, Timeout, 10
IniRead, Program1, timer.ini, section, Program1
IniRead, Program2, timer.ini, section, Program2
IniRead, Program3, timer.ini, section, Program3
IniRead, LastTime, timer.ini, section, LastTime, 00:00:00
IniRead, ColorAlert, timer.ini, section, ColorAlert, true
IniRead, OnColor, timer.ini, section, OnColor, B0FFFF
IniRead, OffColor, timer.ini, section, OffColor, F07070
IniRead, OverColor, timer.ini, section, OverColor, c9364c
IniWrite, %ColorAlert%, timer.ini, section, ColorAlert
IniWrite, %OnColor%, timer.ini, section, OnColor
IniWrite, %OffColor%, timer.ini, section, OffColor
IniWrite, %OverColor%, timer.ini, section, OverColor
menuX := 170
menuY := 8
menuHeight := 24
windowWidth := 210
windowHeight := 40
overWorked := 0
GOTO START

START:
  SetBatchLines, -1
  Gui +LastFound +AlwaysOnTop
  Gui, Color, %OnColor%

  ; Select font: Leave 2 code blocks and comment any others
  ; Gui, Font, S20 CDefault, Segoe UI Bold Italic
  ; Gui, Add, Text, x8 y0 vMyText, 00:00:00
  Gui, Font, S18 CDefault, Inter V Black Italic
  Gui, Add, Text, x8 y5 vMyText, 00:00:00
  ; Gui, Font, S24 CDefault, DS-Digital Bold Italic
  ; Gui, Add, Text, x4 y4 vMyText, 00:00:00
  ; Gui, Font, S14 CDefault, Arcade Normal
  ; Gui, Add, Text, x6 y12 vMyText, 00:00:00
  ; Gui, Font, S24 CDefault, PxPlus IBM VGA8
  ; Gui, Add, Text, x8 y6 vMyText, 00:00:00
  ; Gui, Font, S24 CDefault, NeoDunggeunmo
  ; Gui, Add, Text, x8 y6 vMyText, 00:00:00
  ; Gui, Font, S14 CDefault, Amiga Forever Pro2
  ; Gui, Add, Text, x8 y7 vMyText, --------

  ; Menu icon
  Gui, Font, S16 CDefault, Consolas
  menuIcon := Chr(0x2630)
  Gui, Add, Button, x%menuX% y%menuY% h%menuHeight% gPopMenu, %menuIcon%
  SetFormat, Float, 02.0
  h := m := s := "00"
  SetTimer, Update, 1000
  Gosub, Update
  Gui, -MinimizeBox -MaximizeBox
  Gui, Show, w%windowWidth% h%windowHeight%, MEMENTO MORI

  Gui, 2: +LastFound +AlwaysOnTop
  Gui, 2: Add, Text, x8 y7 vMyText, Enter idle timeout in seconds:
  Gui, 2: Add, Edit, y5 vNewTimeout w25
  Gui, 2: Add, Button, gSetTimeoutOK Default, Set
  WinSet, Style, -0x20000 -0x10000

  progmen1 = Program 1: %Program1%
  progmen2 = Program 2: %Program2%
  progmen3 = Program 3: %Program3%
  timemen = Timeout: %IdleTime%
  Menu, MyMenu, Add, Resume previous time, Prev
  Menu, MyMenu, Add
  Menu, MyMenu, Add, %progmen1%, SetProgram1
  Menu, MyMenu, Add, %progmen2%, SetProgram2
  Menu, MyMenu, Add, %progmen3%, SetProgram3
  Menu, MyMenu, Add
  Menu, MyMenu, Add, %timemen%, SetTimeout
  Menu, MyMenu, Add
  Menu, MyMenu, Add, Color Alert, ChangeColor
  if (ColorAlert = "true") {
    Menu, MyMenu, Check, Color Alert
  }
RETURN

GuiClose:
  IniWrite, %H%:%M%:%S%, timer.ini, section, LastTime
ExitApp

ChangeColor:
  if (ColorAlert = "true") {
    Menu, MyMenu, UnCheck, Color Alert
    ColorAlert = false
    IniWrite, false, timer.ini, section, ColorAlert
    Gui, Color, %OnColor%
  } else {
    Menu, MyMenu, Check, Color Alert
    ColorAlert = true
    IniWrite, true, timer.ini, section, ColorAlert
    Gui, Color, %OffColor%
  }
RETURN

PopMenu:
  if ((Program1 = "ERROR") or (Program1 = "")) {
    progmen1b = Program 1: (Not set)
  } else {
    progmen1B = Program 1: %Program1%
  }
  if ((Program2 = "ERROR") or (Program2 = "")) {
    progmen2b = Program 2: (Not set)
  } else {
    progmen2B = Program 2: %Program2%
  }
  if ((Program3 = "ERROR") or (Program3 = "")) {
    progmen3b = Program 3: (Not set)
  } else {
    progmen3B = Program 3: %Program3%
  }
  if (progmen1 != progmen1B ) {
    Menu,MyMenu,Rename,%progmen1%,%progmen1B%
    progmen1 = %progmen1B%
  }
  if (progmen2 != progmen2B ) {
    Menu,MyMenu,Rename,%progmen2%,%progmen2B%
    progmen2 = %progmen2B%
  }
  if (progmen3 != progmen3B ) {
    Menu,MyMenu,Rename,%progmen3%,%progmen3B%
    progmen3 = %progmen3B%
  }
  timemenB = Timeout: %IdleTime%
  if (timemen != timemenB ) {
    Menu,MyMenu,Rename,%timemen%,%timemenB%
    timemen = %timemenB%
  }
  Menu, MyMenu, Show
RETURN

Prev:
StringSplit, LastTimeA, LastTime, `:
  H = %LastTimeA1%
  M = %LastTimeA2%
  S = %LastTimeA3%
  GuiControl,, MyText, %H%:%M%:%S%
  SetTimer, Update, 1000
RETURN

SetProgram:
  Gui, Font, S10 CDefault, Arial
  GuiControl, Font, MyText
  GuiControl,, MyText,Awaiting program...
  while (class = "AutoHotkeyGUI") {
  }
  Gui, Font, S20 CDefault Bold, Courier New
  GuiControl, Font, MyText
  GuiControl,, MyText, %H%:%M%:%S%
RETURN

SetProgram1:
  Gosub, SetProgram
  Program1 = %class%
  IniWrite, %class%, timer.ini, section, Program1
RETURN

SetProgram2:
  Gosub, SetProgram
  Program2 = %class%
  IniWrite, %class%, timer.ini, section, Program2
RETURN

SetProgram3:
  Gosub, SetProgram
  Program3 = %class%
  IniWrite, %class%, timer.ini, section, Program3
RETURN

SetTimeout:
  Gui, 2: Show,, Set Idle Timeout
RETURN

SetTimeoutOK:
  Gui, 2: Submit
  if NewTimeout is integer
    IdleTime = %NewTimeout%
  IniWrite, %IdleTime%, timer.ini, section, Timeout
RETURN

Update:

  if ((H * 60 + M >= 480) and (overWorked = 0)) {
    MsgBox, You are overworking. Get some rest...
    overWorked := 1
    ; ExitApp
  }

  ID := DllCall("GetParent", UInt,WinExist("A")), ID := !ID ? WinExist("A") : ID
  WinGetClass, class, ahk_id %ID%
  if ((class = Program1) or (class = Program2) or (class = Program3)) {
    ; Mouse buttons down and movement
    ProgramActive = 1
    ; LButton down only (very strict)
    ; GetKeyState, state, LButton
    ; if (state = "D") {
    ;   ProgramActive = 1
    ; } else {
    ;   ProgramActive = 0
    ; }
  } else {
    ProgramActive = 0
  }

  if (TimerActive = 0) and ( (A_TimeIdle > IdleTime*1000) or (ProgramActive = 0) ) {
    RETURN
  } else {
    if ( (A_TimeIdle > IdleTime*1000) or (ProgramActive = 0) ) {
      TimerActive = 0
      if (ColorAlert = "true")
        Gui, Color, %OffColor%
      Gui, Show, w%windowWidth% h%windowHeight% NA, WAITING
      RETURN
    }
    TimerActive = 1
    if (ColorAlert = "true") {
      if (H * 60 + M > 420) {
        Gui, Color, %OverColor%
      } else {
        Gui, Color, %OnColor%
      }
    }
    Gui, Show, w%windowWidth% h%windowHeight% NA, RUNNING

    if (Mod(M, 5) = 0) {
      ; Save time information every 5 minutes
      IniWrite, %H%:%M%:%S%, timer.ini, section, LastTime
    }

    if (S >= 59) {
      if (M >= 59) {
        M = 00
        H += 1.0
        GuiControl,, MyText, %H%:%M%:%S%
      } else {
        M += 1.0
      }
      S = 00
      GuiControl,, MyText, %H%:%M%:%S%
      RETURN
    }
    S += 1.0
    GuiControl,, MyText, %H%:%M%:%S%
    RETURN
  }
RETURN