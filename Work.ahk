; This script is a simple timer that tracks active time based on user-defined programs and idle time.
; It shows a transparent window with a clock and changes color based on activity and time.
; It is a complete conversion from AHK v1.0 to v2.0.

; Variable declarations and INI file reads.
; IniRead() and IniWrite() are functions in v2.0.
global
IdleTime := IniRead("timer.ini", "section", "Timeout", 10)
Program1 := IniRead("timer.ini", "section", "Program1")
Program2 := IniRead("timer.ini", "section", "Program2")
Program3 := IniRead("timer.ini", "section", "Program3")
LastTime := IniRead("timer.ini", "section", "LastTime", "00:00:00")
ColorAlert := IniRead("timer.ini", "section", "ColorAlert", "true")
OnColor := IniRead("timer.ini", "section", "OnColor", "B0FFFF")
OffColor := IniRead("timer.ini", "section", "OffColor", "F07070")
OverColor := IniRead("timer.ini", "section", "OverColor", "c9364c")
PositionX := IniRead("timer.ini", "section", "positionX", 100)
PositionY := IniRead("timer.ini", "section", "positionY", 100)

TimerActive := 1
menuX := 210
menuY := 11
menuHeight := 30
windowWidth := 240
windowHeight := 50
overWorked := 0
H := 0, M := 0, S := 0

; Main script logic starts here. No more GOTO.
; This code runs on startup.

; GUI 1: The main timer window.
MyGui := Gui("+AlwaysOnTop", "MEMENTO MORI")
MyGui.Opt("-MinimizeBox -MaximizeBox")
MyGui.BackColor := OnColor

; Font selection for the timer text.
; MyGui.Font("S26", "Segoe UI Bold")
; MyGui.Add("Text", "x8 y0 vMyText", "--------------")
MyGui.Font("S26", "Inter Display ExtraBold Italic")
MyGui.Add("Text", "x5 y5 vMyText", "------------")

; Menu button icon.
MyGui.Font("S14", "Calibri")
menuIcon := Chr(0x2630)
MyGui.Add("Button", "x" menuX " y" menuY " h" menuHeight " gPopMenu", menuIcon)

; Start the timer.
SetTimer "Update", 1000
Update()
MyGui.Show("x" PositionX " y" PositionY " w" windowWidth " h" windowHeight)

; GUI 2: The timeout configuration window.
SetTimeoutGui := Gui("+AlwaysOnTop", "Set Idle Timeout")
SetTimeoutGui.Add("Text", "x8 y7", "Enter idle timeout in seconds:")
SetTimeoutGui.Add("Edit", "y5 vNewTimeout w25", "")
SetTimeoutGui.Add("Button", "gSetTimeoutOK Default", "Set")
SetTimeoutGui.Opt("-Caption -Border -Resize -SysMenu")


; Menu definition.
MyMenu := Menu()
MyMenu.Add("Resume previous time", "Prev")
MyMenu.Add()
MyMenu.Add("Program 1: " Program1, "SetProgram1")
MyMenu.Add("Program 2: " Program2, "SetProgram2")
MyMenu.Add("Program 3: " Program3, "SetProgram3")
MyMenu.Add()
MyMenu.Add("Timeout: " IdleTime, "SetTimeout")
MyMenu.Add()
MyMenu.Add("Color Alert", "ChangeColor")
if (ColorAlert = "true") {
    MyMenu.Check("Color Alert")
}

; Function to handle the main GUI close event.
MyGui.OnEvent("Close", GuiClose)

; --- Functions start here ---

GuiClose() {
    global
    MyGui.GetPos(&currentPositionX, &currentPositionY)
    IniWrite(currentPositionX, "timer.ini", "section", "PositionX")
    IniWrite(currentPositionY, "timer.ini", "section", "PositionY")
    IniWrite(H ":" M ":" S, "timer.ini", "section", "LastTime")
    ExitApp
}

ChangeColor() {
    global
    if (ColorAlert = "true") {
        MyMenu.Uncheck("Color Alert")
        ColorAlert := "false"
        IniWrite("false", "timer.ini", "section", "ColorAlert")
        MyGui.BackColor := OnColor
    } else {
        MyMenu.Check("Color Alert")
        ColorAlert := "true"
        IniWrite("true", "timer.ini", "section", "ColorAlert")
        IniWrite(OnColor, "timer.ini", "section", "OnColor")
        IniWrite(OffColor, "timer.ini", "section", "OffColor")
        IniWrite(OverColor, "timer.ini", "section", "OverColor")
        MyGui.BackColor := OffColor
    }
}

PopMenu() {
    global
    
    ; The menu labels are now dynamic and will be updated.
    progmen1B := (Program1 = "ERROR" or Program1 = "") ? "Program 1: (Not set)" : "Program 1: " Program1
    progmen2B := (Program2 = "ERROR" or Program2 = "") ? "Program 2: (Not set)" : "Program 2: " Program2
    progmen3B := (Program3 = "ERROR" or Program3 = "") ? "Program 3: (Not set)" : "Program 3: " Program3
    timemenB := "Timeout: " IdleTime

    MyMenu.Rename("Program 1: " Program1, progmen1B)
    MyMenu.Rename("Program 2: " Program2, progmen2B)
    MyMenu.Rename("Program 3: " Program3, progmen3B)
    MyMenu.Rename("Timeout: " IdleTime, timemenB)
    
    Program1 := progmen1B
    Program2 := progmen2B
    Program3 := progmen3B
    IdleTime := timemenB

    MyMenu.Show()
}

Prev() {
    global
    ; Split the LastTime string into an array.
    lastTimeParts := StrSplit(LastTime, ":")
    H := lastTimeParts[1], M := lastTimeParts[2], S := lastTimeParts[3]
    MyGui["MyText"].Value := Format("{:02} : {:02} : {:02}", H, M, S)
    SetTimer "Update", 1000
}

SetProgram1() {
    global
    class := WinGetClass("A")
    while (class = "AutoHotKeyGUI") {
        MyGui["MyText"].Value := "Select App"
        Sleep 1000
        class := WinGetClass("A")
        if (class != "AutoHotKeyGUI" and class != "") {
            Program1 := class
            IniWrite(class, "timer.ini", "section", "Program1")
            title := WinGetTitle("A")
            MsgBox(title)
            MyGui["MyText"].Value := Format("{:02} : {:02} : {:02}", H, M, S)
            Break
        }
    }
}

SetProgram2() {
    global
    class := WinGetClass("A")
    while (class = "AutoHotKeyGUI") {
        MyGui["MyText"].Value := "Select App"
        Sleep 1000
        class := WinGetClass("A")
        if (class != "AutoHotKeyGUI" and class != "") {
            Program2 := class
            IniWrite(class, "timer.ini", "section", "Program2")
            title := WinGetTitle("A")
            MsgBox(title)
            MyGui["MyText"].Value := Format("{:02} : {:02} : {:02}", H, M, S)
            Break
        }
    }
}

SetProgram3() {
    global
    class := WinGetClass("A")
    while (class = "AutoHotKeyGUI") {
        MyGui["MyText"].Value := "Select App"
        Sleep 1000
        class := WinGetClass("A")
        if (class != "AutoHotKeyGUI" and class != "") {
            Program3 := class
            IniWrite(class, "timer.ini", "section", "Program3")
            title := WinGetTitle("A")
            MsgBox(title)
            MyGui["MyText"].Value := Format("{:02} : {:02} : {:02}", H, M, S)
            Break
        }
    }
}

SetTimeout() {
    global
    SetTimeoutGui.Show()
}

SetTimeoutOK() {
    global
    ; Get value from the GUI control.
    timeoutVal := SetTimeoutGui.NewTimeout.Value
    
    ; Check if the value is a number.
    if IsNumber(timeoutVal) {
        IdleTime := timeoutVal
    }
    IniWrite(IdleTime, "timer.ini", "section", "Timeout")
    SetTimeoutGui.Hide()
}

Update() {
    global
    ; Check if 8 hours (480 minutes) of work time have passed.
    if ((H * 60 + M >= 480) and (overWorked = 0)) {
        MsgBox("You are overworking. Get some rest...")
        overWorked := 1
    }

    ; Get the class of the active window.
    activeWindowId := WinExist("A")
    ; Handle parent windows (e.g., child windows like dialog boxes)
    parentWindowId := DllCall("user32\GetParent", "ptr", activeWindowId, "ptr")
    idToCheck := (parentWindowId = 0) ? activeWindowId : parentWindowId
    class := WinGetClass("ahk_id " idToCheck)

    ; Check if the active window is one of the designated programs.
    ProgramActive := 0
    if (class = Program1 or class = Program2 or class = Program3) {
        ProgramActive := 1
    }

    ; If the timer is inactive OR the user is idle/not in a designated program, stop the timer.
    if (TimerActive = 0 and (A_TimeIdle > IdleTime * 1000 or ProgramActive = 0)) {
        return
    } else {
        if (A_TimeIdle > IdleTime * 1000 or ProgramActive = 0) {
            TimerActive := 0
            if (ColorAlert = "true") {
                MyGui.BackColor := OffColor
            }
            MyGui.Title := "WAITING"
            MyGui.Show("w" windowWidth " h" windowHeight " NA")
            return
        }
        
        TimerActive := 1
        if (ColorAlert = "true") {
            if (H * 60 + M > 420) {
                MyGui.BackColor := OverColor
            } else {
                MyGui.BackColor := OnColor
            }
        }
        MyGui.Title := "RUNNING"
        MyGui.Show("w" windowWidth " h" windowHeight " NA")

        ; Save status to INI file every 5 minutes.
        if (Mod(M, 5) = 0) {
            MyGui.GetPos(&currentPositionX, &currentPositionY)
            IniWrite(currentPositionX, "timer.ini", "section", "PositionX")
            IniWrite(currentPositionY, "timer.ini", "section", "PositionY")
            IniWrite(H ":" M ":" S, "timer.ini", "section", "LastTime")
            IniWrite(OnColor, "timer.ini", "section", "OnColor")
            IniWrite(OffColor, "timer.ini", "section", "OffColor")
            IniWrite(OverColor, "timer.ini", "section", "OverColor")
        }

        ; Increment the timer.
        S += 1
        if (S >= 60) {
            S := 0
            M += 1
            if (M >= 60) {
                M := 0
                H += 1
            }
        }
        MyGui["MyText"].Value := Format("{:02} : {:02} : {:02}", H, M, S)
    }
}
