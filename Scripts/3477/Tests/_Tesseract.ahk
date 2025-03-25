#Include %A_ScriptDir%\..\..\Include\Gdip_All.ahk
#Include %A_ScriptDir%\..\..\Include\Gdip_Imagesearch.ahk

#Include *i %A_ScriptDir%\..\..\Include\Gdip_Extra.ahk

#SingleInstance, Force
SetBatchLines, -1
SetTitleMatchMode, 3
CoordMode, Pixel, Screen

global winTitle := "Main"
global tesseractPath := "C:\Program Files\Tesseract-OCR\tesseract.exe"

Gdip_Startup()

Screenshot(filename := "Screenshot") {
    SetWorkingDir %A_ScriptDir%  ; Ensures the working directory is the script's directory

    ; Define folder and file paths
    screenshotsDir := A_ScriptDir . "\_Tesseract"
    if !FileExist(screenshotsDir)
        FileCreateDir, %screenshotsDir%

    ; File path for saving the screenshot locally
    screenshotFile := screenshotsDir . "\" . A_Now . "_" . winTitle . "_" . filename . ".png"

    pBitmap := from_window(WinExist(winTitle))
    result := Gdip_SaveBitmapToFile(pBitmap, screenshotFile)

    Gdip_DisposeImage(pBitmap)

    return screenshotFile
}

ScreenshotRegion(x, y, width, height, ByRef outputFilename, filename := "ScreenshotRegion", screenshotFilePath := "") {
    ; Load bitmap from window
    if (screenshotFilePath) {
        pBitmapWindow := Gdip_CreateBitmapFromFile(screenshotFilePath)
    } else {
        pBitmapWindow := from_window(WinExist(winTitle))
    }

    ; Create new cropped bitmap
    pBitmapRegion := Gdip_CreateBitmap(width, height)
    gRegion := Gdip_GraphicsFromImage(pBitmapRegion)
    Gdip_SetSmoothingMode(gRegion, 0)  ; High quality

    ; Draw cropped region from the original bitmap onto the new one
    Gdip_DrawImage(gRegion, pBitmapWindow, 0, 0, width, height, x, y, width, height)

    ; Increase contrast and convert to grayscale using a color matrix
    contrast := 25  ; Adjust contrast level (-100 to 100)
    factor := (100.0 + contrast) / 100.0
    factor := factor * factor

    ; Grayscale conversion with contrast applied
    redFactor := 0.299 * factor
    greenFactor := 0.587 * factor
    blueFactor := 0.114 * factor
    xFactor := 0.5 * (1 - factor)
    colorMatrix := redFactor . "|" . redFactor . "|" . redFactor . "|0|0|" . greenFactor . "|" . greenFactor . "|" . greenFactor . "|0|0|" . blueFactor . "|" . blueFactor . "|" . blueFactor . "|0|0|0|0|0|1|0|" . xFactor . "|" . xFactor . "|" . xFactor . "|0|1"

    ; Apply the color matrix
    Gdip_DrawImage(gRegion, pBitmapRegion, 0, 0, width, height, 0, 0, width, height, colorMatrix)

    ; Define folder and file paths
    screenshotsDir := A_ScriptDir . "\_Tesseract\tmp"
    if !FileExist(screenshotsDir)
        FileCreateDir, %screenshotsDir%

    ; File path for saving the screenshot locally
    screenshotFile := screenshotsDir "\" . winTitle . "_" . filename . ".png"

    ; Save the cropped image
    saveResult := Gdip_SaveBitmapToFile(pBitmapRegion, screenshotFile, 100)
    if (saveResult != 0) {
        MsgBox % "Failed to save " . filename . " screenshot.`nError code: " . saveResult
        saveResult := false
    }
    else {
        outputFilename := screenshotFile
        saveResult := true
    }

    ; Clean up resources
    Gdip_DeleteGraphics(gRegion)
    Gdip_DisposeImage(pBitmapWindow)
    Gdip_DisposeImage(pBitmapRegion)

    return saveResult
}

from_window(ByRef image) {
    ; Thanks tic - https://www.autohotkey.com/boards/viewtopic.php?t=6517

    ; Get the handle to the window.
    image := (hwnd := WinExist(image)) ? hwnd : image

    ; Restore the window if minimized! Must be visible for capture.
    if DllCall("IsIconic", "ptr", image)
        DllCall("ShowWindow", "ptr", image, "int", 4)

    ; Get the width and height of the client window.
    VarSetCapacity(Rect, 16) ; sizeof(RECT) = 16
    DllCall("GetClientRect", "ptr", image, "ptr", &Rect)
        , width  := NumGet(Rect, 8, "int")
        , height := NumGet(Rect, 12, "int")

    ; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
    hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
    VarSetCapacity(bi, 40, 0)                ; sizeof(bi) = 40
        , NumPut(       40, bi,  0,   "uint") ; Size
        , NumPut(    width, bi,  4,   "uint") ; Width
        , NumPut(  -height, bi,  8,    "int") ; Height - Negative so (0, 0) is top-left.
        , NumPut(        1, bi, 12, "ushort") ; Planes
        , NumPut(       32, bi, 14, "ushort") ; BitCount / BitsPerPixel
        , NumPut(        0, bi, 16,   "uint") ; Compression = BI_RGB
        , NumPut(        3, bi, 20,   "uint") ; Quality setting (3 = low quality, no anti-aliasing)
    hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", &bi, "uint", 0, "ptr*", pBits:=0, "ptr", 0, "uint", 0, "ptr")
    obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

    ; Print the window onto the hBitmap using an undocumented flag. https://stackoverflow.com/a/40042587
    DllCall("PrintWindow", "ptr", image, "ptr", hdc, "uint", 0x3) ; PW_CLIENTONLY | PW_RENDERFULLCONTENT
    ; Additional info on how this is implemented: https://www.reddit.com/r/windows/comments/8ffr56/altprintscreen/

    ; Convert the hBitmap to a Bitmap using a built in function as there is no transparency.
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hbm, "ptr", 0, "ptr*", pBitmap:=0)

    ; Cleanup the hBitmap and device contexts.
    DllCall("SelectObject", "ptr", hdc, "ptr", obm)
    DllCall("DeleteObject", "ptr", hbm)
    DllCall("DeleteDC",  "ptr", hdc)

    return pBitmap
}

GetTextFromImage(inputFilename) {
    SplitPath, inputFilename, FileName, , , FileNameNoExt
    ; --- Call Tesseract OCR ------------------------------------------------------
    ; Tesseract is a command-line utility. It takes an input image and an output base.
    ; The OCR result is written to "FileNameNoExt.txt". Adjust parameters as desired.
    outputBase := A_ScriptDir . "\_Tesseract\tmp\" . FileNameNoExt

    RunWait, %ComSpec% /c ""%tesseractPath%" "%inputFilename%" "%outputBase%" --oem 3 --psm 7", , Hide

    outputFilename := outputBase ".txt"
    FileRead, ocrText, %outputFilename%
    if (ErrorLevel) {
        MsgBox, 16, Error, % "Failed to read OCR output from " . outputFilename
    }

    return ocrText
}

Screenshot()

if (ScreenshotRegion(71, 158, 110, 17, capturedScreenshot, "ScreenshotRegion")) {
    MsgBox % GetTextFromImage(capturedScreenshot)
}

ExitApp
