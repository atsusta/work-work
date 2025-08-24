#Requires AutoHotkey v2.0
#SingleInstance Force

; 전역 변수 선언
global g := {}
g.IniFile := A_ScriptDir . "\timer.ini"
g.TimerActive := false
g.CurrentSeconds := 0
g.LastActivity := 0
g.WaitingForProgram := 0
g.Gui := ""
g.TimeText := ""
g.MenuGui := ""

; 기본값 설정
g.Programs := ["", "", "", "", ""]
g.Timeout := 2
g.OnColor := 0xB0FFFF
g.OffColor := 0xF07070
g.OverColor := 0xC9364C
g.PosX := 100
g.PosY := 100
g.LastTime := "00:00:00"

; 초기화
LoadSettings()
CreateGui()
SetTimer(UpdateTimer, 1000)
SetTimer(CheckActivity, 100)

; 종료 시 설정 저장
OnExit((*) => SaveSettings())

; 설정 파일 로드
LoadSettings() {
    if !FileExist(g.IniFile)
        return
        
    g.LastTime := IniRead(g.IniFile, "Settings", "LastTime", "00:00:00")
    g.Programs[1] := IniRead(g.IniFile, "Settings", "Program1", "")
    g.Programs[2] := IniRead(g.IniFile, "Settings", "Program2", "")
    g.Programs[3] := IniRead(g.IniFile, "Settings", "Program3", "")
    g.Programs[4] := IniRead(g.IniFile, "Settings", "Program4", "")
    g.Programs[5] := IniRead(g.IniFile, "Settings", "Program5", "")
    g.Timeout := Integer(IniRead(g.IniFile, "Settings", "Timeout", "2"))
    
    ; 색상 정보 로드 및 변환 (# 문자 없이 저장된 16진수 값)
    onColorStr := IniRead(g.IniFile, "Settings", "OnColor", "B0FFFF")
    offColorStr := IniRead(g.IniFile, "Settings", "OffColor", "F07070")
    overColorStr := IniRead(g.IniFile, "Settings", "OverColor", "C9364C")
    
    g.OnColor := Integer("0x" . onColorStr)
    g.OffColor := Integer("0x" . offColorStr)
    g.OverColor := Integer("0x" . overColorStr)
    
    ; 위치 정보 로드
    g.PosX := Integer(IniRead(g.IniFile, "Settings", "PositionX", "100"))
    g.PosY := Integer(IniRead(g.IniFile, "Settings", "PositionY", "100"))
}

; 설정 파일 저장
SaveSettings() {
    ; GUI 위치 가져오기
    if IsObject(g.Gui) {
        try {
            g.Gui.GetPos(&x, &y)
            g.PosX := x
            g.PosY := y
        }
    }
    
    IniWrite(FormatTime(g.CurrentSeconds), g.IniFile, "Settings", "LastTime")
    IniWrite(g.Programs[1], g.IniFile, "Settings", "Program1")
    IniWrite(g.Programs[2], g.IniFile, "Settings", "Program2")
    IniWrite(g.Programs[3], g.IniFile, "Settings", "Program3")
    IniWrite(g.Programs[4], g.IniFile, "Settings", "Program4")
    IniWrite(g.Programs[5], g.IniFile, "Settings", "Program5")
    IniWrite(g.Timeout, g.IniFile, "Settings", "Timeout")
    IniWrite(Format("{:06X}", g.OnColor), g.IniFile, "Settings", "OnColor")
    IniWrite(Format("{:06X}", g.OffColor), g.IniFile, "Settings", "OffColor")
    IniWrite(Format("{:06X}", g.OverColor), g.IniFile, "Settings", "OverColor")
    IniWrite(g.PosX, g.IniFile, "Settings", "PositionX")
    IniWrite(g.PosY, g.IniFile, "Settings", "PositionY")
}

; GUI 생성
CreateGui() {
    ; 메인 GUI
    g.Gui := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox", "Usage Timer")
    g.Gui.SetFont("s26", "Inter Display ExtraBold Italic")
    g.Gui.MarginX := 10
    g.Gui.MarginY := 10
    
    ; 시간 텍스트
    g.TimeText := g.Gui.Add("Text", "w200 Left", "00 : 00 : 00")
    
    ; 햄버거 메뉴 버튼
    MenuBtn := g.Gui.Add("Button", "x+10 w30 h30", "☰")
    MenuBtn.OnEvent("Click", (*) => ShowDropdownMenu())
    
    ; GUI 이벤트
    g.Gui.OnEvent("Close", (*) => GuiClose())
    
    ; 위치 설정 및 표시 - Show() 호출 후에 Move() 사용
    g.Gui.Show("Hide")  ; 먼저 숨긴 상태로 표시
    g.Gui.Move(g.PosX, g.PosY)  ; 위치 설정
    g.Gui.Show()  ; 다시 표시
    UpdateGuiColor()
}

; 풀다운 메뉴 표시
ShowDropdownMenu() {
    ; 메뉴 생성
    MainMenu := Menu()
    
    ; 메뉴 항목 추가
    MainMenu.Add("Resume previous time", (*) => ResumePreviousTime())
    MainMenu.Add() ; 구분선
    
    ; 프로그램 설정 메뉴
    Loop 5 {
        progInfo := g.Programs[A_Index]
        if progInfo != "" {
            ; 프로세스 정보가 있으면 프로세스 이름만 표시
            if InStr(progInfo, "|") {
                parts := StrSplit(progInfo, "|")
                progName := parts[1]
            } else {
                ; 이전 버전 호환성 (윈도우 제목)
                progName := progInfo
            }
        } else {
            progName := "Not Set"
        }
        
        ; 클로저를 위한 로컬 변수 생성
        idx := A_Index
        MainMenu.Add("Program " . idx . ": [" . progName . "]", ((i) => (*) => SetProgram(i))(idx))
    }
    
    MainMenu.Add() ; 구분선
    MainMenu.Add("Timeout: [" . g.Timeout . "]", (*) => SetTimeout())
    
    ; 메뉴 표시 (버튼 아래쪽에)
    MainMenu.Show()
}

; 메뉴 닫기 체크
CheckMenuClose() {
    if !IsObject(g.MenuGui)
        return
        
    if !WinActive("Menu ahk_id " . g.MenuGui.Hwnd) {
        try g.MenuGui.Destroy()
        g.MenuGui := ""
        SetTimer(CheckMenuClose, 0)
    }
}

; 이전 시간 복원
ResumePreviousTime() {
    g.CurrentSeconds := TimeStringToSeconds(g.LastTime)
    UpdateDisplay()
}

; 프로그램 설정
SetProgram(index) {
    g.WaitingForProgram := index
    ToolTip("Click on the program window you want to track for Program " . index)
    SetTimer((*) => ToolTip(), 3000)
}

; 타임아웃 설정
SetTimeout() {
    InputGui := Gui("+AlwaysOnTop", "Set Timeout")
    InputGui.Add("Text", , "Enter idle timeout in seconds:")
    TimeoutEdit := InputGui.Add("Edit", "w100", String(g.Timeout))
    OkBtn := InputGui.Add("Button", "w100", "OK")
    
    TimeoutOkClick(*) {
        newTimeout := TimeoutEdit.Text
        if IsInteger(newTimeout) && Integer(newTimeout) > 0 {
            g.Timeout := Integer(newTimeout)
        }
        InputGui.Destroy()
    }
    
    OkBtn.OnEvent("Click", TimeoutOkClick)
    
    InputGui.Show()
}

; 메뉴 닫기
CloseMenu() {
    if IsObject(g.MenuGui) {
        try g.MenuGui.Destroy()
        g.MenuGui := ""
        SetTimer(CheckMenuClose, 0)
    }
}

; 활동 체크
CheckActivity() {
    ; 프로그램 선택 대기 중인 경우
    if g.WaitingForProgram > 0 {
        if GetKeyState("LButton", "P") {
            try {
                activeWinID := WinGetID("A")
                processName := WinGetProcessName("ahk_id " . activeWinID)
                processPath := WinGetProcessPath("ahk_id " . activeWinID)
                ; 프로세스 이름과 경로를 함께 저장하여 더 정확한 식별
                g.Programs[g.WaitingForProgram] := processName . "|" . processPath
                ToolTip("Program " . g.WaitingForProgram . " set to: " . processName)
                g.WaitingForProgram := 0
                SetTimer((*) => ToolTip(), 2000)
            }
        }
        return
    }
    
    ; 현재 활성 창 확인
    try {
        activeWinID := WinGetID("A")
        currentProcessName := WinGetProcessName("ahk_id " . activeWinID)
        currentProcessPath := WinGetProcessPath("ahk_id " . activeWinID)
        currentProcess := currentProcessName . "|" . currentProcessPath
        
        isTrackedProgram := false
        
        ; 추적 대상 프로그램인지 확인 (프로세스 이름과 경로로 비교)
        Loop 5 {
            if g.Programs[A_Index] != "" {
                savedProcess := g.Programs[A_Index]
                ; 저장된 프로세스 정보와 현재 프로세스 정보 비교
                if savedProcess == currentProcess {
                    isTrackedProgram := true
                    break
                }
                ; 이전 버전 호환성을 위해 윈도우 제목으로도 확인
                try {
                    activeWinTitle := WinGetTitle("A")
                    if InStr(activeWinTitle, savedProcess) {
                        isTrackedProgram := true
                        break
                    }
                }
            }
        }
        
        currentTick := A_TickCount
        
        ; 추적 대상 프로그램이 활성화되어 있는 경우
        if isTrackedProgram {
            ; 키보드/마우스 활동 확인
            MouseGetPos(&mouseX, &mouseY)
            static lastMouseX := 0, lastMouseY := 0
            
            ; 키보드/마우스 입력 체크
            hasActivity := false
            
            ; 마우스 움직임 체크 (이제 활동으로 인정함)
            if mouseX != lastMouseX || mouseY != lastMouseY {
                hasActivity := true
                lastMouseX := mouseX
                lastMouseY := mouseY
            }
            
            ; 마우스 클릭 체크
            if GetKeyState("LButton", "P") || GetKeyState("RButton", "P") || GetKeyState("MButton", "P") {
                hasActivity := true
            }
            
            ; 키보드 입력 체크 (주요 키들)
            Loop 26 {
                if GetKeyState(Chr(64 + A_Index), "P") {
                    hasActivity := true
                    break
                }
            }
            
            ; 숫자키, 스페이스, 엔터 등 체크
            keys := ["Space", "Enter", "Tab", "Backspace", "Delete", "Ctrl", "Alt", "Shift"]
            Loop 10 {
                keys.Push(String(A_Index - 1))
            }
            
            for key in keys {
                if GetKeyState(key, "P") {
                    hasActivity := true
                    break
                }
            }
            
            ; 활동이 있으면 마지막 활동 시간 업데이트
            if hasActivity {
                g.LastActivity := currentTick
                if !g.TimerActive {
                    g.TimerActive := true
                    UpdateGuiColor()
                }
            } else {
                ; 추적 프로그램에서 입력이 없는 상태가 Timeout 시간 초과 시 타이머 정지
                if currentTick - g.LastActivity > g.Timeout * 1000 {
                    if g.TimerActive {
                        g.TimerActive := false
                        UpdateGuiColor()
                    }
                }
            }
        } else {
            ; 추적 대상이 아닌 프로그램으로 포커스가 변경된 경우
            ; 포커스가 변경된 시점부터 Timeout 시간이 지나면 타이머 정지
            static lastFocusChange := 0
            
            ; 포커스 변경 감지
            if g.TimerActive && lastFocusChange == 0 {
                lastFocusChange := currentTick
            }
            
            ; 포커스가 다른 프로그램으로 맞춰진 후 Timeout 시간이 지나면 타이머 정지
            if g.TimerActive && lastFocusChange > 0 && (currentTick - lastFocusChange > g.Timeout * 1000) {
                g.TimerActive := false
                UpdateGuiColor()
                lastFocusChange := 0
            }
            
            ; 추적 프로그램으로 다시 돌아오면 포커스 변경 타이머 리셋
            if !g.TimerActive && lastFocusChange > 0 {
                lastFocusChange := 0
            }
        }
    }
}

; 타이머 업데이트
UpdateTimer() {
    if g.TimerActive {
        g.CurrentSeconds++
    }
    UpdateDisplay()
}

; 디스플레이 업데이트
UpdateDisplay() {
    timeStr := FormatTime(g.CurrentSeconds)
    g.TimeText.Text := timeStr
    UpdateGuiColor()
}

; 시간 포맷
FormatTime(seconds) {
    hours := seconds // 3600
    minutes := (seconds - hours * 3600) // 60
    secs := seconds - hours * 3600 - minutes * 60
    return Format("{:02d} : {:02d} : {:02d}", hours, minutes, secs)
}

; 시간 문자열을 초로 변환
TimeStringToSeconds(timeStr) {
    parts := StrSplit(timeStr, ":")
    if parts.Length != 3
        return 0
    return Integer(parts[1]) * 3600 + Integer(parts[2]) * 60 + Integer(parts[3])
}

; GUI 색상 업데이트
UpdateGuiColor() {
    if !IsObject(g.Gui)
        return
        
    if g.TimerActive {
        if g.CurrentSeconds >= 28800 { ; 8시간 = 28800초
            g.Gui.BackColor := g.OverColor
        } else {
            g.Gui.BackColor := g.OnColor
        }
    } else {
        g.Gui.BackColor := g.OffColor
    }
}

; GUI 종료
GuiClose() {
    SaveSettings()
    ExitApp()
}

; 왼쪽 마우스 버튼 후킹 (프로그램 선택용)
~LButton::
{
    ; 프로그램 선택 모드에서만 처리
    if g.WaitingForProgram > 0 {
        Sleep(50) ; 클릭 완료 대기
        try {
            activeWinID := WinGetID("A")
            processName := WinGetProcessName("ahk_id " . activeWinID)
            processPath := WinGetProcessPath("ahk_id " . activeWinID)
            g.Programs[g.WaitingForProgram] := processName . "|" . processPath
            ToolTip("Program " . g.WaitingForProgram . " set to: " . processName)
            g.WaitingForProgram := 0
            SetTimer((*) => ToolTip(), 2000)
        }
    }
}