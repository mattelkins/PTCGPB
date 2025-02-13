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
Gui, Show, w500 h640, Arturo's PTCGPB Bot
Gui, Color, White
Gui, Font, s10 Bold, Segoe UI

Gui, Add, Button, gWindowsArrange x215 y208 w70 h32, Arrange Windows
Gui, Add, Text, x227 y258 w46 h32 BackgroundGreen
Gui, Add, Button, gStart x227 y258 w46 h32, Start

Gui, Add, Text, x0 y604 w640 h30 gOpenLink cBlue Center +BackgroundTrans
Gui, Add, Text, x265 y558 w167 h50 gOpenDiscord cBlue Center +BackgroundTrans

; Add the background image to the GUI.
Gui, Add, Picture, x0 y0 w500 h640, %A_ScriptDir%\Scripts\GUI\GUI.png

Gui, Font, s15 Bold , Segoe UI

; Add input controls.
if (Settings["FriendID"] = "ERROR")
    Gui, Add, Edit, vFriendID x80 y95 w145 h30 Center
else
    Gui, Add, Edit, vFriendID x80 y95 w145 h30 Center, % Settings["FriendID"]

if (Settings["runMain"])
    Gui, Add, CheckBox, Checked vrunMain x2 y95 Center, Main
else
    Gui, Add, CheckBox, vrunMain x2 y95 Center, Main

Gui, Add, Edit, vInstances x275 y95 w72 Center, % Settings["Instances"]
Gui, Add, Edit, vColumns x348 y95 w72 Center, % Settings["Columns"]

; Pack selection.
if (Settings["openPack"] = "Palkia") {
    defaultPack := 1
} else if (Settings["openPack"] = "Dialga") {
    defaultPack := 2
} else if (Settings["openPack"] = "Mew") {
    defaultPack := 3
}

Gui, Add, DropDownList, x80 y166 w145 vopenPack choose%defaultPack% Center, Palkia|Dialga|Mew|Mewtwo|Charizard|Pikachu


; Monitor selection
SysGet, MonitorCount, MonitorCount
MonitorOptions := ""
Loop, %MonitorCount% {
    SysGet, MonitorName, MonitorName, %A_Index%
    SysGet, Monitor, Monitor, %A_Index%
    MonitorOptions .= (A_Index > 1 ? "|" : "") "" A_Index ": (" MonitorRight - MonitorLeft "x" MonitorBottom - MonitorTop ")"

}
SelectedMonitorIndex := RegExReplace(Settings["SelectedMonitorIndex"], ":.*$")
Gui, Add, DropDownList, x275 y245 w145 vSelectedMonitorIndex choose%SelectedMonitorIndex%, %MonitorOptions%

Gui, Add, Edit, vDelay x80 y332 w145 Center, %Delay%
Gui, Add, Edit, vChangeDate x275 y332 w145 Center, % Settings["ChangeDate"]
Gui, Add, Edit, vswipeSpeed x348 y404 w72 Center, % Settings["swipeSpeed"]
Gui, Add, Edit, x275 y404 w72 vwaitTime Center, % Settings["waitTime"]

; Pack selection logic
if (Settings["skipInvalidGP"] = "No") {
    defaultskipGP := 1
} else if (Settings["skipInvalidGP"] = "Yes") {
    defaultskipGP := 2
}

Gui, Add, DropDownList, x80 y476 w145 vskipInvalidGP choose%defaultskipGP% Center, No|Yes

; Pack selection logic
if (Settings["deleteMethod"] = "3 Pack") {
    defaultDelete := 1
} else if (Settings["deleteMethod"] = "1 Pack") {
    defaultDelete := 2
} else if (Settings["deleteMethod"] = "Inject 1 Pack") {
    defaultDelete := 3
} else if (Settings["deleteMethod"] = "Inject 2 Pack") {
    defaultDelete := 4
}

Gui, Add, DropDownList, x80 y546 w145 vdeleteMethod choose%defaultDelete% Center, 3 Pack|1 Pack|Inject 1 Pack|Inject 2 Pack

Gui, Font, s10 Bold, Segoe UI

Gui, Add, Edit, vfolderPath x80 y404 w145 h35 Center, % Settings["folderPath"]

if (Settings["discordUserID"] = "ERROR")
    Gui, Add, Edit, vdiscordUserId x273 y476 w72 h35 Center
else
    Gui, Add, Edit, vdiscordUserId x273 y476 w72 h35 Center, % Settings["discordUserId"]

if (Settings["discordWebhookURL"] = "ERROR")
    Gui, Add, Edit, vdiscordWebhookURL x348 y476 w72 h35 Center
else
    Gui, Add, Edit, vdiscordWebhookURL x348 y476 w72 h35 Center, % Settings["discordWebhookURL"]

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
