# Windows installer (standalone)

`tcs-installer.nsi` builds the user-facing Windows installer for
TaCraft Player Community: Modern UI 2, Simplified Chinese by default, welcome
bitmap in the launcher's orange palette, and a copy of the app plus its
`resources` folder.

It installs per user into `%LOCALAPPDATA%\TCS-Player-Community`, creates a
desktop and start menu shortcut, registers an uninstall entry, and keeps
`%APPDATA%\TCS-Community` (game data) when uninstalling.

## Build

Requires NSIS 3.10 (`makensis`). On Linux the Windows build of makensis runs
fine under wine:

```sh
# stage the release build
mkdir -p stage
cp path/to/TaCraft-Player-Community.exe stage/
cp -r path/to/resources stage/

wine /path/to/nsis-3.10/makensis.exe /INPUTCHARSET UTF8 tcs-installer.nsi
```

The stock Simplified Chinese language file asks for SimSun 9pt, which looks
dated next to the launcher. Rewrite the font line in
`Contrib/Language files/SimpChinese.nlf` (`宋体` → `Microsoft YaHei UI`) in your
NSIS copy before building.

## Bitmaps

`assets/welcome.bmp` (164x314) and `assets/header.bmp` (150x57) are generated
from `packages/assets/branding/tacraft-512.png`: rounded app icon over the
launcher's orange wave gradient. Regenerate them with any image editor if the
branding changes; NSIS only accepts 24-bit BMP.
