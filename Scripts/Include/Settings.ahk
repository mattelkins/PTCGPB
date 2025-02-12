global settingsPath := A_ScriptDir . "\Settings.ini"

SettingsRead()
{
    global settingsPath

    IniRead, FriendID, %settingsPath%, UserSettings, FriendID
    IniRead, waitTime, %settingsPath%, UserSettings, waitTime, 5
    IniRead, Delay, %settingsPath%, UserSettings, Delay, 250
    IniRead, folderPath, %settingsPath%, UserSettings, folderPath, C:\Program Files\Netease
    IniRead, discordWebhookURL, %settingsPath%, UserSettings, discordWebhookURL
    IniRead, discordUserId, %settingsPath%, UserSettings, discordUserId
    IniRead, ChangeDate, %settingsPath%, UserSettings, ChangeDate, 0100
    IniRead, Columns, %settingsPath%, UserSettings, Columns, 5
    IniRead, openPack, %settingsPath%, UserSettings, openPack, Palkia
    IniRead, Instances, %settingsPath%, UserSettings, Instances, 1
    IniRead, defaultLanguage, %settingsPath%, UserSettings, defaultLanguage, Scale125
    IniRead, SelectedMonitorIndex, %settingsPath%, UserSettings, SelectedMonitorIndex, 1
    IniRead, swipeSpeed, %settingsPath%, UserSettings, swipeSpeed, 600
    IniRead, skipInvalidGP, %settingsPath%, UserSettings, skipInvalidGP, Yes
    IniRead, deleteMethod, %settingsPath%, UserSettings, deleteMethod, 3 Pack
    IniRead, runMain, %settingsPath%, UserSettings, runMain, 1
    IniRead, heartBeat, %settingsPath%, UserSettings, heartBeat, 0
    IniRead, heartBeatWebhookURL, %settingsPath%, UserSettings, heartBeatWebhookURL
    IniRead, heartBeatName, %settingsPath%, UserSettings, heartBeatName
    IniRead, nukeAccount, %settingsPath%, UserSettings, nukeAccount, 0

    array := {}
    array["FriendID"] := FriendID
    array["waitTime"] := waitTime
    array["Delay"] := Delay
    array["folderPath"] := folderPath
    array["discordWebhookURL"] := discordWebhookURL
    array["discordUserId"] := discordUserId
    array["ChangeDate"] := ChangeDate
    array["Columns"] := Columns
    array["openPack"] := openPack
    array["Instances"] := Instances
    array["defaultLanguage"] := defaultLanguage
    array["SelectedMonitorIndex"] := SelectedMonitorIndex
    array["swipeSpeed"] := swipeSpeed
    array["skipInvalidGP"] := skipInvalidGP
    array["deleteMethod"] := deleteMethod
    array["runMain"] := runMain
    array["heartBeat"] := heartBeat
    array["heartBeatWebhookURL"] := heartBeatWebhookURL
    array["heartBeatName"] := heartBeatName
    array["nukeAccount"] := nukeAccount

    return array
}

SettingsWrite()
{
    global settingsPath, Settings

    GuiControlGet, FriendID
    GuiControlGet, waitTime
    GuiControlGet, Delay
    GuiControlGet, folderPath
    GuiControlGet, discordWebhookURL
    GuiControlGet, discordUserId
    GuiControlGet, ChangeDate
    GuiControlGet, Columns
    GuiControlGet, openPack
    GuiControlGet, Instances
    GuiControlGet, defaultLanguage
    GuiControlGet, SelectedMonitorIndex
    GuiControlGet, swipeSpeed
    GuiControlGet, skipInvalidGP
    GuiControlGet, deleteMethod
    GuiControlGet, runMain
    GuiControlGet, heartBeat
    GuiControlGet, heartBeatWebhookURL
    GuiControlGet, heartBeatName
    GuiControlGet, nukeAccount

    IniWrite, %FriendID%, %settingsPath%, UserSettings, FriendID
    IniWrite, %waitTime%, %settingsPath%, UserSettings, waitTime
    IniWrite, %Delay%, %settingsPath%, UserSettings, Delay
    IniWrite, %folderPath%, %settingsPath%, UserSettings, folderPath
    IniWrite, %discordWebhookURL%, %settingsPath%, UserSettings, discordWebhookURL
    IniWrite, %discordUserId%, %settingsPath%, UserSettings, discordUserId
    IniWrite, %ChangeDate%, %settingsPath%, UserSettings, ChangeDate
    IniWrite, %Columns%, %settingsPath%, UserSettings, Columns
    IniWrite, %openPack%, %settingsPath%, UserSettings, openPack
    IniWrite, %Instances%, %settingsPath%, UserSettings, Instances
    IniWrite, %defaultLanguage%, %settingsPath%, UserSettings, defaultLanguage
    IniWrite, %SelectedMonitorIndex%, %settingsPath%, UserSettings, SelectedMonitorIndex
    IniWrite, %swipeSpeed%, %settingsPath%, UserSettings, swipeSpeed
    IniWrite, %skipInvalidGP%, %settingsPath%, UserSettings, skipInvalidGP
    IniWrite, %deleteMethod%, %settingsPath%, UserSettings, deleteMethod
    IniWrite, %runMain%, %settingsPath%, UserSettings, runMain
    IniWrite, %heartBeat%, %settingsPath%, UserSettings, heartBeat
    IniWrite, %heartBeatWebhookURL%, %settingsPath%, UserSettings, heartBeatWebhookURL
    IniWrite, %heartBeatName%, %settingsPath%, UserSettings, heartBeatName
    IniWrite, %nukeAccount%, %settingsPath%, UserSettings, nukeAccount

    Settings = SettingsRead()

    return
}
