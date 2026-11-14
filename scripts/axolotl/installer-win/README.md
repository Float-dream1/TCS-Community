# Windows installer

`tcs-installer.nsi` builds the user-facing installer for TaCraft Player
Community. It is a plain NSIS wizard — welcome, target folder, progress, finish —
with no custom drawing, the same shape as the 7-Zip installer. Simplified
Chinese is the first language in the table, so that is what you get by default.

The install is per-user (`%LOCALAPPDATA%\TCS-Player-Community`), needs no
elevation, creates desktop and start menu shortcuts, registers an uninstall
entry, and leaves `%APPDATA%\TCS-Community` (game data) alone when uninstalling.

## Build

Needs NSIS 3.10 (the Unicode build). On Linux the Windows build of `makensis`
runs under wine:

```sh
mkdir -p stage
cp path/to/TaCraft-Player-Community.exe stage/
cp -r path/to/resources stage/
wine /path/to/nsis-3.10/makensis.exe /INPUTCHARSET UTF8 tcs-installer.nsi
```

`assets/welcome.bmp` is the 164x314 panel on the welcome and finish pages. It is
generated from `packages/assets/branding/tacraft-512.png` (rounded app icon over
the launcher's orange wave); NSIS only accepts 24-bit BMP.
