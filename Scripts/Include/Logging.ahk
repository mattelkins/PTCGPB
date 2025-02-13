; Logging functions.

CreateStatusMessage(Message, X := 0, Y := 80) {
    global Settings, showStatus, scriptName

    if(!showStatus)
        return

    if (scriptName = "") {
        scriptName := "1"
    }

    guiName := "GUI_" . scriptName
    ownerWND := WinExist(scriptName)

    try {
        WinGetPos, xpos, ypos, Width, Height, %scriptName%
        X := X + xpos + 5
        Y := Y + ypos
        if(!X)
            X := 0
        if(!Y)
            Y := 0

        ; Create a new GUI with the given name, position, and message.
        if (!ownerWND)
            Gui, %guiName%:New, +Owner%ownerWND% -AlwaysOnTop +ToolWindow -Caption
        else
            Gui, %guiName%:New, -AlwaysOnTop +ToolWindow -Caption
        Gui, %guiName%:Margin, 2, 2
        Gui, %guiName%:Font, s8
        Gui, %guiName%:Add, Text,, %Message%
        Gui, %guiName%:Show, NoActivate x%X% y%Y% AutoSize, NoActivate %guiName%
    }
}
