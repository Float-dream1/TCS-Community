; TaCraft Player Community — Windows installer (plain NSIS wizard)
;
; Deliberately the same shape as the 7-Zip installer: welcome → target folder →
; progress → finish, all standard MUI pages, Simplified Chinese first, no
; frameless tricks. Fast and predictable on every Windows box.

Unicode true
SetCompressor /SOLID lzma
SetCompressorDictSize 64
RequestExecutionLevel user
CRCCheck on
SetDatablockOptimize on

!include "MUI2.nsh"
!include "LogicLib.nsh"

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
Icon "icon.ico"
UninstallIcon "icon.ico"

VIProductVersion "1.0.1.0"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${APP_VERSION}"
VIAddVersionKey "FileVersion" "${APP_VERSION}"
VIAddVersionKey "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey "LegalCopyright" "GPL-3.0"
VIAddVersionKey "FileDescription" "${PRODUCT_NAME} 安装程序"

; --- look -------------------------------------------------------------------
!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"
!define MUI_ABORTWARNING
!define MUI_WELCOMEFINISHPAGE_BITMAP "assets\welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "assets\welcome.bmp"

!define MUI_WELCOMEPAGE_TITLE "$(welcomeTitle)"
!define MUI_WELCOMEPAGE_TEXT "$(welcomeText)"
!define MUI_DIRECTORYPAGE_TEXT_TOP "$(dirText)"
!define MUI_FINISHPAGE_TITLE "$(finishTitle)"
!define MUI_FINISHPAGE_TEXT "$(finishText)"
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_EXE}"
!define MUI_FINISHPAGE_RUN_TEXT "$(runText)"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

LangString welcomeTitle ${LANG_SIMPCHINESE} "欢迎使用 ${PRODUCT_NAME} ${APP_VERSION} 安装向导"
LangString welcomeText  ${LANG_SIMPCHINESE} "现在将把 ${PRODUCT_NAME} ${APP_VERSION} 安装到你的计算机上。$\r$\n$\r$\n点「下一步」继续，点「取消」退出安装。"
LangString dirText      ${LANG_SIMPCHINESE} "选择 ${PRODUCT_NAME} 的安装位置，然后点「安装」。"
LangString finishTitle  ${LANG_SIMPCHINESE} "已完成 ${PRODUCT_NAME} 安装"
LangString finishText   ${LANG_SIMPCHINESE} "${PRODUCT_NAME} ${APP_VERSION} 已经装好了。游戏数据会保存在 %APPDATA%\TCS-Community。"
LangString runText      ${LANG_SIMPCHINESE} "立即运行 ${PRODUCT_NAME}"

LangString welcomeTitle ${LANG_ENGLISH} "Welcome to the ${PRODUCT_NAME} ${APP_VERSION} Setup Wizard"
LangString welcomeText  ${LANG_ENGLISH} "This wizard will install ${PRODUCT_NAME} ${APP_VERSION} on your computer.$\r$\n$\r$\nClick Next to continue, or Cancel to quit."
LangString dirText      ${LANG_ENGLISH} "Choose where to install ${PRODUCT_NAME}, then click Install."
LangString finishTitle  ${LANG_ENGLISH} "${PRODUCT_NAME} has been installed"
LangString finishText   ${LANG_ENGLISH} "${PRODUCT_NAME} ${APP_VERSION} is ready to use. Game data lives in %APPDATA%\TCS-Community."
LangString runText      ${LANG_ENGLISH} "Launch ${PRODUCT_NAME}"

; --- install ----------------------------------------------------------------
Section "${PRODUCT_NAME}"
  SectionIn RO
  SetShellVarContext current

  SetOutPath "$INSTDIR"
  File "/oname=${APP_EXE}" "stage\TaCraft-Player-Community.exe"
  SetOutPath "$INSTDIR\resources"
  File /r "stage\resources\*.*"
  SetOutPath "$INSTDIR"

  WriteRegStr HKCU "Software\TCS-Player-Community" "InstallDir" "$INSTDIR"

  CreateShortcut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0
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
