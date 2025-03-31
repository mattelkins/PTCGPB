global ScriptDir := RegExReplace(A_LineFile, "\\[^\\]+$"), LogsDir := ScriptDir . "\..\..\Logs"
global discordWebhookURL, discordUserId, sendAccountXml

sSettingsPath := ScriptDir . "\..\..\Settings.ini"

IniRead, discordWebhookURL, %sSettingsPath%, UserSettings, discordWebhookURL, ""
IniRead, discordUserId, %sSettingsPath%, UserSettings, discordUserId, ""
IniRead, sendAccountXml, %sSettingsPath%, UserSettings, sendAccountXml, 0

LogToFile(message, logFile := "") {
    if (logFile = "") {
        logFile := LogsDir . "\Log" . StrReplace(A_ScriptName, ".ahk") . ".txt"
    }
    else
        logFile := LogsDir . "\" . logFile
    FormatTime, readableTime, %A_Now%, MMMM dd, yyyy HH:mm:ss
    FileAppend, % "[" readableTime "] " message "`n", %logFile%
}

LogToDiscord(message, screenshotFile := "", ping := false, xmlFile := "", screenshotFile2 := "", altWebhookURL := "") {
    discordPing := ""

    if (ping) {
        discordPing := "<@" . discordUserId . "> "
        discordFriends := ReadFile("discord")
        if (discordFriends) {
            for index, value in discordFriends {
                if(value = discordUserId)
                    continue
                discordPing .= "<@" . value . "> "
            }
        }
    }

    webhookURL := (altWebhookURL ? altWebhookURL : discordWebhookURL)

    if (webhookURL != "") {
        if (!sendAccountXml)
            xmlFile := ""
        MaxRetries := 10
        RetryCount := 0
        Loop {
            try {
                ; Base command
                curlCommand := "curl -k "
                    . "-F ""payload_json={\""content\"":\""" . discordPing . message . "\""};type=application/json;charset=UTF-8"" "

                ; If an screenshot or xml file is provided, send it
                sendScreenshot1 := screenshotFile != "" && FileExist(screenshotFile)
                sendScreenshot2 := screenshotFile2 != "" && FileExist(screenshotFile2)
                sendAccountXml := xmlFile != "" && FileExist(xmlFile)
                if (sendScreenshot1 + sendScreenshot2 + sendAccountXml > 1) {
                    fileIndex := 0
                    if (sendScreenshot1) {
                        fileIndex++
                        curlCommand := curlCommand . "-F ""file" . fileIndex . "=@" . screenshotFile . """ "
                    }
                    if (sendScreenshot2) {
                        fileIndex++
                        curlCommand := curlCommand . "-F ""file" . fileIndex . "=@" . screenshotFile2 . """ "
                    }
                    if (sendAccountXml) {
                        fileIndex++
                        curlCommand := curlCommand . "-F ""file" . fileIndex . "=@" . xmlFile . """ "
                    }
                }
                else if (sendScreenshot1 + sendScreenshot2 + sendAccountXml == 1) {
                    if (sendScreenshot1)
                        curlCommand := curlCommand . "-F ""file=@" . screenshotFile . """ "
                    if (sendScreenshot2)
                        curlCommand := curlCommand . "-F ""file=@" . screenshotFile2 . """ "
                    if (sendAccountXml)
                        curlCommand := curlCommand . "-F ""file=@" . xmlFile . """ "
                }
                ; Add the webhook
                curlCommand := curlCommand . webhookURL

                LogToFile(curlCommand, "Discord.txt")

                ; Send the message using curl
                RunWait, %curlCommand%,, Hide
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
            Sleep, 250
        }
    }
}
