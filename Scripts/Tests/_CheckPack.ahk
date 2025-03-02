#Include %A_ScriptDir%\..\Include\Gdip_All.ahk
#Include %A_ScriptDir%\..\Include\Gdip_Imagesearch.ahk

#SingleInstance, Force
SetBatchLines, -1
SetTitleMatchMode, 3
CoordMode, Pixel, Screen

if not A_IsAdmin {
    ; Relaunch script with admin rights.
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

global scriptName, screenshotFilePath, ExCheck, OneStarCheck, ThreeDiamondCheck, ExCount, OneStarCount, ThreeDiamondCount, TrainerCheck, FullArtCheck, RainbowCheck, CrownCheck, ImmersiveCheck, PseudoGodPack, minStars

scriptName := StrReplace(A_ScriptName, ".ahk")
screenshotFilePath := A_ScriptDir . "\_CheckPack\screenshot.png"

if (!FileExist(screenshotFilePath)) {
    MsgBox, % "No screenshot found! Exiting..."
    ExitApp
}

IniRead, ExCheck, %A_ScriptDir%\..\..\Settings.ini, UserSettings, ExCheck, 0
IniRead, OneStarCheck, %A_ScriptDir%\..\..\Settings.ini, UserSettings, OneStarCheck, 0
IniRead, ThreeDiamondCheck, %A_ScriptDir%\..\..\Settings.ini, UserSettings, ThreeDiamondCheck, 0
IniRead, ExCount, %A_ScriptDir%\..\..\Settings.ini, UserSettings, ExCount, 1
IniRead, OneStarCount, %A_ScriptDir%\..\..\Settings.ini, UserSettings, OneStarCount, 1
IniRead, ThreeDiamondCount, %A_ScriptDir%\..\..\Settings.ini, UserSettings, ThreeDiamondCount, 1
IniRead, TrainerCheck, %A_ScriptDir%\..\..\Settings.ini, UserSettings, TrainerCheck, 0
IniRead, FullArtCheck, %A_ScriptDir%\..\..\Settings.ini, UserSettings, FullArtCheck, 0
IniRead, RainbowCheck, %A_ScriptDir%\..\..\Settings.ini, UserSettings, RainbowCheck, 0
IniRead, CrownCheck, %A_ScriptDir%\..\..\Settings.ini, UserSettings, CrownCheck, 0
IniRead, ImmersiveCheck, %A_ScriptDir%\..\..\Settings.ini, UserSettings, ImmersiveCheck, 0
IniRead, PseudoGodPack, %A_ScriptDir%\..\..\Settings.ini, UserSettings, PseudoGodPack, 0
IniRead, minStars, %A_ScriptDir%\..\..\Settings.ini, UserSettings, minStars, 0

ExCount := StrReplace(ExCount, "x ", "")
OneStarCount := StrReplace(OneStarCount, "x ", "")
ThreeDiamondCount := StrReplace(ThreeDiamondCount, "x ", "")

pToken := Gdip_Startup()

global borderCoords := [[30, 284, 83, 286]
        ,[113, 284, 166, 286]
        ,[196, 284, 249, 286]
        ,[70, 399, 123, 401]
        ,[155, 399, 208, 401]]

global borderNeedles := ["normal"
    ,"3diamond"
    ,"1star"
    ,"fullart"
    ,"rainbow"
    ,"trainer"
    ,"immersive"
    ,"crown"]
; "ex" is not included in the arrays above because there is no reliable way of
; identifying a 4-diamond EX card which is compatible with all languages (other
; than having 5 needle images per language...)

global bordersFound := {"3diamond": 0
    ,"ex": 0
    ,"1star": 0
    ,"fullart": 0
    ,"rainbow": 0
    ,"trainer": 0
    ,"immersive": 0
    ,"crown": 0}

CheckPack() {
    ; Increment pack count.
    packs += 1
    if (packMethod)
        packs := 1

    ; What types of cards are in this pack?
    bordersFound := {"3diamond": 0
        ,"ex": 0
        ,"1star": 0
        ,"fullart": 0
        ,"rainbow": 0
        ,"trainer": 0
        ,"immersive": 0
        ,"crown": 0}

    for index, coords in borderCoords {
        borderFound := CheckCardSlot(index)
        bordersFound[borderFound] := bordersFound[borderFound] + 1
    }

    foundLabel := ["The pack in the screenshot..."]

    found1starCount := bordersFound["1star"]
    found2starCount := bordersFound["fullart"] + bordersFound["rainbow"] + bordersFound["trainer"] + bordersFound["immersive"] + bordersFound["crown"]
    foundValid2starCount := bordersFound["fullart"] + bordersFound["rainbow"] + bordersFound["trainer"]

    foundGP := false
    if ((found2starCount + found1starCount) = 5) {
        if ((foundValid2starCount + found1starCount) = 5 && (minStars = 0 || foundValid2starCount >= minStars))
            foundLabel.push("- is a God Pack!")
        else
            foundLabel.push("- is an invalid God Pack")
    }

    foundInvalid := bordersFound["immersive"] + bordersFound["crown"]

    foundLabel.push("- contains " . bordersFound["immersive"] . " immersive cards")
    foundLabel.push("- contains " . bordersFound["crown"] . " crown cards")
    foundLabel.push("- contains " . bordersFound["fullart"] . " full art cards")
    foundLabel.push("- contains " . bordersFound["rainbow"] . " rainbow cards")
    foundLabel.push("- contains " . foundValid2starCount . " 2-star cards")
    foundLabel.push("- contains " . bordersFound["trainer"] . " 2-star trainer cards")

    foundExCount := bordersFound["ex"]
    foundLabel.push("- contains " . foundExCount . " EX cards")

    found1starCount := bordersFound["1star"]
    foundLabel.push("- contains " . found1starCount . " 1-star cards")

    found3diamondCount := bordersFound["3diamond"]
    foundLabel.push("- contains " . found3diamondCount . " 3-diamond cards")

    MsgBox % ArrayJoin(foundLabel)
}

CheckCardSlot(slotIndex) {
    borderFound := ""

    checkCoords := borderCoords[slotIndex]
    searchVariation := 5
    pBitmap := Gdip_CreateBitmapFromFile(screenshotFilePath)

    for index, needleName in borderNeedles {
        needlePath = %A_ScriptDir%\..\Scale125\%needleName%%slotIndex%.png

        if (!FileExist(needlePath))
            continue

        pNeedle := GetNeedle(needlePath)
        vRet := Gdip_ImageSearch(pBitmap, pNeedle, vPosXY, checkCoords[1], checkCoords[2], checkCoords[3], checkCoords[4], searchVariation)
        if (vRet = 1) {
            borderFound := needleName
            break
        }
    }

    Gdip_DisposeImage(pBitmap)

    ; If a border hasn't been identified, assume there is a 4-diamond EX card in the current slot.
    if (borderFound = "")
        borderFound := "ex"

    return borderFound
}

GetNeedle(Path) {
    static NeedleBitmaps := Object()
    if (NeedleBitmaps.HasKey(Path)) {
        return NeedleBitmaps[Path]
    } else {
        pNeedle := Gdip_CreateBitmapFromFile(Path)
        NeedleBitmaps[Path] := pNeedle
        return pNeedle
    }
}

ArrayJoin(Array) {
    for k, v in Array
        Out .= "`n" . v
    return Out
}

CheckPack()
ExitApp
