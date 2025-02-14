#Include %A_ScriptDir%\Scripts\Include\Settings.ahk
#Include %A_ScriptDir%\Scripts\Include\Files.ahk
#Include %A_ScriptDir%\Scripts\Include\Windows.ahk
#Include %A_ScriptDir%\Scripts\Include\Logging.ahk
#Include %A_ScriptDir%\Scripts\Include\Utils.ahk

version = Arturos PTCGP Bot
#SingleInstance Force
CoordMode, Mouse, Screen
SetTitleMatchMode, 3

if !A_IsAdmin {
    ; Relaunch script with admin permissions.
    Run *RunAs %A_ScriptFullPath%
    ExitApp
}

global Settings

; Init JSON files.
FileTotalInit()
FilePacksInit()

; Load settings.
Settings := SettingsRead()

; Main GUI setup.
Gui, Show, w500 h698, Arturo's PTCGP Bot
Gui, Color, White
Gui, Font, s10, Segoe UI

; Add input controls.
guiControlWidth := 140
guiControlMaxHeight := 26

; - Header, Column 1
guiControlMarginX := 95
guiControlMarginY := 58

; FriendID
if (Settings["FriendID"] = "ERROR")
    Gui, Add, Edit, vFriendID x%guiControlMarginX% y%guiControlMarginY% w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans
else
    Gui, Add, Edit, vFriendID x%guiControlMarginX% y%guiControlMarginY% w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans, % Settings["FriendID"]

; - Header, Column 2
guiControlMarginX := 330
guiControlMarginY := 58

if (Settings["discordUserID"] = "ERROR")
    Gui, Add, Edit, vdiscordUserId x%guiControlMarginX% y%guiControlMarginY% w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans
else
    Gui, Add, Edit, vdiscordUserId x%guiControlMarginX% y%guiControlMarginY% w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans, % Settings["discordUserId"]

; - Top, Column 1
guiControlWidth := 150
guiControlMaxWidth := 360
guiControlMarginX := 70
guiControlMarginY := 107

; runMain
if (Settings["runMain"])
    Gui, Add, CheckBox, Checked vrunMain x%guiControlMarginX% y%guiControlMarginY%, % "Run Main instance?"
else
    Gui, Add, CheckBox, vrunMain x%guiControlMarginX% y%guiControlMarginY%, % "Run Main instance?"

; Instances
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Reroll Instances:"
Gui, Add, Edit, vInstances x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans, % Settings["Instances"]

; Columns
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Columns:"
Gui, Add, Edit, vColumns x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans, % Settings["Columns"]

; folderPath
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "MuMu Folder:"
Gui, Add, Edit, vfolderPath x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight%, % Settings["folderPath"]

; SelectedMonitorIndex
SysGet, MonitorCount, MonitorCount
MonitorOptions := ""
Loop, %MonitorCount% {
    SysGet, MonitorName, MonitorName, %A_Index%
    SysGet, Monitor, Monitor, %A_Index%
    MonitorOptions .= (A_Index > 1 ? "|" : "") "" A_Index ": (" MonitorRight - MonitorLeft "x" MonitorBottom - MonitorTop ")"
}
SelectedMonitorIndex := RegExReplace(Settings["SelectedMonitorIndex"], ":.*$")

Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Monitor:"
Gui, Add, DropDownList, x%guiControlMarginX% y+5 w%guiControlWidth% vSelectedMonitorIndex choose%SelectedMonitorIndex%, %MonitorOptions%

; - Top, Column 2
guiControlMarginX := 280
guiControlMarginY := 133

; Delay
Gui, Add, Text, x%guiControlMarginX% y%guiControlMarginY% BackgroundTrans, % "Delay:"
Gui, Add, Edit, vDelay x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight%, %Delay%

; ChangeDate
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Refresh Time (HHMM):"
Gui, Add, Edit, vChangeDate x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight%, % Settings["ChangeDate"]

; swipeSpeed
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Swipe Speed:"
Gui, Add, Edit, vswipeSpeed x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight%, % Settings["swipeSpeed"]

; waitTime
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Friend Add Wait Time (s):"
Gui, Add, Edit, vwaitTime x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight%, % Settings["waitTime"]

; - Middle, Column 1
guiControlMarginX := 70
guiControlMarginY := 375

; openPack
if (Settings["openPack"] = "Palkia") {
    defaultPack := 1
} else if (Settings["openPack"] = "Dialga") {
    defaultPack := 2
} else if (Settings["openPack"] = "Mew") {
    defaultPack := 3
}

Gui, Add, Text, x%guiControlMarginX% y%guiControlMarginY% BackgroundTrans, % "Open Pack:"
Gui, Add, DropDownList, vopenPack x%guiControlMarginX% y+5 w%guiControlWidth% choose%defaultPack%, Palkia|Dialga|Mew

; skipInvalid
if (Settings["skipInvalidGP"] = "No") {
    defaultskipGP := 1
} else if (Settings["skipInvalidGP"] = "Yes") {
    defaultskipGP := 2
}

Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Skip Immersive/Crown Packs:"
Gui, Add, DropDownList, vskipInvalidGP x%guiControlMarginX% y+5 w%guiControlWidth% choose%defaultskipGP%, No|Yes

; deleteMethod
if (Settings["deleteMethod"] = "3 Pack") {
    defaultDeleteMethod := 1
} else if (Settings["deleteMethod"] = "1 Pack") {
    defaultDeleteMethod := 2
} else if (Settings["deleteMethod"] = "Inject 1 Pack") {
    defaultDeleteMethod := 3
} else if (Settings["deleteMethod"] = "Inject 2 Pack") {
    defaultDeleteMethod := 4
}

Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Method:"
Gui, Add, DropDownList, vdeleteMethod x%guiControlMarginX% y+5 w%guiControlWidth% choose%defaultDeleteMethod%, 3 Pack|1 Pack|Inject 1 Pack|Inject 2 Pack

; discordWebhookURL
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Discord Webhook URL:"
if (Settings["discordWebhookURL"] = "ERROR")
    Gui, Add, Edit, vdiscordWebhookURL x%guiControlMarginX% y+5 w%guiControlMaxWidth% h%guiControlMaxHeight%
else
    Gui, Add, Edit, vdiscordWebhookURL x%guiControlMarginX% y+5 w%guiControlMaxWidth% h%guiControlMaxHeight%, % Settings["discordWebhookURL"]

; - Middle, Column 2
guiControlMarginX := 280
guiControlMarginY := 375

Gui, Add, Text, x%guiControlMarginX% y%guiControlMarginY% BackgroundTrans, % "Find Pokemon:"
Gui, Add, ListBox, vfindPokemon x%guiControlMarginX% y+5 w%guiControlWidth% r8 multi, Golem|Marshadow|Mew|Raichu|Serperior|Tauros|Vaporeon|Volcarona|---|Aerodactyl ex|Celebi ex|Gyarados ex|Mew ex|Pidgeot ex

; - Bottom (Buttons)

Gui, Add, Text, gWindowsArrange x175 y627 w153 h27 BackgroundTrans
Gui, Add, Text, gStart x360 y627 w100 h27 BackgroundTrans

; Add background picture.
Gui, Add, Picture, x0 y0 w500 h698, %A_ScriptDir%\Assets\GUI\Background.png

; Show the GUI and return.
Gui, Show
return



Start:
    global Settings

    ; Save settings.
    Settings := SettingsWrite()

    ; Submit and close GUI.
    Gui, Submit
    Gui, Destroy

    ; Download a file to use for ids.txt if required.
    if (inStr(Settings["FriendID"], "https"))
        FileDownload(Settings["FriendID"], A_ScriptDir . "ids.txt")

    ; Run main if required.
    if (Settings["runMain"]) {
        runFile := A_ScriptDir . "Scripts\Main.ahk"
        Run, %runFile%
    }

    ; Loop to run script for each instance.
    Loop, Settings["Instances"] {
        if (A_Index > 1) {
            ; Path to the source .ahk file.
            sourceFile := A_ScriptDir . "Scripts\1.ahk"

            ; Generate target file path.
            targetFile := A_ScriptDir . "Scripts\" . A_Index . ".ahk"

            ; Copy source file to target.
            FileCopy, %sourceFile%, %targetFile%, 1

            if (ErrorLevel)
                MsgBox, Failed to create %targetFile%. Ensure permissions and paths are correct.
        }

        runFile := A_ScriptDir . "Scripts\" . A_Index . ".ahk"

        Run, %runFile%
    }

    ; Reroll status loop.
    rerollTime := A_TickCount
    Loop {
        Sleep, 30000

        ; Sum all variable values and write to total.json.
        totalPacks := FilePacksSum()

        ; Total time in seconds and minutes.
        totalSeconds := Round((A_TickCount - rerollTime) / 1000)
        totalMinutes := Floor(totalSeconds / 60)

        ; Set pack status message.
        packStatus := "Time: " . totalMinutes . "m Packs: " . totalPacks
        CreateStatusMessage(packStatus, 287, 490)
    }
return

GuiClose:
    ExitApp

~F7::ExitApp
