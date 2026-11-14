; TaCraft Player Community — Windows installer
;
; Built on Linux with the Windows build of makensis under wine, see
; build-installer.sh in this directory. The UI uses Modern UI 2 with a custom
; orange/white welcome bitmap so the installer matches the launcher itself.

Unicode true
SetCompressor /SOLID lzma
SetCompressorDictSize 64
RequestExecutionLevel user

!define PRODUCT_NAME "TaCraft Player Community"
!define PRODUCT_SHORT "TaCraft Player Community"
!define INSTALL_DIR_NAME "TCS-Player-Community"
!define APP_EXE "TaCraft-Player-Community.exe"
!define APP_VERSION "1.0.1"
!define PRODUCT_PUBLISHER "TCS Community"
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\TCS-Player-Community"

Name "${PRODUCT_NAME}"
BrandingText "${PRODUCT_NAME} ${APP_VERSION}"
OutFile "TaCraft-Player-Community-${APP_VERSION}-setup.exe"
InstallDir "$LOCALAPPDATA\${INSTALL_DIR_NAME}"
InstallDirRegKey HKCU "Software\TCS-Player-Community" "InstallDir"

VIProductVersion "1.0.1.0"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${APP_VERSION}"
VIAddVersionKey "FileVersion" "${APP_VERSION}"
VIAddVersionKey "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey "LegalCopyright" "GPL-3.0"
VIAddVersionKey "FileDescription" "${PRODUCT_NAME} 安装程序"

; ---------------------------------------------------------------- modern UI
!include "MUI2.nsh"

!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"
!define MUI_ABORTWARNING
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "assets\header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "assets\welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "assets\welcome.bmp"

!define MUI_WELCOMEPAGE_TITLE "$(welcomeTitle)"
!define MUI_WELCOMEPAGE_TEXT "$(welcomeText)"
!define MUI_DIRECTORYPAGE_TEXT_TOP "$(instDirText)"
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_EXE}"
!define MUI_FINISHPAGE_RUN_TEXT "$(finishRun)"
!define MUI_FINISHPAGE_TITLE "$(finishTitle)"
!define MUI_FINISHPAGE_TEXT "$(finishText)"

; Simplified Chinese is loaded first, so it is the language the installer
; starts in. English is kept as a second string table for future builds.
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!define MUI_UNTEXT_CONFIRM_TITLE "$(unConfirmTitle)"
!define MUI_UNTEXT_CONFIRM_SUBTITLE "$(unConfirmSubtitle)"
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

LangString welcomeTitle ${LANG_SIMPCHINESE} "欢迎安装 ${PRODUCT_NAME}"
LangString welcomeText ${LANG_SIMPCHINESE} "正在准备安装 ${PRODUCT_NAME} ${APP_VERSION}。$\r$\n$\r$\n这会为当前用户安装启动器，无需管理员权限，也不会改动系统目录。$\r$\n$\r$\n点「下一步」继续。"
LangString instDirText ${LANG_SIMPCHINESE} "请选择 ${PRODUCT_NAME} 的安装位置。"
LangString finishRun ${LANG_SIMPCHINESE} "立即运行 ${PRODUCT_NAME}"
LangString finishTitle ${LANG_SIMPCHINESE} "${PRODUCT_NAME} 已安装完成"
LangString finishText ${LANG_SIMPCHINESE} "${PRODUCT_NAME} ${APP_VERSION} 已经装好了。$\r$\n$\r$\n游戏数据会保存在 %APPDATA%\TCS-Community，卸载时不会删除。"
LangString unConfirmTitle ${LANG_SIMPCHINESE} "卸载 ${PRODUCT_NAME}"
LangString unConfirmSubtitle ${LANG_SIMPCHINESE} "游戏数据 %APPDATA%\TCS-Community 会保留，卸载后不会删除。"
LangString secMain ${LANG_SIMPCHINESE} "${PRODUCT_NAME} 主程序"

LangString welcomeTitle ${LANG_ENGLISH} "Welcome to ${PRODUCT_NAME}"
LangString welcomeText ${LANG_ENGLISH} "This will install ${PRODUCT_NAME} ${APP_VERSION} for the current user.$\r$\n$\r$\nNo administrator rights are required and no system directory is touched.$\r$\n$\r$\nClick Next to continue."
LangString instDirText ${LANG_ENGLISH} "Choose where ${PRODUCT_NAME} should be installed."
LangString finishRun ${LANG_ENGLISH} "Launch ${PRODUCT_NAME}"
LangString finishTitle ${LANG_ENGLISH} "${PRODUCT_NAME} is installed"
LangString finishText ${LANG_ENGLISH} "${PRODUCT_NAME} ${APP_VERSION} is ready to use.$\r$\n$\r$\nGame data lives in %APPDATA%\TCS-Community and is kept when you uninstall."
LangString unConfirmTitle ${LANG_ENGLISH} "Remove ${PRODUCT_NAME}"
LangString unConfirmSubtitle ${LANG_ENGLISH} "Game data in %APPDATA%\TCS-Community is kept after uninstalling."
LangString secMain ${LANG_ENGLISH} "${PRODUCT_NAME} application"

; ---------------------------------------------------------------- sections
Section "$(secMain)" SecMain
  SectionIn RO
  SetShellVarContext current
  SetOutPath "$INSTDIR"

  File "/oname=${APP_EXE}" "stage\TaCraft-Player-Community.exe"
  SetOutPath "$INSTDIR\resources"
  File /r "stage\resources\*.*"

  SetOutPath "$INSTDIR"
  WriteRegStr HKCU "Software\TCS-Player-Community" "InstallDir" "$INSTDIR"

  CreateShortcut "$SMPROGRAMS\${PRODUCT_SHORT}.lnk" "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0
  CreateShortcut "$DESKTOP\${PRODUCT_SHORT}.lnk" "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0

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
  Delete "$INSTDIR\${APP_EXE}"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR\resources"
  RMDir "$INSTDIR"

  Delete "$SMPROGRAMS\${PRODUCT_SHORT}.lnk"
  Delete "$DESKTOP\${PRODUCT_SHORT}.lnk"

  DeleteRegKey HKCU "${UNINST_KEY}"
  DeleteRegKey HKCU "Software\TCS-Player-Community"
SectionEnd
