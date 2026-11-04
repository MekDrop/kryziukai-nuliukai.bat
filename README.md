[![License](https://img.shields.io/github/license/MekDrop/Kryziukai-Nuliukai.bat.svg?maxAge=2592000)](License.txt) ![GitHub release](https://img.shields.io/github/release/MekDrop/Kryziukai-Nuliukai.bat.svg?maxAge=2592000)

Kryziukai-Nuliukai.bat
======================

[Crosses and zeros (aka Tic-Tac-Toe, Noughts and crosses, Xs and Os)](https://en.wikipedia.org/wiki/Tic-tac-toe) game written in [Windows Batch](http://en.wikipedia.org/wiki/Batch_file) language and can be played in different languages.

![Kryziukai-Nuliukai.bat English version with ANSI colors](screenshot.png)

Difficulty
==========

Choose a difficulty when starting the game, or pass `/D easy`, `/D normal`, or `/D hard` (for example, `kryz.bat /L lt /D hard /MONO`). The selection stays active when playing again.

- **Easy** picks a random free square.
- **Normal** takes an immediate win, blocks an immediate loss, then picks a random free square.
- **Hard** plays optimally: you can draw, but cannot win.

Hard uses readable batch rules: win, block, then choose a square that prevents the player from building a fork (two separate winning threats). It prefers the center, corners, then sides when several moves are safe. All AI logic lives in `kryz.bat`; the existing `Language` files supply translations.

Terminal appearance
===================

Windows 2000 is detected automatically and uses a plain ASCII board, English text, and the existing console code page. This path needs neither PowerShell nor ANSI support. `/ASCII` selects the same display on another Windows version. Language files are resolved relative to the batch file.

Other Windows versions use the UTF-8 board. Colors are automatic in Windows Terminal, ANSICON, and ConEmu. In the standard Windows 10/11 console, an optional PowerShell call enables ANSI processing for the current console. If PowerShell is unavailable or the console rejects ANSI processing, the game falls back to plain text. Windows 2000 and other pre-Windows-10 systems never invoke PowerShell. `/COLOR` requests color detection; `/MONO` disables colors. `NO_COLOR` disables automatic coloring; `/COLOR` opts back in. ASCII mode always uses plain text.

Windows 2000 compatibility still needs execution testing on an actual Windows 2000 installation.

X is cyan, O is magenta, the board is muted gray, and errors are red.

The screenshot shows actual game output rendered with xterm.js using a Windows console color palette.

Winning marks turn bright green on the final board when ANSI colors are enabled. Monochrome mode surrounds each winning glyph with full-height brackets. ASCII mode uses `[X]` or `[O]`.
