global ExCheck, OneStarCheck, ThreeDiamondCheck, ExCount, OneStarCount, ThreeDiamondCount, MatchCount, ReportAllPacks
global ExS4T, OneStarS4T, ThreeDiamondS4T, ReportS4T

IniRead, ExCheck, Settings.ini, UserSettings, ExCheck, 0
IniRead, OneStarCheck, Settings.ini, UserSettings, OneStarCheck, 0
IniRead, ThreeDiamondCheck, Settings.ini, UserSettings, ThreeDiamondCheck, 0
IniRead, ExCount, Settings.ini, UserSettings, ExCount, 1
IniRead, OneStarCount, Settings.ini, UserSettings, OneStarCount, 1
IniRead, ThreeDiamondCount, Settings.ini, UserSettings, ThreeDiamondCount, 1
IniRead, MatchCount, Settings.ini, UserSettings, MatchCount, 1
IniRead, ReportAllPacks, Settings.ini, UserSettings, ReportAllPacks, 0
IniRead, ExS4T, Settings.ini, UserSettings, ExS4T, 0
IniRead, OneStarS4T, Settings.ini, UserSettings, OneStarS4T, 0
IniRead, ThreeDiamondS4T, Settings.ini, UserSettings, ThreeDiamondS4T, 0
IniRead, ReportS4T, Settings.ini, UserSettings, ReportS4T, 0

ExCount := Trim(StrReplace(ExCount, "x", ""))
OneStarCount := Trim(StrReplace(OneStarCount, "x", ""))
ThreeDiamondCount := Trim(StrReplace(ThreeDiamondCount, "x", ""))

CheckPack3477() {
    if (ReportAllPacks) {
        Loop {
            if (FindBorders("lag") = 0)
                break
            Delay(1)
        }

        screenShot := Screenshot("Opened")

        logMessage := "Pack opened by " . username . " in instance: " . scriptName . ". Continuing..."
        LogToDiscord(logMessage, screenShot)
    }

    foundGP := false
    foundFullArt := false
    foundRainbow := false
    found2starCount := 0
    foundTrainer := false
    foundExCount := 0
    found1starCount := 0
    found3diamondCount := 0
    foundShiny := false
    foundImmersive := false
    foundCrown := false
    foundLabel := ""
    foundGP := FindGodPack()
    foundInvalid := FindBorders("immersive") + FindBorders("crown") + FindBorders("shiny2star") + FindBorders("shiny1star")

    if (!foundGP && !foundInvalid) {
        checkCount := 0

        if (FullArtCheck) {
            foundFullArt := FindBorders("fullart")
            if (foundFullArt)
                checkCount++
        }
        if (RainbowCheck) {
            foundRainbow := FindBorders("rainbow")
            if (foundRainbow)
                checkCount++
        }
        if (PseudoGodPack) {
            found2starCount := FindBorders("trainer") + FindBorders("rainbow") + FindBorders("fullart")
            if (found2starCount > 1)
                checkCount++
        }
        if (TrainerCheck) {
            foundTrainer := FindBorders("trainer")
            if (foundTrainer)
                checkCount++
        }
        if (ExCheck && !foundFullArt && !foundRainbow) {
            foundExCount := FindExRule()
            if (foundExCount >= ExCount)
                checkCount++
        }
        if (OneStarCheck) {
            found1starCount := FindBorders("1star")
            if (found1starCount >= OneStarCount)
                checkCount += found1starCount
        }
        if (ThreeDiamondCheck) {
            found3diamondCount := FindBorders3477("3diamond")
            if (found3diamondCount >= ThreeDiamondCount)
                checkCount += found3diamondCount
        }

        if (checkCount >= MatchCount)
            foundLabel := "Good Pack"
    }

    if (ShinyCheck && !foundLabel) {
        foundShiny := FindBorders("shiny2star") + FindBorders("shiny1star")
        if (foundShiny)
            foundLabel := "Shiny"
    }
    if (ImmersiveCheck && !foundLabel) {
        foundImmersive := FindBorders("immersive")
        if (foundImmersive)
            foundLabel := "Immersive"
    }
    if (CrownCheck && !foundLabel) {
        foundCrown := FindBorders("crown")
        if (foundCrown)
            foundLabel := "Crown"
    }

    if (foundGP || foundLabel) {
        if (loadedAccount) {
            FileDelete, %loadedAccount% ;delete xml file from folder if using inject method
            IniWrite, 0, %A_ScriptDir%\..\%scriptName%.ini, UserSettings, DeadCheck
        }
        if (foundGP) {
            restartGameInstance("God Pack found. Continuing...", "GodPack") ; restarts to backup and delete xml file with account info.
        } else if (foundLabel) {
            FoundGood(foundLabel)
            restartGameInstance(foundLabel . " found. Continuing...", "GodPack") ; restarts to backup and delete xml file with account info.
        }
    } else {
        savedForTrade := false

        if (!savedForTrade && ExS4T) {
            if (!(ExCheck && foundExCount = 0)) {
                foundExCount := FindExRule()
                if (foundExCount > 0) {
                    SaveForTrade("EX", foundExCount)
                    savedForTrade := true
                }
            }
        }
        if (!savedForTrade && OneStarS4T) {
            if (!(OneStarCheck && OneStarCount = 0)) {
                found1starCount := FindBorders("1star")
                if (found1starCount > 0) {
                    SaveForTrade("One Star", found1starCount)
                    savedForTrade := true
                }
            }
        }
        if (!savedForTrade && ThreeDiamondS4T) {
            if (!(ThreeDiamondCheck && ThreeDiamondCount    = 0)) {
                found3diamondCount := FindBorders3477("3diamond")
                if (found3diamondCount > 0) {
                    SaveForTrade("Three Diamond", found3diamondCount)
                    savedForTrade := true
                }
            }
        }
    }
}

FindBorders3477(prefix) {
    count := 0
    searchVariation := 40
    borderCoords := [[30, 284, 83, 286]
        ,[113, 284, 166, 286]
        ,[196, 284, 249, 286]
        ,[70, 399, 123, 401]
        ,[155, 399, 208, 401]]
    pBitmap := from_window(WinExist(winTitle))
    for index, value in borderCoords {
        coords := borderCoords[A_Index]
        Path = %A_ScriptDir%\3477\Assets\Needles\%prefix%%A_Index%.png
        pNeedle := GetNeedle(Path)
        vRet := Gdip_ImageSearch(pBitmap, pNeedle, vPosXY, coords[1], coords[2], coords[3], coords[4], searchVariation)
        if (vRet = 1) {
            count += 1
        }
    }
    Gdip_DisposeImage(pBitmap)
    return count
}

FindExRule() {
    count := 0
    searchVariation := 40
    ruleCoords := [[45, 277, 88, 279]
        ,[128, 277, 171, 279]
        ,[211, 277, 254, 279]
        ,[85, 392, 128, 394]
        ,[170, 392, 213, 394]]
    pBitmap := from_window(WinExist(winTitle))
    for index, value in ruleCoords {
        coords := ruleCoords[A_Index]
        ; @TODO Add support for other languages. Needles for each supported language required.
        Path = %A_ScriptDir%\3477\Assets\Needles\ENG\4diamond%A_Index%.png
        pNeedle := GetNeedle(Path)
        vRet := Gdip_ImageSearch(pBitmap, pNeedle, vPosXY, coords[1], coords[2], coords[3], coords[4], searchVariation)
        if (vRet = 1) {
            count += 1
        }
    }
    Gdip_DisposeImage(pBitmap)
    return count
}

FoundGood(foundLabel) {
    IniWrite, 0, %A_ScriptDir%\..\%scriptName%.ini, UserSettings, DeadCheck

    fileName := StrReplace(foundLabel, " ", "_")

    screenShot := Screenshot(fileName)
    accountFile := saveAccount(fileName)
    friendCode := getFriendCode()

    CreateStatusMessage(foundLabel . " found!")

    logMessage := foundLabel . " found by " . username . " (" . friendCode . ") in instance: " . scriptName . " (" . packs . " packs)\nFile name: " . accountFile . "\nBacking up to the Accounts\\SpecificCards folder and continuing..."
    LogToFile(logMessage, "GPlog.txt")
    LogToDiscord(logMessage, screenShot, discordUserId)

    if (foundLabel = "Crown" || foundLabel = "Immersive")
        RemoveFriends()
}

SaveForTrade(cardType, cardCount) {
    ; @TODO Get friend code for file name(s) and log message(s).
    ;friendCode := getFriendCode()
    friendCode := "@TODO"

    fileName := openPack . "_" . StrReplace(cardType, " ", "_") . "_x" . cardCount

    screenShot := Screenshot(fileName)
    accountFile := saveAccount3477(fileName, "Accounts\Trades")

    CreateStatusMessage("Account saved for trading!")

    if (ReportS4T) {
        logMessage := cardCount . " " . cardType . " card(s) found by " . username . " in instance: " . scriptName . "\nFile name: " . accountFile . "\nBacking up to the Accounts\\Trades folder and continuing..."
        LogToFile(logMessage, "GPlog.txt")
        LogToDiscord(logMessage, screenShot, discordUserId)
    }
}

saveAccount3477(file, folder) {
    saveDir := A_ScriptDir . "\..\" . folder . "\"
    xmlFile := A_Now . "_" . file . "_" . packs . "_packs.xml"
    filePath := saveDir . xmlFile

    if !FileExist(saveDir) ; Check if the directory exists
        FileCreateDir, %saveDir% ; Create the directory if it doesn't exist

    count := 0
    Loop {
        CreateStatusMessage("Attempting to save account XML. " . count . "/10")

        adbShell.StdIn.WriteLine("cp -f /data/data/jp.pokemon.pokemontcgp/shared_prefs/deviceAccount:.xml /sdcard/deviceAccount.xml")
        waitadb()
        Sleep, 500

        RunWait, % adbPath . " -s 127.0.0.1:" . adbPort . " pull /sdcard/deviceAccount.xml """ . filePath,, Hide

        Sleep, 500

        adbShell.StdIn.WriteLine("rm /sdcard/deviceAccount.xml")

        Sleep, 500

        FileGetSize, OutputVar, %filePath%

        if (OutputVar > 0)
            break

        if (count > 10 && file != "All") {
            CreateStatusMessage("Attempted to save the account XML`n10 times, but was unsuccesful.`nPausing...")
            LogToDiscord("Attempted to save account in " . scriptName . " but was unsuccessful. Pausing. You will need to manually extract.", Screenshot(), discordUserId)
            Pause, On
        } else if (count > 10) {
            LogToDiscord("Couldnt save this regular account. Skipping it.")
            break
        }
        count++
    }

    return xmlFile
}
