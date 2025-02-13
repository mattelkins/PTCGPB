; Window management.
WindowsArrange() {
    GuiControlGet, Instances

    Loop % Instances {
        WindowsReset(A_Index)
        sleep, 10
    }

    return
}

WindowsReset(winTitle) {
    GuiControlGet, SelectedMonitorIndex
    GuiControlGet, Columns
    GuiControlGet, runMain

    SelectedMonitorIndex := RegExReplace(SelectedMonitorIndex, ":.*$")

    retryCount := 0
    maxRetries := 10

    ; Scale is always 125%.
    scaleParam := 277
    rowHeight := 533

    if (runMain && winTitle = 1) {
        Loop {
            try {
                SysGet, Monitor, Monitor, %SelectedMonitorIndex%
                WinMove, Main,, MonitorLeft, MonitorTop, scaleParam, % (rowHeight + 5)
                break
            } catch {
                if (retryCount > maxRetries)
                    Pause
            }
            Sleep, 1000
        }
    }

    Loop {
        try {
            SysGet, Monitor, Monitor, %SelectedMonitorIndex%

            winOffset := winTitle
            if (!runMain) {
                winOffset := winOffset - 1
            }

            currentRow := Floor(winOffset / Columns)
            y := currentRow * rowHeight
            x := Mod(winOffset, Columns) * scaleParam

            WinMove, %winTitle%,, % (MonitorLeft + x), % (MonitorTop + y), scaleParam, % (rowHeight + 5)
            break
        } catch {
            if (retryCount > maxRetries)
                Pause
        }
        Sleep, 1000
    }

    return true
}
