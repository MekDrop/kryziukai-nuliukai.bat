[![License](https://img.shields.io/github/license/MekDrop/Kryziukai-Nuliukai.bat.svg?maxAge=2592000)](License.txt) ![GitHub release](https://img.shields.io/github/release/MekDrop/Kryziukai-Nuliukai.bat.svg?maxAge=2592000) [![Website - Play online](https://img.shields.io/badge/website-play%20online-blue)](https://mekdrop.github.io/kryziukai-nuliukai.bat/)

Kryziukai-Nuliukai.bat
======================

A Tic-Tac-Toe game for Windows, available in English and Lithuanian. You play as X against the computer. Get three marks in a row, column, or diagonal to win.

Play
====

The easiest way is to **[play online](https://mekdrop.github.io/kryziukai-nuliukai.bat/)**. Wait for Windows to load inside your browser; the game opens automatically. Click inside the game, choose a difficulty, and use your keyboard to play. The flag buttons switch between English and Lithuanian. Refreshing the page starts a fresh session.

To play on your own Windows computer:

1. [Download the latest release](https://github.com/MekDrop/kryziukai-nuliukai.bat/releases/latest).
2. Extract the ZIP file using **Extract All**. Keep `kryz.bat` and the `Language` folder together.
3. Open the extracted folder and double-click `kryz.bat`.

The downloadable game requires Windows 2000 or newer and needs no installation. The browser version can be played on other operating systems too.

How to play
===========

Choose a difficulty by typing `1`, `2`, or `3`, then pressing Enter. During the game, type the number of an empty square (1–9) and press Enter to place your X.

Type `exit` at a move prompt to quit. After a game, press Enter to play again, or type `no` (English) or `ne` (Lithuanian) to stop. You can also use `yes`/`y`, `no`/`n`, `taip`/`t`, or `ne`/`n` in the selected language.

![Kryziukai-Nuliukai.bat English version with ANSI colors](screenshot.png)

Difficulty
==========

Press Enter at the difficulty prompt to accept the default: Normal the first time, then your last selected difficulty. The same difficulty stays active when playing again.

- **Easy** picks a random free square.
- **Normal** takes an immediate win, blocks an immediate loss, then picks a random free square.
- **Hard** plays optimally: you can draw, but cannot win.

Project status
==============

This project is mostly inactive, with occasional updates when I have time and interest. Small fixes may be considered, but pull requests may go unanswered. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

Advanced options
================

The game is written in Windows Batch. No programming knowledge is needed to play. If you use Command Prompt, you can choose a language, difficulty, or display mode when launching it:

```bat
kryz.bat /L lt /D hard /MONO
```

- `/L en` or `/L lt`: English or Lithuanian.
- `/D easy`, `/D normal`, or `/D hard`: skip the difficulty prompt.
- `/MONO`: disable colors.
- `/COLOR`: request colors if the terminal supports them.
- `/ASCII`: use simpler board characters.
- `/?`: show help.

Difficulty choices, including those made with `/D`, are saved in `%APPDATA%\kryziukai-nuliukai.bat\difficulty.txt`. If saving fails, the game still works.

For browser demo development and deployment instructions, see [web/README.md](web/README.md).

Display and compatibility
=========================

X is cyan and O is magenta when colors are supported. Winning marks turn green; without colors, brackets highlight them instead.

If the board looks wrong, try the simpler display by running `kryz.bat /ASCII` from Command Prompt. Windows 2000 uses this layout automatically. Colors are optional; the game can run without PowerShell or color support.

The screenshot shows the modern board layout. The Windows 2000 browser demo uses a simpler board with numbered squares. Its initial display has been checked in the emulator; full gameplay and a native Windows 2000 installation still need separate testing.
