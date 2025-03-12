global ExCheck, OneStarCheck, ThreeDiamondCheck, ExCount, OneStarCount, ThreeDiamondCount, MatchCount, ScreenshotAllPacks

IniRead, ExCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, ExCheck, 0
IniRead, OneStarCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, OneStarCheck, 0
IniRead, ThreeDiamondCheck, %A_ScriptDir%\..\Settings.ini, UserSettings, ThreeDiamondCheck, 0
IniRead, ExCount, %A_ScriptDir%\..\Settings.ini, UserSettings, ExCount, 1
IniRead, OneStarCount, %A_ScriptDir%\..\Settings.ini, UserSettings, OneStarCount, 1
IniRead, ThreeDiamondCount, %A_ScriptDir%\..\Settings.ini, UserSettings, ThreeDiamondCount, 1
IniRead, MatchCount, Settings.ini, UserSettings, MatchCount, 1
IniRead, ScreenshotAllPacks, Settings.ini, UserSettings, ScreenshotAllPacks, 0

ExCount := Trim(StrReplace(ExCount, "x", ""))
OneStarCount := Trim(StrReplace(OneStarCount, "x", ""))
ThreeDiamondCount := Trim(StrReplace(ThreeDiamondCount, "x", ""))

CheckPack3477() {
    global scriptName, DeadCheck

    if (ScreenshotAllPacks) {
        Loop {
            if (FindBorders("lag") = 0)
                break
            Delay(1)
        }

        Screenshot("Opened")
    }

    foundGP := false
    foundFullArt := false
    foundRainbow := false
    found2starCount := 0
    foundTrainer := false
    foundExCount := 0
    found1starCount := 0
    found3diamondCount := 0
    foundImmersive := false
    foundCrown := false
    foundLabel := ""
    foundGP := FindGodPack()
    foundInvalid := FindBorders("immersive") + FindBorders("crown")

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
                checkCount++
        }
        if (ThreeDiamondCheck) {
            found3diamondCount := FindBorders3477("3diamond")
            if (found3diamondCount >= ThreeDiamondCount)
                checkCount++
        }

        if (checkCount >= MatchCount)
            foundLabel := "Good Pack"
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
    global scriptName, DeadCheck
    IniWrite, 0, %A_ScriptDir%\..\%scriptName%.ini, UserSettings, DeadCheck

    screenShot := Screenshot(foundLabel)
    accountFile := saveAccount(foundLabel)
    friendCode := getFriendCode()

    logMessage := foundLabel . " found by " . username . " (" . friendCode . ") in instance: " . scriptName . " (" . packs . " packs)\nFile name: " . accountFile . "\nBacking up to the Accounts\\SpecificCards folder and continuing..."
    CreateStatusMessage(logMessage)
    LogToFile(logMessage, "GPlog.txt")
    LogToDiscord(logMessage, screenShot, discordUserId, "", "")

    if(foundLabel = "Crown" || foundLabel = "Immersive")
        RemoveFriends()
}
