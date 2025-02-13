; Discord logging via webhooks.

LogToDiscord(message, screenshotFile := "", ping := false, xmlFile := "") {
    global Settings

    if (Settings["discordWebhookURL"] != "") {
        ; Set up string for Discord pings.
        discordPing := "<@" . Settings["discordUserId"] . ">"
        discordFriends := ReadFile("discord.txt")

        if (discordFriends) {
            for index, value in discordFriends {
                if (value = Settings["discordUserId"])
                    continue
                discordPing .= "<@" . value . "> "
            }
        }

        ; Discord cURL loop.
        MaxRetries := 10
        RetryCount := 0
        Loop {
            try {
                ; If an image file is provided, send it.
                if (screenshotFile != "" && FileExist(screenshotFile)) {
                    ; Send the image using curl.
                    curlCommand := "curl -k "
                        . "-F ""payload_json={\""content\"":\""" . discordPing . message . "\""};type=application/json;charset=UTF-8"" "
                        . "-F ""file=@" . screenshotFile . """ "
                        . Settings["discordWebhookURL"]

                    RunWait, %curlCommand%,, Hide
                } else {
                    curlCommand := "curl -k "
                    . "-F ""payload_json={\""content\"":\""" . discordPing . message . "\""};type=application/json;charset=UTF-8"" " . Settings["discordWebhookURL"]
                        RunWait, %curlCommand%,, Hide
                }
                break
            } catch {
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
