; File operations.

FileTotalInit() {
    totalFile := A_ScriptDir . "\json\total.json"
    backupFile := A_ScriptDir . "\json\total-backup.json"

    if FileExist(totalFile) {
        FileCopy, %totalFile%, %backupFile%, 1
        if (ErrorLevel)
            MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
    }

    FileDelete, %totalFile%
}

FilePacksInit() {
    packsFile := A_ScriptDir . "\json\Packs.json"
    backupFile := A_ScriptDir . "\json\Packs-backup.json"

    if FileExist(packsFile) {
        FileCopy, %packsFile%, %backupFile%, 1
        if (ErrorLevel) {
            MsgBox, Failed to create %backupFile%. Ensure permissions and paths are correct.
            return
        }
    }

    FileDelete, %packsFile%

    ; Write an empty JSON array.
    FileAppend, [], %packsFile%
}

FilePacksAppend(variableValue) {
    packsFile := A_ScriptDir . "\json\Packs.json"
    FileAppendJSONVariable(packsFile, variableValue)
}

FilePacksSum() {
    packsFile := A_ScriptDir . "\json\Packs.json"
    totalFile := A_ScriptDir . "\json\total.json"
    FileSumJSON(packsFile, totalFile)
}

FileAppendJSONVariable(targetPath, variableValue) {
    if !FileExist(targetPath) {
        MsgBox, File %targetPath% does not exist.
        return
    }

    FileRead, jsonData, targetPath
    if (jsonData = "") {
        jsonData := "[]"
    }

    ; Parse and modify the JSON content.
    ; Remove trailing bracket from JSON array in order to append.
    jsonData := SubStr(jsonData, 1, StrLen(jsonData) - 1)

    ; Append to JSON array.
    if (jsonData != "[")
        jsonData .= ","
    jsonData .= "{""time"": """ A_Now """, ""variable"": " variableValue "}]"

    ; Write to file.
    FileDelete, targetPath
    FileAppend, jsonData, targetPath
}

FileSumJSON(sourcePath, targetPath := "") {
    if !FileExist(sourcePath) {
        MsgBox, File %sourcePath% does not exist.
        return
    }

    FileRead, jsonData, sourcePath
    if (jsonData = "") {
        return 0
    }

    ; Parse the JSON and calculate the sum.
    sum := 0

    ; Remove leading and trailing brackets from JSON array.
    jsonData := StrReplace(jsonData, "[", "")
    jsonData := StrReplace(jsonData, "]", "")

    ; Loop and sum.
    Loop, Parse, jsonContent, {, }
    {
        ; Match each variable value.
        if (RegExMatch(A_LoopField, """variable"":\s*(-?\d+)", match)) {
            sum += match1
        }
    }

    ; Store sum as a JSON object if a target file has been specified.
    if (targetPath != "") {
        totalData := "{""total_sum"": " sum "}"
        FileDelete, targetPath
        FileAppend, %totalData%, %targetPath%
    }

    return sum
}

FileDownload(url, targetPath) {
    URLDownloadToFile, %url%, targetPath
}
