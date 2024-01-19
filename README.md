# atsusta's AHK scripts

## Work.ahk
Working time counter based on [original script](https://neilblr.com/post/58757345346)

### 📝 Saving time information every N minutes
For unwanted situations like system crash, restart, or something else
* Saves `LastTime` in INI file
* _Default: 5 minutes_

### 🅰️ Fonts
For better readability
* **[Inter V Black Italic (Default)](https://rsms.me/inter/)**
* Segoe UI Bold Italic
* [DS-Digital Bold Italic](https://fontmeme.com/fonts/ds-digital-font/)
* [Arcade Normal](https://www.urbanfonts.com/fonts/Arcade_Normal.font)
* [MxPlus IBM VGA 8x16](https://int10h.org/oldschool-pc-fonts/download/)
* [NeoDunggeunmo](https://neodgm.dalgona.dev)
* [Amiga Forever Pro2](https://www.ffonts.net/Amiga-Forever-Pro2.font.download)

#### ❓ How to change font
Leave 2 code blocks and comment any others in `Work.ahk`

```ahk
; Select font: Leave 2 code blocks and comment any others
; Gui, Font, ...
; Gui, Add, ...
Gui, Font, ...
Gui, Add, ...
; Gui, Font, ...
; Gui, Add, ...
```

### 🍔 New menu icon
Unicode character 'TIGRAM FOR HEAVEN' (	☰)
* Position: 0x2630
* Decimal: 9776

### ⏰ Additional color alert
For Work & Life balance
* Window color changes after target time
* _Default: 7 hours_

#### ❓ How to change color
* Change HEX code value of `OverColor` in INI file
* Use HEX code for changing color

```ini
[section]
ColorAlert=true
OnColor=9D9DFC
OffColor=e58549
OverColor=c95ee0
LastTime=02:20:52
Timeout=2
Program1=Photoshop
Program2=OWL.DocumentWindow
Program3=PSFilter_WindowClass
```

### 💬 Alert message for overworking
For Work & Life balance
* Alerts you after target time
* _Default: 8 hours_

## Remaps.ahk
Some useful keyboard remaps
* Shift + Space for changing language (Hangeul/English)
* Replace Capslock for Ctrl
* And others...

## top.ps1
Graphical performance information for PowerShell. Source is [here](https://yvez.be/2019/09/01/lets-create-top-for-powershell/#code).

## Beatcon-to-keyboard.ahk
Rhythm game controller inputs to keyboard mapping.