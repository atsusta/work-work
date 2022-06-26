# atsusta's AHK scripts

## Work.ahk
Working time counter based on [original script](https://neilblr.com/post/58757345346)

### New Features

#### 📝 Added Saving time information 
For unwanted situations like system crash, restart, or something else
* Saves `LastTime` in INI file
* _Default: 5 minutes_

#### 🅰️ Changed font
For better readability
* **Inter V Black Italic (Default)**
* Segoe UI Bold Italic
* DS-Digital Bold Italic
* Arcade Normal
* PxPlus IBM VGA8
* NeoDunggeunmo
* Amiga Forever Pro2

##### ❓ How to change font
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

#### 🍔 Changed menu icon to hamburger
Unicode character 'TIGRAM FOR HEAVEN' (	☰)
* Position: 0x2630
* Decimal: 9776

#### ⏰ Added new color alert
For Work & Life balance
* Window color changes after target time
* _Default: 7 hours_

##### ❓ How to change color
* Change HEX code value of `OverColor` in INI file
* Use HEX code for changing color

```ini
[section]
ColorAlert=true
OnColor=E3C3C1
OffColor=9D9DFC
OverColor=c95ee0
LastTime=02:05:59
Timeout=2
```

#### 💬 Added alert message for overworking
For Work & Life balance
* Alerts you after target time
* _Default: 8 hours_

## Remaps.ahk
Some useful keyboard remaps
* Shift + space for changing language
* Replace Capslock for Ctrl
* And others...
