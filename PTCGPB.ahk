version = Arturos PTCGP Bot
#SingleInstance, force
CoordMode, Mouse, Screen
SetTitleMatchMode, 3

if not A_IsAdmin
{
    ; Relaunch script with admin rights
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

;KillADBProcesses()

global Instances, jsonFileName, PacksText, runMain

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
global FriendID
; Create the main GUI for selecting number of instances
	IniRead, FriendID, Settings.ini, UserSettings, FriendID
	IniRead, waitTime, Settings.ini, UserSettings, waitTime, 5
	IniRead, Delay, Settings.ini, UserSettings, Delay, 250
	IniRead, folderPath, Settings.ini, UserSettings, folderPath, C:\Program Files\Netease
	IniRead, discordWebhookURL, Settings.ini, UserSettings, discordWebhookURL, ""
	IniRead, discordUserId, Settings.ini, UserSettings, discordUserId, ""
	IniRead, changeDate, Settings.ini, UserSettings, ChangeDate, 0100
	IniRead, Columns, Settings.ini, UserSettings, Columns, 5
	IniRead, openPack, Settings.ini, UserSettings, openPack, Palkia
	IniRead, godPack, Settings.ini, UserSettings, godPack, Continue
	IniRead, Instances, Settings.ini, UserSettings, Instances, 1
	;IniRead, setSpeed, Settings.ini, UserSettings, setSpeed, 1x/3x
	IniRead, defaultLanguage, Settings.ini, UserSettings, defaultLanguage, Scale125
	IniRead, SelectedMonitorIndex, Settings.ini, UserSettings, SelectedMonitorIndex, 1
	IniRead, swipeSpeed, Settings.ini, UserSettings, swipeSpeed, 600
	IniRead, skipInvalidGP, Settings.ini, UserSettings, skipInvalidGP, Yes
	IniRead, deleteMethod, Settings.ini, UserSettings, deleteMethod, 3 Pack
	IniRead, runMain, Settings.ini, UserSettings, runMain, 1
	IniRead, heartBeat, Settings.ini, UserSettings, heartBeat, 0
	IniRead, heartBeatWebhookURL, Settings.ini, UserSettings, heartBeatWebhookURL, ""
	IniRead, heartBeatName, Settings.ini, UserSettings, heartBeatName, ""
	IniRead, nukeAccount, Settings.ini, UserSettings, nukeAccount, 0
	IniRead, TrainerCheck, Settings.ini, UserSettings, TrainerCheck, No
	IniRead, FullArtCheck, Settings.ini, UserSettings, FullArtCheck, No
	IniRead, RainbowCheck, Settings.ini, UserSettings, RainbowCheck, No

; Main GUI setup
Gui, Show, w500 h698, Arturo's PTCGP Bot
Gui, Color, White
Gui, Font, s10, Segoe UI

; Add input controls.
guiControlWidth := 140
guiControlHalfWidth := 65
guiControlMaxHeight := 26

; - Header, Column 1
guiControlMarginX := 95
guiControlMarginY := 58

; FriendID
if(FriendID = "ERROR")
	FriendID =

if(FriendID = )
	Gui, Add, Edit, vFriendID x%guiControlMarginX% y%guiControlMarginY% w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans
else
	Gui, Add, Edit, vFriendID x%guiControlMarginX% y%guiControlMarginY% w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans, %FriendID%

; - Header, Column 2
guiControlMarginX := 330
guiControlMarginY := 58

; discordUserID
if(StrLen(discordUserID) > 2)
	Gui, Add, Edit, vdiscordUserId x%guiControlMarginX% y%guiControlMarginY% w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans, %discordUserId%
else
	Gui, Add, Edit, vdiscordUserId x%guiControlMarginX% y%guiControlMarginY% w%guiControlWidth% h%guiControlMaxHeight% BackgroundTrans

; - Top, Column 1
guiControlWidth := 150
guiControlMaxWidth := 360
guiControlMarginX := 70
guiControlMarginY := 107

; runMain
if(runMain)
	Gui, Add, CheckBox, Checked vrunMain x%guiControlMarginX% y%guiControlMarginY%, Main
else
	Gui, Add, CheckBox, vrunMain x%guiControlMarginX% y%guiControlMarginY%, Main

; Instances | Columns
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, Instances
Gui, Add, Text, x+28 BackgroundTrans, Columns

Gui, Add, Edit, vInstances x%guiControlMarginX% y+5 w%guiControlHalfWidth% h%guiControlMaxHeight% Center BackgroundTrans, %Instances%
Gui, Add, Edit, vColumns x+20 w%guiControlHalfWidth% h%guiControlMaxHeight% Center BackgroundTrans, %Columns%

; folderPath
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, Folder
Gui, Add, Edit, vfolderPath x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight%, %folderPath%

; SelectedMonitorIndex
SysGet, MonitorCount, MonitorCount
MonitorOptions := ""
Loop, %MonitorCount%
{
	SysGet, MonitorName, MonitorName, %A_Index%
	SysGet, Monitor, Monitor, %A_Index%
	MonitorOptions .= (A_Index > 1 ? "|" : "") "" A_Index ": (" MonitorRight - MonitorLeft "x" MonitorBottom - MonitorTop ")"

}
SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, Monitor
Gui, Add, DropDownList, x%guiControlMarginX% y+5 w%guiControlWidth% vSelectedMonitorIndex Choose%SelectedMonitorIndex%, %MonitorOptions%

; defaultLanguage
global scaleParam

if (defaultLanguage = "Scale125") {
	defaultLang := 1
	scaleParam := 277
} else if (defaultLanguage = "Scale100") {
	defaultLang := 2
	scaleParam := 287
}

Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, Scale
Gui, Add, DropDownList, x%guiControlMarginX% y+5 w%guiControlWidth% vdefaultLanguage choose%defaultLang%, Scale125

; - Top, Column 2
guiControlMarginX := 280

; Pack selection logic
if (openPack = "Palkia") {
	defaultPack := 1
} else if (openPack = "Dialga") {
	defaultPack := 2
} else if (openPack = "Mew") {
	defaultPack := 3
}

; openPack
Gui, Add, Text, x%guiControlMarginX% y%guiControlMarginY% BackgroundTrans, Pack
Gui, Add, DropDownList, x%guiControlMarginX% y+5 w%guiControlWidth% vopenPack choose%defaultPack%, Palkia|Dialga|Mew

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

; CardCheck
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, Find 2 Stars
Gui, Add, DropDownList, x%guiControlMarginX% y+5 w%guiControlWidth% vCardCheck choose%defaultCardCheck%, Only God Packs|All|Trainer+Full Art|Trainer+Rainbow|Full Art+Rainbow|Trainer|Full Arts|Rainbow

; Pack selection logic
if (skipInvalidGP = "No") {
	defaultskipGP := 1
} else if (skipInvalidGP = "Yes") {
	defaultskipGP := 2
}

; skipInvalid
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, % "Skip Crowns/Immersives"
Gui, Add, DropDownList, vskipInvalidGP x%guiControlMarginX% y+5 w%guiControlWidth% choose%defaultskipGP%, No|Yes

; Pack selection logic
if (deleteMethod = "3 Pack") {
	defaultDelete := 1
} else if (deleteMethod = "1 Pack") {
	defaultDelete := 2
} else if (deleteMethod = "Inject 1 Pack") {
	defaultDelete := 3
} else if (deleteMethod = "Inject 2 Pack") {
	defaultDelete := 4
}

; deleteMethod
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, Method
Gui, Add, DropDownList, x%guiControlMarginX% y+5 w%guiControlWidth% vdeleteMethod choose%defaultDelete% gdeleteSettings, 3 Pack|1 Pack|Inject 1 Pack|Inject 2 Pack

; nukeAccount
if (nukeAccount)
	Gui, Add, CheckBox, Checked vnukeAccount x%guiControlMarginX% y+10, % "Menu Delete"
else
	Gui, Add, CheckBox, vnukeAccount x%guiControlMarginX% y+10, % "Menu Delete"

if (InStr(deleteMethod, "Inject")) {
	GuiControl, Hide, nukeAccount
}

; - Middle, Column 1
guiControlMarginX := 70
guiControlMarginY := 375

; Delay | waitTime
Gui, Add, Text, x%guiControlMarginX% y%guiControlMarginY% BackgroundTrans, Delay
Gui, Add, Text, x+51 BackgroundTrans, % "Wait Time"

Gui, Add, Edit, vDelay x%guiControlMarginX% y+5 w%guiControlHalfWidth% h%guiControlMaxHeight% Center, %Delay%
Gui, Add, Edit, vwaitTime x+20 w%guiControlHalfWidth% h%guiControlMaxHeight% Center, %waitTime%

; discordWebhookURL
Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, Discord Webhook URL
if(StrLen(discordWebhookURL) > 2)
	Gui, Add, Edit, vdiscordWebhookURL x%guiControlMarginX% y+5 w%guiControlMaxWidth% h%guiControlMaxHeight%, %discordWebhookURL%
else
	Gui, Add, Edit, vdiscordWebhookURL x%guiControlMarginX% y+5 w%guiControlMaxWidth% h%guiControlMaxHeight%

; heartBeat
if (heartBeat)
	Gui, Add, CheckBox, Checked vheartBeat x%guiControlMarginX% y+7, Discord Heartbeat
else
	Gui, Add, CheckBox, vheartBeat x%guiControlMarginX% y+7, Discord Heartbeat


; - Middle, Column 2
guiControlMarginX := 280
guiControlMarginY := 375

; ChangeDate | swipeSpeed
Gui, Add, Text, x%guiControlMarginX% y%guiControlMarginY% BackgroundTrans, Swipe Speed
Gui, Add, Text, x+7 BackgroundTrans, % "Time Zone"

Gui, Add, Edit, vswipeSpeed x%guiControlMarginX% y+5 w%guiControlHalfWidth% h%guiControlMaxHeight% Center, %swipeSpeed%
Gui, Add, Edit, vChangeDate x+20 w%guiControlHalfWidth% h%guiControlMaxHeight% Center, %ChangeDate%

; heartBeatName
if(StrLen(heartBeatName) < 3)
    heartBeatName =

Gui, Add, Text, x%guiControlMarginX% y+63 BackgroundTrans, Heartbeat Name
Gui, Add, Edit, vheartBeatName x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight%, %heartBeatName%

; heartBeatWebhookURL
if(StrLen(heartBeatWebhookURL) < 3)
    heartBeatWebhookURL =

Gui, Add, Text, x%guiControlMarginX% y+7 BackgroundTrans, Heartbeat Webhook URL
Gui, Add, Edit, vheartBeatWebhookURL x%guiControlMarginX% y+5 w%guiControlWidth% h%guiControlMaxHeight%, %heartBeatWebhookURL%

; - Bottom (Links & Buttons)

Gui, Add, Text, gOpenDiscord x68 y535 w153 h27 BackgroundTrans
Gui, Add, Text, gOpenLink x68 y566 w153 h27 BackgroundTrans

Gui, Add, Text, gArrangeWindows x175 y627 w153 h27 BackgroundTrans
Gui, Add, Text, gStart x360 y627 w100 h27 BackgroundTrans

; Add background picture.
Gui, Add, Picture, x0 y0 w500 h698, %A_ScriptDir%\Scripts\GUI\Background.png

; Show the GUI
Gui, Show
return

deleteSettings:
    Gui, Submit, NoHide
	GuiControlGet, deleteMethod

	if (InStr(deleteMethod, "Inject")) {
		GuiControl, Hide, nukeAccount
		nukeAccount = false
	}
	else {
		GuiControl, Show, nukeAccount
	}
return

ShowMsgName:
	MsgBox, Input the name you want the accounts to have. `nIf it's getting stuck inputting the name then make sure your dpi is set to 220.`nLeave blank for a random pokemon name ;'
return

ShowMsgInstances:
	MsgBox, Input how many instances you are running
return

ShowMsgColumns:
	MsgBox, Input the number of instances per row
return

ShowMsgPacks:
	MsgBox, Select the pack you want to open
return

ShowMsgGodPacks:
	MsgBox, Select the behavior you want when finding a god pack. `nClose will close the emulator and stop the script to save resources. `nPause will only pause the script on the opening screen. `nContinue will save the account data to a file and continue rolling with the instance. The xml account data can then be injected into an instance using the tools in the 'Accounts' folder to recover the god pack.
return

ShowMsgLanguage:
	MsgBox, Select your game's language. In order to change your language > change language settings in mumu > delete the game account data. ;'
return

ShowMsgMonitor:
	MsgBox, Select the monitor you want the instances to be on. `nBe sure to start them on that monitor to prevent issues. `nIf you're having issues make sure all monitors are set to 125`% scale or the scale you have chosen ;'
return

ShowMsgDelay:
	MsgBox, Input the delay in between clicks.
return

ShowMsgTimeZone:
	MsgBox, What time the date change is for you. `n1 AM EST is default you can look up what that is in your time zone.
return

ShowMsgFolder:
	MsgBox, Where the "MuMuPlayerGlobal-12.0" folder is located. `nTypically it's in the Netease folder: C:\Program Files\Netease ;'
return

ShowMsgSpeed:
	MsgBox, Select the speed configuration. `n2x flat speed. (usually better when maxing out your system) `n1x/2x to swipe at 1x speed then do the rest on 2x. This needs the new speed mod in the guide. (Good option if you are having issues swiping on flat 2x speed) `n1x/3x to swipe at 1x speed then do the reset on 3x. This needs the new speed mod in the guide. (usually better when running fewer instances)
return

ShowMsgSwipeSpeed:
	MsgBox, Input the swipe speed in milliseconds. `nAnything from 100 to 1000 can probably work. `nPlay around with the speed to get the best speed for your system. Lower number = faster speed.
return

ShowMsgdiscordID:
	MsgBox, Input your discord ID for pings using webhook. Not your username, but your numerical discord ID.
return

ShowMsgdiscordwebHook:
	MsgBox, Input your server's webhook. It will be something like: https://discord.com/api/webhooks/124124151245/oihri1u24hifb12oiu43hy1 `nCreate a server in discord > for any channel > click the edit channel cog wheel > integrations > create a webhook > click on the webhook created > copy webhook url. Paste that here. ;'
return

ShowMsgAccountDeletion:
	MsgBox, Select the method to delete the account. `nFile method deletes the XML file and then closes/reopens the game. This should be more efficient. `nClicks method will simulate clicking and deleting the account through the Menu. Use this if for some reason your game takes a long time starting up.
return

ShowMsgSkipGP:
	MsgBox, Select whether or not to skip god packs. If you skip them you will still receive a discord ping and the account XML is also saved in the Accounts folder.
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
Gui, Submit  ; Collect the input values from the first page
Instances := Instances  ; Directly reference the "Instances" variable

if (CardCheck = "Only God Packs") {
    TrainerCheck := "No"
    FullArtCheck := "No"
    RainbowCheck := "No"
} else if (CardCheck = "All") {
    TrainerCheck := "Yes"
    FullArtCheck := "Yes"
    RainbowCheck := "Yes"
} else if (CardCheck = "Trainer") {
    TrainerCheck := "Yes"
    FullArtCheck := "No"
    RainbowCheck := "No"
} else if (CardCheck = "Full Arts") {
    TrainerCheck := "No"
    FullArtCheck := "Yes"
    RainbowCheck := "No"
} else if (CardCheck = "Rainbow") {
    TrainerCheck := "No"
    FullArtCheck := "No"
    RainbowCheck := "Yes"
} else if (CardCheck = "Trainer+Full Art") {
    TrainerCheck := "Yes"
    FullArtCheck := "Yes"
    RainbowCheck := "No"
} else if (CardCheck = "Trainer+Rainbow") {
    TrainerCheck := "Yes"
    FullArtCheck := "No"
    RainbowCheck := "Yes"
} else if (CardCheck = "Full Art+Rainbow") {
    TrainerCheck := "No"
    FullArtCheck := "Yes"
    RainbowCheck := "Yes"
}

; Create the second page dynamically based on the number of instances
Gui, Destroy ; Close the first page

IniWrite, %FriendID%, Settings.ini, UserSettings, FriendID
IniWrite, %waitTime%, Settings.ini, UserSettings, waitTime
IniWrite, %Delay%, Settings.ini, UserSettings, Delay
IniWrite, %folderPath%, Settings.ini, UserSettings, folderPath
IniWrite, %discordWebhookURL%, Settings.ini, UserSettings, discordWebhookURL
IniWrite, %discordUserId%, Settings.ini, UserSettings, discordUserId
IniWrite, %ChangeDate%, Settings.ini, UserSettings, ChangeDate
IniWrite, %Columns%, Settings.ini, UserSettings, Columns
IniWrite, %openPack%, Settings.ini, UserSettings, openPack
IniWrite, %godPack%, Settings.ini, UserSettings, godPack
IniWrite, %Instances%, Settings.ini, UserSettings, Instances
;IniWrite, %setSpeed%, Settings.ini, UserSettings, setSpeed
IniWrite, %defaultLanguage%, Settings.ini, UserSettings, defaultLanguage
IniWrite, %SelectedMonitorIndex%, Settings.ini, UserSettings, SelectedMonitorIndex
IniWrite, %swipeSpeed%, Settings.ini, UserSettings, swipeSpeed
IniWrite, %skipInvalidGP%, Settings.ini, UserSettings, skipInvalidGP
IniWrite, %deleteMethod%, Settings.ini, UserSettings, deleteMethod
IniWrite, %runMain%, Settings.ini, UserSettings, runMain
IniWrite, %heartBeat%, Settings.ini, UserSettings, heartBeat
IniWrite, %heartBeatWebhookURL%, Settings.ini, UserSettings, heartBeatWebhookURL
IniWrite, %heartBeatName%, Settings.ini, UserSettings, heartBeatName
IniWrite, %nukeAccount%, Settings.ini, UserSettings, nukeAccount
IniWrite, %TrainerCheck%, Settings.ini, UserSettings, TrainerCheck
IniWrite, %FullArtCheck%, Settings.ini, UserSettings, FullArtCheck
IniWrite, %RainbowCheck%, Settings.ini, UserSettings, RainbowCheck

; Loop to process each instance
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
if(runMain) {
	FileName := "Scripts\Main.ahk"
	Run, %FileName%
}
if(inStr(FriendID, "https"))
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
	if(total = 0)
	total := "0                             "
	packStatus := "Time: " . mminutes . "m Packs: " . total
	CreateStatusMessage(packStatus, 287, 490)
	if(heartBeat)
		if((A_Index = 1 || (Mod(A_Index, 60) = 0))) {
			onlineAHK := "Online: "
			offlineAHK := "Offline: "
			Online := []
			if(runMain) {
				IniRead, value, HeartBeat.ini, HeartBeat, Main
				if(value)
					onlineAHK := "Online: Main, "
				else
					offlineAHK := "Offline: Main, "
				IniWrite, 0, HeartBeat.ini, HeartBeat, Main
			}
			Loop %Instances% {
				IniRead, value, HeartBeat.ini, HeartBeat, Instance%A_Index%
				if(value)
					Online.push(1)
				else
					Online.Push(0)
				IniWrite, 0, HeartBeat.ini, HeartBeat, Instance%A_Index%
			}
			for index, value in Online {
				if(index = Online.MaxIndex())
					commaSeparate := "."
				else
					commaSeparate := ", "
				if(value)
					onlineAHK .= A_Index . commaSeparate
				else
					offlineAHK .= A_Index . commaSeparate
			}
			if(offlineAHK = "Offline: ")
				offlineAHK := "Offline: none."
			if(onlineAHK = "Online: ")
				onlineAHK := "Online: none."

			discMessage := "\n" . onlineAHK . "\n" . offlineAHK . "\n" . packStatus
			if(heartBeatName)
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
	if(heartBeatWebhookURL)
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
	if(runMain){
		if(Title = 1) {
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
			if(runMain)
				Title := Title + 1
			rowHeight := 533  ; Adjust the height of each row
			currentRow := Floor((Title - 1) / Columns)
			y := currentRow * rowHeight
			x := Mod((Title - 1), Columns) * scaleParam
			if(runMain)
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
		} else {			OwnerWND := WinExist(1)
			if(!OwnerWND)
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

	if(sum > 0) {
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
