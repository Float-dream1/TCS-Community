; TaCraft Player Community — Windows installer (custom flat UI)
;
; Page 1 is drawn from bitmaps: an orange banner across the top and bitmap
; buttons at the bottom right, all sitting on the stock NSIS page with the
; caption removed. Page 2 is the stock progress page.

Unicode true
SetCompressor /SOLID lzma
SetCompressorDictSize 64
RequestExecutionLevel user
CRCCheck on
SetDatablockOptimize on

!include "LogicLib.nsh"
!include "nsDialogs.nsh"
!include "MUI2.nsh"

!define PRODUCT_NAME "TaCraft Player Community"
!define APP_EXE "TaCraft-Player-Community.exe"
!define APP_VERSION "1.0.1"
!define PRODUCT_PUBLISHER "TCS Community"
!define INSTALL_DIR_NAME "TCS-Player-Community"
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\TCS-Player-Community"

Name "${PRODUCT_NAME}"
OutFile "TaCraft-Player-Community-${APP_VERSION}-setup.exe"
InstallDir "$LOCALAPPDATA\${INSTALL_DIR_NAME}"
InstallDirRegKey HKCU "Software\TCS-Player-Community" "InstallDir"
ShowInstDetails nevershow
ShowUninstDetails nevershow
AutoCloseWindow true
Icon "icon.ico"
UninstallIcon "icon.ico"

VIProductVersion "1.0.1.0"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${APP_VERSION}"
VIAddVersionKey "FileVersion" "${APP_VERSION}"
VIAddVersionKey "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey "LegalCopyright" "GPL-3.0"
VIAddVersionKey "FileDescription" "${PRODUCT_NAME} 安装程序"

Var Dialog
Var hBanner
Var hBannerImg
Var hDir
Var hShortcut
Var hRun
Var hInstallBtn
Var hInstallImg
Var hCancelBtn
Var hCancelImg
Var hCloseBtn
Var hCloseImg
Var MakeShortcut
Var RunAfter
Var hShortcutImg
Var hRunImg
Var hTmpImg

; --- frameless window -------------------------------------------------------
Function MakeFrameless
  System::Call 'user32::GetWindowLongW(p $HWNDPARENT, i -16) i .R3'
  IntOp $R3 $R3 & 0xFF30FFFF
  System::Call 'user32::SetWindowLongW(p $HWNDPARENT, i -16, i $R3)'
FunctionEnd

; SS_NOTIFY on a bitmap static: the picture is the button, clicks arrive
; as STN_CLICKED. The static paints itself, so nothing is lost behind it.
Function MakeClickable
  Exch $0
  System::Call 'user32::GetWindowLongW(p $0, i -16) i .R1'
  IntOp $R1 $R1 | 0x100
  System::Call 'user32::SetWindowLongW(p $0, i -16, i $R1)'
  Pop $0
FunctionEnd

; raise a control above the full-page bitmap
Function BringToTop
  Exch $0
  System::Call 'user32::SetWindowPos(p $0, p -1, i 0, i 0, i 0, i 0, i 0x0003)'
  Pop $0
FunctionEnd

Function OnToggleShortcut
  ${If} $MakeShortcut == 1
    StrCpy $MakeShortcut 0
    ${NSD_SetImage} $hShortcut "assets\check-shortcut-off.bmp" $hTmpImg
  ${Else}
    StrCpy $MakeShortcut 1
    ${NSD_SetImage} $hShortcut "assets\check-shortcut-on.bmp" $hTmpImg
  ${EndIf}
  Push $hShortcut
  Call BringToTop
  Pop $hShortcut
FunctionEnd

Function OnToggleRun
  ${If} $RunAfter == 1
    StrCpy $RunAfter 0
    ${NSD_SetImage} $hRun "assets\check-run-off.bmp" $hTmpImg
  ${Else}
    StrCpy $RunAfter 1
    ${NSD_SetImage} $hRun "assets\check-run-on.bmp" $hTmpImg
  ${EndIf}
  Push $hRun
  Call BringToTop
  Pop $hRun
FunctionEnd

Function OnCancelClick
  Quit
FunctionEnd

Function OnInstallClick
  ${NSD_GetText} $hDir $0
  ${If} $0 == ""
    MessageBox MB_ICONSTOP "$(errNoDir)"
    Return
  ${EndIf}
  StrCpy $INSTDIR $0
  ${NSD_GetState} $hShortcut $MakeShortcut
  ${NSD_GetState} $hRun $RunAfter
  ; same as pressing Next
  SendMessage $HWNDPARENT 0x0111 1 0
FunctionEnd

Function HideWizardButtons
  GetDlgItem $0 $HWNDPARENT 1
  ShowWindow $0 0
  GetDlgItem $0 $HWNDPARENT 2
  ShowWindow $0 0
FunctionEnd

Function PageMain
  nsDialogs::Create 1018
  Pop $Dialog
  ${If} $Dialog == error
    Abort
  ${EndIf}
  Call MakeFrameless
  Call HideWizardButtons
  System::Call 'user32::SetWindowTextW(p $HWNDPARENT, w "${PRODUCT_NAME} 安装")'

  ; one bitmap covers the whole page: banner on top, white body below
  ${NSD_CreateBitmap} 0 0 700 500 ""
  Pop $hBanner
  ${NSD_SetImage} $hBanner "assets\body.bmp" $hBannerImg
  System::Call 'user32::GetWindowLongW(p $hBanner, i -16) i .R1'
  IntOp $R1 $R1 & 0xFFFFFFFE
  System::Call 'user32::SetWindowLongW(p $hBanner, i -16, i $R1)'

  ${NSD_CreateText} 24 130 520 24 "$INSTDIR"
  Pop $hDir
  SetCtlColors $hDir 0x2F2A26 0xFFFFFF
  System::Call 'user32::InvalidateRect(p $hDir, p 0, i 1)'
  Push $hDir
  Call BringToTop
  Pop $hDir

  StrCpy $MakeShortcut 1
  StrCpy $RunAfter 1

  ${NSD_CreateBitmap} 24 208 280 20 ""
  Pop $hShortcut
  ${NSD_SetImage} $hShortcut "assets\check-shortcut-on.bmp" $hShortcutImg
  ${NSD_OnClick} $hShortcut OnToggleShortcut
  Push $hShortcut
  Call MakeClickable
  Pop $hShortcut
  Push $hShortcut
  Call BringToTop
  Pop $hShortcut

  ${NSD_CreateBitmap} 24 232 280 20 ""
  Pop $hRun
  ${NSD_SetImage} $hRun "assets\check-run-on.bmp" $hRunImg
  ${NSD_OnClick} $hRun OnToggleRun
  Push $hRun
  Call MakeClickable
  Pop $hRun
  Push $hRun
  Call BringToTop
  Pop $hRun

  ${NSD_CreateBitmap} 446 219 118 36 ""
  Pop $hInstallBtn
  ${NSD_SetImage} $hInstallBtn "assets\btn-install.bmp" $hInstallImg
  ${NSD_OnClick} $hInstallBtn OnInstallClick
  Push $hInstallBtn
  Call MakeClickable
  Pop $hInstallBtn
  Push $hInstallBtn
  Call BringToTop
  Pop $hInstallBtn

  ${NSD_CreateBitmap} 352 219 82 36 ""
  Pop $hCancelBtn
  ${NSD_SetImage} $hCancelBtn "assets\btn-cancel.bmp" $hCancelImg
  ${NSD_OnClick} $hCancelBtn OnCancelClick
  Push $hCancelBtn
  Call MakeClickable
  Pop $hCancelBtn
  Push $hCancelBtn
  Call BringToTop
  Pop $hCancelBtn

  ${NSD_CreateBitmap} 552 10 26 26 ""
  Pop $hCloseBtn
  ${NSD_SetImage} $hCloseBtn "assets\btn-close.bmp" $hCloseImg
  ${NSD_OnClick} $hCloseBtn OnCancelClick
  Push $hCloseBtn
  Call MakeClickable
  Pop $hCloseBtn
  Push $hCloseBtn
  Call BringToTop
  Pop $hCloseBtn

  nsDialogs::Show
FunctionEnd

Function PageMainLeave
  ${NSD_GetText} $hDir $0
  ${If} $0 == ""
    MessageBox MB_ICONSTOP "$(errNoDir)"
    Abort
  ${EndIf}
  StrCpy $INSTDIR $0
FunctionEnd

Page custom PageMain PageMainLeave
Page instfiles

Section "${PRODUCT_NAME}"
  SectionIn RO
  SetShellVarContext current

  SetOutPath "$INSTDIR"
  File "/oname=${APP_EXE}" "stage\TaCraft-Player-Community.exe"
  SetOutPath "$INSTDIR\resources"
  File /r "stage\resources\*.*"
  SetOutPath "$INSTDIR"

  WriteRegStr HKCU "Software\TCS-Player-Community" "InstallDir" "$INSTDIR"

  ${If} $MakeShortcut == 1
    CreateShortcut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0
  ${EndIf}
  CreateShortcut "$SMPROGRAMS\${PRODUCT_NAME}.lnk" "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  WriteRegStr HKCU "${UNINST_KEY}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKCU "${UNINST_KEY}" "DisplayVersion" "${APP_VERSION}"
  WriteRegStr HKCU "${UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr HKCU "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\${APP_EXE}"
  WriteRegStr HKCU "${UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKCU "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegDWORD HKCU "${UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINST_KEY}" "NoRepair" 1

  ${If} $RunAfter == 1
    Exec '"$INSTDIR\${APP_EXE}"'
  ${EndIf}
SectionEnd

Section "Uninstall"
  SetShellVarContext current
  Delete "$INSTDIR\${APP_EXE}"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR\resources"
  RMDir "$INSTDIR"

  Delete "$SMPROGRAMS\${PRODUCT_NAME}.lnk"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"

  DeleteRegKey HKCU "${UNINST_KEY}"
  DeleteRegKey HKCU "Software\TCS-Player-Community"
SectionEnd

; ---------------------------------------------------------------------------
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

LangString optShortcut   ${LANG_SIMPCHINESE} "创建桌面快捷方式"
LangString optRun        ${LANG_SIMPCHINESE} "安装完成后立即运行"
LangString errNoDir      ${LANG_SIMPCHINESE} "请填写一个安装位置。"

LangString optShortcut   ${LANG_ENGLISH} "Create a desktop shortcut"
LangString optRun        ${LANG_ENGLISH} "Launch ${PRODUCT_NAME} when done"
LangString errNoDir      ${LANG_ENGLISH} "Please choose an install location."
