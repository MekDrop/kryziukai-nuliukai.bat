[![License](https://img.shields.io/github/license/MekDrop/Kryziukai-Nuliukai.bat.svg?maxAge=2592000)](License.txt) ![GitHub release](https://img.shields.io/github/release/MekDrop/Kryziukai-Nuliukai.bat.svg?maxAge=2592000)

Kryziukai-Nuliukai.bat
======================

[Crosses and zeros (aka Tic-Tac-Toe, Noughts and crosses, Xs and Os)](https://en.wikipedia.org/wiki/Tic-tac-toe) game written in [Windows Batch](http://en.wikipedia.org/wiki/Batch_file) language and can be played in different languages.

![Kryziukai-Nuliukai.bat English version with ANSI colors](screenshot.png)

Terminal appearance
===================

Windows 2000 is detected automatically and uses a plain ASCII board, English text, and the existing console code page. This path needs neither PowerShell nor ANSI support. `/ASCII` selects the same display on another Windows version. Language files are resolved relative to the batch file.

Other Windows versions use the UTF-8 board. Colors are automatic in Windows Terminal, ANSICON, and ConEmu. `/COLOR` opts into another ANSI-capable console whose ANSI processing is already enabled; `/MONO` disables colors. `NO_COLOR` disables automatic coloring; `/COLOR` opts back in. ASCII mode always uses plain text.

Windows 2000 compatibility still needs execution testing on an actual Windows 2000 installation.

X is cyan, O is magenta, the board is muted gray, and errors are red.

The screenshot shows actual game output rendered with xterm.js using a Windows console color palette.
