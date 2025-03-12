global FriendID, waitTime, Delay, folderPath, discordWebhookURL, discordUserId, Columns, openPack, godPack, Instances
global instanceStartDelay, defaultLanguage, SelectedMonitorIndex, swipeSpeed, deleteMethod, runMain, heartBeat
global heartBeatWebhookURL, heartBeatName, nukeAccount, packMethod, TrainerCheck, FullArtCheck, RainbowCheck,
global CrownCheck, ImmersiveCheck, PseudoGodPack, minStars, Palkia, Dialga, Arceus, Mew, Pikachu, Charizard, Mewtwo
global slowMotion, ocrLanguage, mainIdsURL, vipIdsURL, autoLaunchMonitor, instanceLaunchDelay

global ExCheck, OneStarCheck, ThreeDiamondCheck, ExCount, OneStarCount, ThreeDiamondCount, MatchCount, ExS4T,
global OneStarS4T, ThreeDiamondS4T, DebugLogs, ScreenshotAllPacks, ReportS4T

IniRead, ExCheck, Settings.ini, UserSettings, ExCheck, 0
IniRead, OneStarCheck, Settings.ini, UserSettings, OneStarCheck, 0
IniRead, ThreeDiamondCheck, Settings.ini, UserSettings, ThreeDiamondCheck, 0
IniRead, ExCount, Settings.ini, UserSettings, ExCount, 1
IniRead, OneStarCount, Settings.ini, UserSettings, OneStarCount, 1
IniRead, ThreeDiamondCount, Settings.ini, UserSettings, ThreeDiamondCount, 1
IniRead, MatchCount, Settings.ini, UserSettings, MatchCount, 1
IniRead, ExS4T, Settings.ini, UserSettings, ExS4T, 0
IniRead, OneStarS4T, Settings.ini, UserSettings, OneStarS4T, 0
IniRead, ThreeDiamondS4T, Settings.ini, UserSettings, ThreeDiamondS4T, 0
IniRead, DebugLogs, Settings.ini, UserSettings, DebugLogs, 0
IniRead, ScreenshotAllPacks, Settings.ini, UserSettings, ScreenshotAllPacks, 0
IniRead, ReportS4T, Settings.ini, UserSettings, ReportS4T, 0

Gui3477() {
    Gui, Add, GroupBox, x5 y495 w741 h145 c00AEAE, 3477

    Gui, Add, Text, x20 y515 c00AEAE, Card Detection:

    if (ExCheck)
        Gui, Add, Checkbox, Checked vExCheck gpackDetectionSettings y+7 c00AEAE, EX
    else
        Gui, Add, Checkbox, vExCheck gpackDetectionSettings y+7 c00AEAE, EX

    if (OneStarCheck)
        Gui, Add, Checkbox, Checked vOneStarCheck gpackDetectionSettings y+14 c00AEAE, 1 Star
    else
        Gui, Add, Checkbox, vOneStarCheck gpackDetectionSettings y+14 c00AEAE, 1 Star

    if (ThreeDiamondCheck)
        Gui, Add, Checkbox, Checked vThreeDiamondCheck gpackDetectionSettings y+14 c00AEAE, 3 Diamond
    else
        Gui, Add, Checkbox, vThreeDiamondCheck gpackDetectionSettings y+14 c00AEAE, 3 Diamond

    defaultExCount := StrReplace(ExCount, "x ", "")
    if (ExCheck)
        Gui, Add, DropDownList, vExCount choose%defaultExCount% x115 y539 w50, x 1|x 2|x 3
    else
        Gui, Add, DropDownList, vExCount choose%defaultExCount% x115 y539 w50 Hidden, x 1|x 2|x 3

    defaultOneStarCount := StrReplace(OneStarCount, "x ", "")
    if (OneStarCheck)
        Gui, Add, DropDownList, vOneStarCount choose%defaultOneStarCount% y+7 w50, x 1|x 2|x 3
    else
        Gui, Add, DropDownList, vOneStarCount choose%defaultOneStarCount% y+7 w50 Hidden, x 1|x 2|x 3

    defaultThreeDiamondCount := StrReplace(ThreeDiamondCount, "x ", "")
    if (ThreeDiamondCheck)
        Gui, Add, DropDownList, vThreeDiamondCount choose%defaultThreeDiamondCount% y+7 w50, x 1|x 2|x 3
    else
        Gui, Add, DropDownList, vThreeDiamondCount choose%defaultThreeDiamondCount% y+7 w50 Hidden, x 1|x 2|x 3

    Gui, Add, Text, x185 y515 c00AEAE, Detection Logic:

    Gui, Add, Text, y+8 c00AEAE, Match Count:
    Gui, Add, DropDownList, vMatchCount choose%MatchCount% x280 y539 w35, 1|2|3

    Gui, Add, Text, x335 y515 c00AEAE, Save for Trade:

    if (ExS4T)
        Gui, Add, Checkbox, Checked vExS4T y+2 c00AEAE, EX
    else
        Gui, Add, Checkbox, vExS4T y+2 c00AEAE, EX

    if (OneStarS4T)
        Gui, Add, Checkbox, Checked vOneStarS4T y+2 c00AEAE, 1 Star
    else
        Gui, Add, Checkbox, vOneStarS4T y+2 c00AEAE, 1 Star

    if (ThreeDiamondS4T)
        Gui, Add, Checkbox, Checked vThreeDiamondS4T y+2 c00AEAE, 3 Diamond
    else
        Gui, Add, Checkbox, vThreeDiamondS4T y+2 c00AEAE, 3 Diamond

    Gui, Add, Text, x483 y515 c00AEAE, Debug:

    if (DebugLogs)
        Gui, Add, Checkbox, Checked vDebugLogs y+2 c00AEAE, 3477 Logging
    else
        Gui, Add, Checkbox, vDebugLogs y+2 c00AEAE, 3477 Logging

    if (ScreenshotAllPacks)
        Gui, Add, Checkbox, Checked vScreenshotAllPacks y+2 c00AEAE, Pack Screenshots
    else
        Gui, Add, Checkbox, vScreenshotAllPacks y+2 c00AEAE, Pack Screenshots

    if (ReportS4T)
        Gui, Add, Checkbox, Checked vReportS4T y+2 c00AEAE, Report S4T
    else
        Gui, Add, Checkbox, vReportS4T y+2 c00AEAE, Report S4T

    Gui, Add, Button, gSaveReload x616 y598 w115, Reload
}

Start3477() {
    IniWrite, %ExCheck%, Settings.ini, UserSettings, ExCheck
    IniWrite, %OneStarCheck%, Settings.ini, UserSettings, OneStarCheck
    IniWrite, %ThreeDiamondCheck%, Settings.ini, UserSettings, ThreeDiamondCheck
    IniWrite, %ExCount%, Settings.ini, UserSettings, ExCount
    IniWrite, %OneStarCount%, Settings.ini, UserSettings, OneStarCount
    IniWrite, %ThreeDiamondCount%, Settings.ini, UserSettings, ThreeDiamondCount
    IniWrite, %MatchCount%, Settings.ini, UserSettings, MatchCount
    IniWrite, %ExS4T%, Settings.ini, UserSettings, ExS4T
    IniWrite, %OneStarS4T%, Settings.ini, UserSettings, OneStarS4T
    IniWrite, %ThreeDiamondS4T%, Settings.ini, UserSettings, ThreeDiamondS4T
    IniWrite, %DebugLogs%, Settings.ini, UserSettings, DebugLogs
    IniWrite, %ScreenshotAllPacks%, Settings.ini, UserSettings, ScreenshotAllPacks
    IniWrite, %ReportS4T%, Settings.ini, UserSettings, ReportS4T
}

PackDetectionSettings() {
    Gui, Submit, NoHide

    if (ExCheck)
        GuiControl, Show, ExCount
    else
        GuiControl, Hide, ExCount

    if (OneStarCheck)
        GuiControl, Show, OneStarCount
    else
        GuiControl, Hide, OneStarCount

    if (ThreeDiamondCheck)
        GuiControl, Show, ThreeDiamondCount
    else
        GuiControl, Hide, ThreeDiamondCount
}

SaveReload() {
    Gui, Submit

    IniWrite, %FriendID%, Settings.ini, UserSettings, FriendID
    IniWrite, %waitTime%, Settings.ini, UserSettings, waitTime
    IniWrite, %Delay%, Settings.ini, UserSettings, Delay
    IniWrite, %folderPath%, Settings.ini, UserSettings, folderPath
    IniWrite, %discordWebhookURL%, Settings.ini, UserSettings, discordWebhookURL
    IniWrite, %discordUserId%, Settings.ini, UserSettings, discordUserId
    IniWrite, %Columns%, Settings.ini, UserSettings, Columns
    IniWrite, %openPack%, Settings.ini, UserSettings, openPack
    IniWrite, %godPack%, Settings.ini, UserSettings, godPack
    IniWrite, %Instances%, Settings.ini, UserSettings, Instances
    IniWrite, %instanceStartDelay%, Settings.ini, UserSettings, instanceStartDelay
    IniWrite, %defaultLanguage%, Settings.ini, UserSettings, defaultLanguage
    IniWrite, %SelectedMonitorIndex%, Settings.ini, UserSettings, SelectedMonitorIndex
    IniWrite, %swipeSpeed%, Settings.ini, UserSettings, swipeSpeed
    IniWrite, %deleteMethod%, Settings.ini, UserSettings, deleteMethod
    IniWrite, %runMain%, Settings.ini, UserSettings, runMain
    IniWrite, %heartBeat%, Settings.ini, UserSettings, heartBeat
    IniWrite, %heartBeatWebhookURL%, Settings.ini, UserSettings, heartBeatWebhookURL
    IniWrite, %heartBeatName%, Settings.ini, UserSettings, heartBeatName
    IniWrite, %nukeAccount%, Settings.ini, UserSettings, nukeAccount
    IniWrite, %packMethod%, Settings.ini, UserSettings, packMethod
    IniWrite, %TrainerCheck%, Settings.ini, UserSettings, TrainerCheck
    IniWrite, %FullArtCheck%, Settings.ini, UserSettings, FullArtCheck
    IniWrite, %RainbowCheck%, Settings.ini, UserSettings, RainbowCheck
    IniWrite, %CrownCheck%, Settings.ini, UserSettings, CrownCheck
    IniWrite, %ImmersiveCheck%, Settings.ini, UserSettings, ImmersiveCheck
    IniWrite, %PseudoGodPack%, Settings.ini, UserSettings, PseudoGodPack
    IniWrite, %minStars%, Settings.ini, UserSettings, minStars
    IniWrite, %Palkia%, Settings.ini, UserSettings, Palkia
    IniWrite, %Dialga%, Settings.ini, UserSettings, Dialga
    IniWrite, %Arceus%, Settings.ini, UserSettings, Arceus
    IniWrite, %Mew%, Settings.ini, UserSettings, Mew
    IniWrite, %Pikachu%, Settings.ini, UserSettings, Pikachu
    IniWrite, %Charizard%, Settings.ini, UserSettings, Charizard
    IniWrite, %Mewtwo%, Settings.ini, UserSettings, Mewtwo
    IniWrite, %slowMotion%, Settings.ini, UserSettings, slowMotion

    IniWrite, %ocrLanguage%, Settings.ini, UserSettings, ocrLanguage
    IniWrite, %mainIdsURL%, Settings.ini, UserSettings, mainIdsURL
    IniWrite, %vipIdsURL%, Settings.ini, UserSettings, vipIdsURL
    IniWrite, %autoLaunchMonitor%, Settings.ini, UserSettings, autoLaunchMonitor
    IniWrite, %instanceLaunchDelay%, Settings.ini, UserSettings, instanceLaunchDelay

    IniWrite, %ExCheck%, Settings.ini, UserSettings, ExCheck
    IniWrite, %OneStarCheck%, Settings.ini, UserSettings, OneStarCheck
    IniWrite, %ThreeDiamondCheck%, Settings.ini, UserSettings, ThreeDiamondCheck
    IniWrite, %ExCount%, Settings.ini, UserSettings, ExCount
    IniWrite, %OneStarCount%, Settings.ini, UserSettings, OneStarCount
    IniWrite, %ThreeDiamondCount%, Settings.ini, UserSettings, ThreeDiamondCount
    IniWrite, %MatchCount%, Settings.ini, UserSettings, MatchCount
    IniWrite, %ExS4T%, Settings.ini, UserSettings, ExS4T
    IniWrite, %OneStarS4T%, Settings.ini, UserSettings, OneStarS4T
    IniWrite, %ThreeDiamondS4T%, Settings.ini, UserSettings, ThreeDiamondS4T
    IniWrite, %DebugLogs%, Settings.ini, UserSettings, DebugLogs
    IniWrite, %ScreenshotAllPacks%, Settings.ini, UserSettings, ScreenshotAllPacks
    IniWrite, %ReportS4T%, Settings.ini, UserSettings, ReportS4T

    Reload
}

