# Windows installer

`tcs-installer.nsi` builds the user-facing installer for TaCraft Player
Community. It has no wizard chrome: one frameless page drawn from
`assets/body.bmp` (orange banner on top, white body below) plus real controls
and bitmap buttons, then the stock progress page while the payload unpacks.

Everything is Simplified Chinese by default. The installer is per-user
(`%LOCALAPPDATA%\TCS-Player-Community`), needs no elevation, registers an
uninstall entry, and leaves `%APPDATA%\TCS-Community` (game data) alone when
uninstalling.

## Build

Needs NSIS 3.10 with the Unicode build. On Linux the Windows build of
`makensis` runs under wine:

```sh
mkdir -p stage
cp path/to/TaCraft-Player-Community.exe stage/
cp -r path/to/resources stage/
wine /path/to/nsis-3.10/makensis.exe /INPUTCHARSET UTF8 tcs-installer.nsi
```

## Artwork

* `assets/body.bmp` — the whole page: banner (96 px tall) plus the body with
  its labels and rules. 1024x560 so higher DPI pages stay covered; the page
  clips it.
* `assets/btn-*.bmp`, `assets/check-*.bmp` — buttons and checkboxes are
  bitmap statics with `SS_NOTIFY`, toggled in script, so they can look like the
  launcher instead of stock Win32 controls.

Changing the palette means regenerating these from
`packages/assets/branding/tacraft-512.png`; NSIS only accepts 24-bit BMP.
