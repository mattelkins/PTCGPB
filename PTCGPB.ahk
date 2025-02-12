#Include %A_ScriptDir%\Scripts\Include\Settings.ahk

version = Arturos PTCGP Bot
#SingleInstance Force
CoordMode, Mouse, Screen
SetTitleMatchMode, 3

if !A_IsAdmin
{
    ; Relaunch script with admin permissions.
    Run *RunAs %A_ScriptFullPath%
    ExitApp
}

; Declare globals.
global Settings, Instances, jsonFileName, PacksText, runMain

; Init JSON files.
totalFile := A_ScriptDir . "\json\total.json"
backupFile := A_ScriptDir . "\json\total-backup.json"
if FileExist(totalFile) ; Check if the file exists
{
    FileCopy, %totalFile%, %backupFile%, 1 ; Copy source file to target
    if (ErrorLevel)
        MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
}
FileDelete, %totalFile%
packsFile := A_ScriptDir . "\json\Packs.json"
backupFile := A_ScriptDir . "\json\Packs-backup.json"
if FileExist(packsFile) ; Check if the file exists
{
    FileCopy, %packsFile%, %backupFile%, 1 ; Copy source file to target
    if (ErrorLevel)
        MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
}
InitializeJsonFile() ; Create or open the JSON file

; Load settings.
Settings := SettingsRead()

Instances := Settings["Instances"]
runMain := Settings["runMain"]









; Main GUI setup.
Gui, Show, w500 h640, Arturo's PTCGPB Bot
Gui, Color, White
Gui, Font, s10 Bold, Segoe UI

Gui, Add, Button, gArrangeWindows x215 y208 w70 h32, Arrange Windows
Gui, Add, Text, x227 y258 w46 h32 BackgroundGreen
Gui, Add, Button, gStart x227 y258 w46 h32, Start

Gui, Add, Text, x0 y604 w640 h30 gOpenLink cBlue Center +BackgroundTrans
Gui, Add, Text, x265 y558 w167 h50 gOpenDiscord cBlue Center +BackgroundTrans

; Add the background image to the GUI.
Gui, Add, Picture, x0 y0 w500 h640, %A_ScriptDir%\Scripts\GUI\GUI.png

Gui, Font, s15 Bold , Segoe UI

; Add input controls
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

; Pack selection logic
if (Settings["openPack"] = "Palkia") {
    defaultPack := 1
} else if (Settings["openPack"] = "Dialga") {
    defaultPack := 2
} else if (Settings["openPack"] = "Mew") {
    defaultPack := 3
}

Gui, Add, DropDownList, x80 y166 w145 vopenPack choose%defaultPack% Center, Palkia|Dialga|Mew
global scaleParam

if (Settings["defaultLanguage"] = "Scale125") {
    defaultLang := 1
    scaleParam := 277
} else if (Settings["defaultLanguage"] = "Scale100") {
    defaultLang := 2
    scaleParam := 287
}

Gui, Add, DropDownList, x80 y245 w145 vdefaultLanguage choose%defaultLang%, Scale125

; Initialize monitor dropdown options
SysGet, MonitorCount, MonitorCount
MonitorOptions := ""
Loop, %MonitorCount%
{
    SysGet, MonitorName, MonitorName, %A_Index%
    SysGet, Monitor, Monitor, %A_Index%
    MonitorOptions .= (A_Index > 1 ? "|" : "") "" A_Index ": (" MonitorRight - MonitorLeft "x" MonitorBottom - MonitorTop ")"

}
SelectedMonitorIndex := RegExReplace(Settings["SelectedMonitorIndex"], ":.*$")
Gui, Add, DropDownList, x275 y245 w145 vSelectedMonitorIndex choose%SelectedMonitorIndex%, %MonitorOptions%

Gui, Add, Edit, vDelay x80 y332 w145 Center, %Delay%
Gui, Add, Edit, vChangeDate x275 y332 w145 Center, % Settings["ChangeDate"]

; Speed selection logic
; if (setSpeed = "2x") {
    ; defaultSpeed := 1
; } else if (setSpeed = "1x/2x") {
    ; defaultSpeed := 2
; } else if (setSpeed = "1x/3x") {
    ; defaultSpeed := 3
; }
; Gui, Add, DropDownList, x275 y404 w72 vsetSpeed choose%defaultSpeed% Center, 2x|1x/2x|1x/3x


Gui, Add, Edit, vswipeSpeed x348 y404 w72 Center, % Settings["swipeSpeed"]


; Pack selection logic
; if (godPack = "Close") {
    ; defaultgodPack := 1
; } else if (godPack = "Pause") {
    ; defaultgodPack := 2
; } else if (godPack = "Continue") {
    ; defaultgodPack := 3
; }

; Gui, Add, DropDownList, x275 y166 w145 vgodPack choose%defaultgodPack% Center, Close|Pause|Continue

if (!CardCheck)
    CardCheck = "Only God Packs"
defaultCardCheck := 1
if (TrainerCheck = "Yes" && FullArtCheck = "Yes" && RainbowCheck = "Yes")
    defaultCardCheck := 2      ; All
else if (TrainerCheck = "Yes" && FullArtCheck = "Yes")
    defaultCardCheck := 3      ; Trainer+Normal
else if (TrainerCheck = "Yes" && RainbowCheck = "Yes")
    defaultCardCheck := 4      ; Trainer+Rainbow
else if (FullArtCheck = "Yes" && RainbowCheck = "Yes")
    defaultCardCheck := 5      ; Normal+Rainbow
else if (TrainerCheck = "Yes")
    defaultCardCheck := 6      ; Trainer
else if (FullArtCheck = "Yes")
    defaultCardCheck := 7      ; Normal
else if (RainbowCheck = "Yes")
    defaultCardCheck := 8      ; Rainbow

Gui, Add, DropDownList, x275 y166 w145 vCardCheck choose%defaultCardCheck% Center, Only God Packs|All|Trainer+Full Art|Trainer+Rainbow|Full Art+Rainbow|Trainer|Full Arts|Rainbow

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

Gui, Add, DropDownList, x80 y546 w145 vdeleteMethod choose%defaultDelete% Center gdeleteSettings, 3 Pack|1 Pack|Inject 1 Pack|Inject 2 Pack

Gui, Font, s10 Bold, Segoe UI
if (InStr(Settings["deleteMethod"], "Inject"))
    if (Settings["nukeAccount"])
        Gui, Add, CheckBox, Checked vnukeAccount x2 y546 Center Hidden, Menu `nDelete
    else
        Gui, Add, CheckBox, vnukeAccount x2 y546 Center Hidden, Menu `nDelete
else
    if (Settings["nukeAccount"])
        Gui, Add, CheckBox, Checked vnukeAccount x2 y546 Center, Menu `nDelete
    else
        Gui, Add, CheckBox, vnukeAccount x2 y546 Center, Menu `nDelete

Gui, Add, Edit, vfolderPath x80 y404 w145 h35 Center, % Settings["folderPath"]

if (Settings["discordUserID"] = "ERROR")
    Gui, Add, Edit, vdiscordUserId x273 y476 w72 h35 Center
else
    Gui, Add, Edit, vdiscordUserId x273 y476 w72 h35 Center, % Settings["discordUserId"]

if (Settings["discordWebhookURL"] = "ERROR")
    Gui, Add, Edit, vdiscordWebhookURL x348 y476 w72 h35 Center
else
    Gui, Add, Edit, vdiscordWebhookURL x348 y476 w72 h35 Center, % Settings["discordWebhookURL"]

if (Settings["heartBeatName"] = "ERROR")
    Settings["heartBeatName"] =

if (Settings["heartBeatWebhookURL"] = "ERROR")
    Settings["heartBeatWebhookURL"] =

if (Settings["heartBeat"]) {
    Gui, Add, CheckBox, Checked vheartBeat x273 y512 Center gdiscordSettings, Discord Heartbeat
    Gui, Add, Edit, vheartBeatName x273 y532 w72 h20 Center, % Settings["heartBeatName"]
    Gui, Add, Edit, vheartBeatWebhookURL x348 y532 w72 h20 Center, % Settings["heartBeatWebhookURL"]
}
else {
    Gui, Add, CheckBox, vheartBeat x273 y512 Center gdiscordSettings, Discord Heart Beat
    Gui, Add, Edit, vheartBeatName x273 y532 w72 h20 Center Hidden, % Settings["heartBeatName"]
    Gui, Add, Edit, vheartBeatWebhookURL x348 y532 w72 h20 Center Hidden, % Settings["heartBeatWebhookURL"]
}

; Show the GUI
Gui, Show
return






discordSettings:
    Gui, Submit, NoHide

    if (heartBeat) {
        GuiControl, Show, heartBeatName
        GuiControl, Show, heartBeatWebhookURL
    }
    else {
        GuiControl, Hide, heartBeatName
        GuiControl, Hide, heartBeatWebhookURL
    }
return

deleteSettings:
    Gui, Submit, NoHide

    if (InStr(deleteMethod, "Inject")) {
        GuiControl, Hide, nukeAccount
        nukeAccount = false
    }
    else
        GuiControl, Show, nukeAccount
return

ArrangeWindows:
    GuiControlGet, runMain,, runMain
    GuiControlGet, Instances,, Instances
    GuiControlGet, Columns,, Columns
    GuiControlGet, SelectedMonitorIndex,, SelectedMonitorIndex
    Loop %Instances% {
        resetWindows(A_Index, SelectedMonitorIndex)
        sleep, 10
    }
return

; Handle the link click
OpenLink:
    Run, https://buymeacoffee.com/aarturoo
return

OpenDiscord:
    Run, https://discord.gg/C9Nyf7P4sT
return

Start:
Gui, Submit
Gui, Destroy

; Save settings.
SettingsWrite()

; Loop to process each instance
Instances := Settings["Instances"]
Loop, %Instances%
{
    if (A_Index != 1) {
        SourceFile := "Scripts\1.ahk" ; Path to the source .ahk file
        TargetFolder := "Scripts\" ; Path to the target folder
        TargetFile := TargetFolder . A_Index . ".ahk" ; Generate target file path
        FileCopy, %SourceFile%, %TargetFile%, 1 ; Copy source file to target
        if (ErrorLevel)
            MsgBox, Failed to create %TargetFile%. Ensure permissions and paths are correct.
    }

    FileName := "Scripts\" . A_Index . ".ahk"
    Command := FileName

    Run, %Command%
}
if (runMain) {
    FileName := "Scripts\Main.ahk"
    Run, %FileName%
}
if (inStr(FriendID, "https"))
    DownloadFile(FriendID, "ids.txt")
SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
SysGet, Monitor, Monitor, %SelectedMonitorIndex%
rerollTime := A_TickCount
Loop {
    Sleep, 30000
    ; Sum all variable values and write to total.json
    total := SumVariablesInJsonFile()
    totalSeconds := Round((A_TickCount - rerollTime) / 1000) ; Total time in seconds
    mminutes := Floor(totalSeconds / 60)
    if (total = 0)
    total := "0                             "
    packStatus := "Time: " . mminutes . "m Packs: " . total
    CreateStatusMessage(packStatus, 287, 490)
    if (heartBeat)
        if ((A_Index = 1 || (Mod(A_Index, 60) = 0))) {
            onlineAHK := "Online: "
            offlineAHK := "Offline: "
            Online := []
            if (runMain) {
                IniRead, value, HeartBeat.ini, HeartBeat, Main
                if (value)
                    onlineAHK := "Online: Main, "
                else
                    offlineAHK := "Offline: Main, "
                IniWrite, 0, HeartBeat.ini, HeartBeat, Main
            }
            Loop %Instances% {
                IniRead, value, HeartBeat.ini, HeartBeat, Instance%A_Index%
                if (value)
                    Online.push(1)
                else
                    Online.Push(0)
                IniWrite, 0, HeartBeat.ini, HeartBeat, Instance%A_Index%
            }
            for index, value in Online {
                if (index = Online.MaxIndex())
                    commaSeparate := "."
                else
                    commaSeparate := ", "
                if (value)
                    onlineAHK .= A_Index . commaSeparate
                else
                    offlineAHK .= A_Index . commaSeparate
            }
            if (offlineAHK = "Offline: ")
                offlineAHK := "Offline: none."
            if (onlineAHK = "Online: ")
                onlineAHK := "Online: none."

            discMessage := "\n" . onlineAHK . "\n" . offlineAHK . "\n" . packStatus
            if (heartBeatName)
                discordUserID := heartBeatName
            LogToDiscord(discMessage, , discordUserID)
        }
}
Return

GuiClose:
ExitApp

MonthToDays(year, month) {
    static DaysInMonths := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    days := 0
    Loop, % month - 1 {
        days += DaysInMonths[A_Index]
    }
    if (month > 2 && IsLeapYear(year))
        days += 1
    return days
}


IsLeapYear(year) {
    return (Mod(year, 4) = 0 && Mod(year, 100) != 0) || Mod(year, 400) = 0
}

LogToDiscord(message, screenshotFile := "", ping := false, xmlFile := "") {
    global discordUserId, discordWebhookURL, friendCode, heartBeatWebhookURL
    discordPing := discordUserId
    if (heartBeatWebhookURL)
        discordWebhookURL := heartBeatWebhookURL

    if (discordWebhookURL != "") {
        MaxRetries := 10
        RetryCount := 0
        Loop {
            try {
                ; If an image file is provided, send it
                if (screenshotFile != "") {
                    ; Check if the file exists
                    if (FileExist(screenshotFile)) {
                        ; Send the image using curl
                        curlCommand := "curl -k "
    . "-F ""payload_json={\""content\"":\""" . discordPing . message . "\""};type=application/json;charset=UTF-8"" " . discordWebhookURL
                        RunWait, %curlCommand%,, Hide
                    }
                }
                else {
                    curlCommand := "curl -k "
    . "-F ""payload_json={\""content\"":\""" . discordPing . message . "\""};type=application/json;charset=UTF-8"" " . discordWebhookURL
                        RunWait, %curlCommand%,, Hide
                }
                break
            }
            catch {
                RetryCount++
                if (RetryCount >= MaxRetries) {
                    CreateStatusMessage("Failed to send discord message.")
                    break
                }
                Sleep, 250
            }
            sleep, 250
        }
    }
}

DownloadFile(url, filename) {
    url := url  ; Change to your hosted .txt URL "https://pastebin.com/raw/vYxsiqSs"
    localPath = %A_ScriptDir%\%filename% ; Change to the folder you want to save the file

    URLDownloadToFile, %url%, %localPath%

    ; if ErrorLevel
        ; MsgBox, Download failed!
    ; else
        ; MsgBox, File downloaded successfully!

}

resetWindows(Title, SelectedMonitorIndex){
    global Columns, runMain
    RetryCount := 0
    MaxRetries := 10
    if (runMain){
        if (Title = 1) {
            Loop
            {
                try {
                    ; Get monitor origin from index
                    SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
                    SysGet, Monitor, Monitor, %SelectedMonitorIndex%

                    rowHeight := 533  ; Adjust the height of each row
                    currentRow := Floor((Title - 1) / Columns)
                    y := currentRow * rowHeight
                    x := Mod((Title - 1), Columns) * scaleParam
                    Title := "Main"
                    WinMove, %Title%, , % (MonitorLeft + x), % (MonitorTop + y), scaleParam, 537
                    break
                }
                catch {
                    if (RetryCount > MaxRetries)
                        Pause
                }
                Sleep, 1000
            }
            Title := 1
        }
    }
    Loop
    {
        try {
            ; Get monitor origin from index
            SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
            SysGet, Monitor, Monitor, %SelectedMonitorIndex%
            if (runMain)
                Title := Title + 1
            rowHeight := 533  ; Adjust the height of each row
            currentRow := Floor((Title - 1) / Columns)
            y := currentRow * rowHeight
            x := Mod((Title - 1), Columns) * scaleParam
            if (runMain)
                Title := Title - 1
            WinMove, %Title%, , % (MonitorLeft + x), % (MonitorTop + y), scaleParam, 537
            break
        }
        catch {
            if (RetryCount > MaxRetries)
                Pause
        }
        Sleep, 1000
    }
    return true
}

CreateStatusMessage(Message, X := 0, Y := 80) {
    global PacksText, SelectedMonitorIndex, createdGUI, Instances
    MaxRetries := 10
    RetryCount := 0
    try {
        GuiName := 22
        SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
        SysGet, Monitor, Monitor, %SelectedMonitorIndex%
        X := MonitorLeft + X
        Y := MonitorTop + Y
        Gui %GuiName%:+LastFoundExist
        if WinExist() {
            GuiControl, , PacksText, %Message%
        } else {
            OwnerWND := WinExist(1)
            if (!OwnerWND)
                Gui, %GuiName%:New, +ToolWindow -Caption
            else
                Gui, %GuiName%:New, +Owner%OwnerWND% +ToolWindow -Caption
            Gui, %GuiName%:Margin, 2, 2  ; Set margin for the GUI
            Gui, %GuiName%:Font, s8  ; Set the font size to 8 (adjust as needed)
            Gui, %GuiName%:Add, Text, vPacksText, %Message%
            Gui, %GuiName%:Show, NoActivate x%X% y%Y%, NoActivate %GuiName%
        }
    }
}

; Global variable to track the current JSON file
global jsonFileName := ""

; Function to create or select the JSON file
InitializeJsonFile() {
    global jsonFileName
    fileName := A_ScriptDir . "\json\Packs.json"
    if FileExist(fileName)
        FileDelete, %fileName%
    if !FileExist(fileName) {
        ; Create a new file with an empty JSON array
        FileAppend, [], %fileName%  ; Write an empty JSON array
        jsonFileName := fileName
        return
    }
}

; Function to append a time and variable pair to the JSON file
AppendToJsonFile(variableValue) {
    global jsonFileName
    if (jsonFileName = "") {
        MsgBox, JSON file not initialized. Call InitializeJsonFile() first.
        return
    }

    ; Read the current content of the JSON file
    FileRead, jsonContent, %jsonFileName%
    if (jsonContent = "") {
        jsonContent := "[]"
    }

    ; Parse and modify the JSON content
    jsonContent := SubStr(jsonContent, 1, StrLen(jsonContent) - 1) ; Remove trailing bracket
    if (jsonContent != "[")
        jsonContent .= ","
    jsonContent .= "{""time"": """ A_Now """, ""variable"": " variableValue "}]"

    ; Write the updated JSON back to the file
    FileDelete, %jsonFileName%
    FileAppend, %jsonContent%, %jsonFileName%
}

; Function to sum all variable values in the JSON file
SumVariablesInJsonFile() {
    global jsonFileName
    if (jsonFileName = "") {
        return
    }

    ; Read the file content
    FileRead, jsonContent, %jsonFileName%
    if (jsonContent = "") {
        return 0
    }

    ; Parse the JSON and calculate the sum
    sum := 0
    ; Clean and parse JSON content
    jsonContent := StrReplace(jsonContent, "[", "") ; Remove starting bracket
    jsonContent := StrReplace(jsonContent, "]", "") ; Remove ending bracket
    Loop, Parse, jsonContent, {, }
    {
        ; Match each variable value
        if (RegExMatch(A_LoopField, """variable"":\s*(-?\d+)", match)) {
            sum += match1
        }
    }

    ; Write the total sum to a file called "total.json"

    if (sum > 0) {
        totalFile := A_ScriptDir . "\json\total.json"
        totalContent := "{""total_sum"": " sum "}"
        FileDelete, %totalFile%
        FileAppend, %totalContent%, %totalFile%
    }

    return sum
}

KillADBProcesses() {
    ; Use AHK's Process command to close adb.exe
    Process, Close, adb.exe
    ; Fallback to taskkill for robustness
    RunWait, %ComSpec% /c taskkill /IM adb.exe /F /T,, Hide
}

~F7::ExitApp
