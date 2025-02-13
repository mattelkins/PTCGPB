; ADB integration.

KillADBProcesses() {
    ; Use AHK's Process command to close adb.exe.
    Process, Close, adb.exe
    ; Fallback to taskkill for robustness.
    RunWait, %ComSpec% /c taskkill /IM adb.exe /F /T,, Hide
}
