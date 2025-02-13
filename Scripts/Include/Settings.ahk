; Settings retrieval and storage.

global settingsPath := A_ScriptDir . "\Settings.ini", Settings

SettingsRead(force := false) {
    global settingsPath, Settings

    if (Settings.Length() > 0 && !force)
        return Settings

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
    IniRead, SelectedMonitorIndex, %settingsPath%, UserSettings, SelectedMonitorIndex, 1
    IniRead, swipeSpeed, %settingsPath%, UserSettings, swipeSpeed, 600
    IniRead, skipInvalidGP, %settingsPath%, UserSettings, skipInvalidGP, Yes
    IniRead, deleteMethod, %settingsPath%, UserSettings, deleteMethod, 3 Pack
    IniRead, runMain, %settingsPath%, UserSettings, runMain, 1

    Settings := {}
    Settings["FriendID"] := FriendID
    Settings["waitTime"] := waitTime
    Settings["Delay"] := Delay
    Settings["folderPath"] := folderPath
    Settings["discordWebhookURL"] := discordWebhookURL
    Settings["discordUserId"] := discordUserId
    Settings["ChangeDate"] := ChangeDate
    Settings["Columns"] := Columns
    Settings["openPack"] := openPack
    Settings["Instances"] := Instances
    Settings["SelectedMonitorIndex"] := SelectedMonitorIndex
    Settings["swipeSpeed"] := swipeSpeed
    Settings["skipInvalidGP"] := skipInvalidGP
    Settings["deleteMethod"] := deleteMethod
    Settings["runMain"] := runMain

    return Settings
}

SettingsWrite() {
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
    GuiControlGet, SelectedMonitorIndex
    GuiControlGet, swipeSpeed
    GuiControlGet, skipInvalidGP
    GuiControlGet, deleteMethod
    GuiControlGet, runMain

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
    IniWrite, %SelectedMonitorIndex%, %settingsPath%, UserSettings, SelectedMonitorIndex
    IniWrite, %swipeSpeed%, %settingsPath%, UserSettings, swipeSpeed
    IniWrite, %skipInvalidGP%, %settingsPath%, UserSettings, skipInvalidGP
    IniWrite, %deleteMethod%, %settingsPath%, UserSettings, deleteMethod
    IniWrite, %runMain%, %settingsPath%, UserSettings, runMain

    ; Make sure settings are up-to-date.
    Settings = SettingsRead(true)

    return Settings
}
