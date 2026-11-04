@echo off
title Kryziukai-Nuliukai.bat - Tic-Tac-Toe

REM ---------------------------------------- LICENSE -------------------------------------------------------
REM
REM    Copyright (c) 2006-2012+, MekDrop <github@mekdrop.name>
REM
REM    Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission
REM    notice appear in all copies.
REM
REM    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
REM    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
REM    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
REM     OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
REM
REM ---------------------------------------- NOTE -------------------------------------------------------
REM
REM    This app is can run only on Windows 2000 or newer

rem Setting default data
setlocal EnableExtensions DisableDelayedExpansion
set app_name=%0
set "script_dir=%~dp0"
set language=en
set "difficulty="
set "difficulty_saved="
set "difficulty_file="
if defined APPDATA set "difficulty_file=%APPDATA%\kryziukai-nuliukai.bat\difficulty.txt"
set "kalbos_failas=%script_dir%Language\%language%.csv"
rem Detect Windows 2000 before changing the console code page.
set "legacy_console="
ver | findstr /R "5\.0" >NUL
if not errorlevel 1 set "legacy_console=1"
if not defined legacy_console chcp 65001 >NUL
rem Try colors automatically; unsupported consoles fall back to plain text.
set "use_color=1"
if defined WT_SESSION set "use_color=1"
if defined ANSICON set "use_color=1"
if /I "%ConEmuANSI%"=="ON" set "use_color=1"
if defined NO_COLOR set "use_color="
set "c_reset="
set "c_board="
set "c_x="
set "c_o="
set "c_error="
set "c_result="
set "c_win="

rem Parsing command line options
:skaityti_komandines_eilutes_parametra
SET parsed_param=%1
shift
if "%parsed_param%"=="" goto setup_colors
if /I "%parsed_param%"=="/COLOR" set "use_color=1"
if /I "%parsed_param%"=="/MONO" set "use_color="
if /I "%parsed_param%"=="/ASCII" set "legacy_console=1"
if "%parsed_param%"=="/?" goto parodyti_pagalba
if "%parsed_param%"=="/L" goto nustatyti_kalba
if /I "%parsed_param%"=="/D" goto set_difficulty
goto skaityti_komandines_eilutes_parametra

:set_difficulty
set "difficulty=%~1"
shift
if /I "%difficulty%"=="easy" goto skaityti_komandines_eilutes_parametra
if /I "%difficulty%"=="normal" goto skaityti_komandines_eilutes_parametra
if /I "%difficulty%"=="hard" goto skaityti_komandines_eilutes_parametra
call :ikelti_kalba
echo %vertimas[difficulty.invalid]%
set "difficulty="
goto skaityti_komandines_eilutes_parametra

:setup_colors
if not defined use_color goto pradzia
rem ANSICON supplies ANSI support even in the legacy ASCII console.
if defined ANSICON goto ansi_colors
if defined legacy_console goto pradzia
rem ANSI-aware terminals do not need console mode changes.
if defined WT_SESSION goto ansi_colors
if defined ANSICON goto ansi_colors
if /I "%ConEmuANSI%"=="ON" goto ansi_colors
rem Native VT processing is available on newer Windows 10 builds and Windows 11.
rem Never invoke PowerShell on Windows 2000 or other pre-Windows-10 systems.
ver | findstr /R "10\.0\." >NUL
if errorlevel 1 goto pradzia
if not exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" goto pradzia
rem Enable VT on the existing console; SetConsoleMode failure selects plain text.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -EncodedCommand QQBkAGQALQBUAHkAcABlACAALQBOAGEAbQBlAHMAcABhAGMAZQAgAEsAcgB5AHoAIAAtAE4AYQBtAGUAIABDAG8AbgBzAG8AbABlACAALQBNAGUAbQBiAGUAcgBEAGUAZgBpAG4AaQB0AGkAbwBuACAAQAAnAAoAWwBTAHkAcwB0AGUAbQAuAFIAdQBuAHQAaQBtAGUALgBJAG4AdABlAHIAbwBwAFMAZQByAHYAaQBjAGUAcwAuAEQAbABsAEkAbQBwAG8AcgB0ACgAIgBrAGUAcgBuAGUAbAAzADIALgBkAGwAbAAiACkAXQAgAHAAdQBiAGwAaQBjACAAcwB0AGEAdABpAGMAIABlAHgAdABlAHIAbgAgAFMAeQBzAHQAZQBtAC4ASQBuAHQAUAB0AHIAIABHAGUAdABTAHQAZABIAGEAbgBkAGwAZQAoAGkAbgB0ACAAbgApADsACgBbAFMAeQBzAHQAZQBtAC4AUgB1AG4AdABpAG0AZQAuAEkAbgB0AGUAcgBvAHAAUwBlAHIAdgBpAGMAZQBzAC4ARABsAGwASQBtAHAAbwByAHQAKAAiAGsAZQByAG4AZQBsADMAMgAuAGQAbABsACIAKQBdACAAcAB1AGIAbABpAGMAIABzAHQAYQB0AGkAYwAgAGUAeAB0AGUAcgBuACAAYgBvAG8AbAAgAEcAZQB0AEMAbwBuAHMAbwBsAGUATQBvAGQAZQAoAFMAeQBzAHQAZQBtAC4ASQBuAHQAUAB0AHIAIABoACwAIABvAHUAdAAgAHUAaQBuAHQAIABtAG8AZABlACkAOwAKAFsAUwB5AHMAdABlAG0ALgBSAHUAbgB0AGkAbQBlAC4ASQBuAHQAZQByAG8AcABTAGUAcgB2AGkAYwBlAHMALgBEAGwAbABJAG0AcABvAHIAdAAoACIAawBlAHIAbgBlAGwAMwAyAC4AZABsAGwAIgApAF0AIABwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABiAG8AbwBsACAAUwBlAHQAQwBvAG4AcwBvAGwAZQBNAG8AZABlACgAUwB5AHMAdABlAG0ALgBJAG4AdABQAHQAcgAgAGgALAAgAHUAaQBuAHQAIABtAG8AZABlACkAOwAKACcAQAAKACQAaABhAG4AZABsAGUAIAA9ACAAWwBLAHIAeQB6AC4AQwBvAG4AcwBvAGwAZQBdADoAOgBHAGUAdABTAHQAZABIAGEAbgBkAGwAZQAoAC0AMQAxACkACgBbAHUAaQBuAHQAMwAyAF0AJABtAG8AZABlACAAPQAgADAACgBpAGYAIAAoACEAWwBLAHIAeQB6AC4AQwBvAG4AcwBvAGwAZQBdADoAOgBHAGUAdABDAG8AbgBzAG8AbABlAE0AbwBkAGUAKAAkAGgAYQBuAGQAbABlACwAIABbAHIAZQBmAF0AJABtAG8AZABlACkAKQAgAHsAIABlAHgAaQB0ACAAMQAgAH0ACgBpAGYAIAAoACEAWwBLAHIAeQB6AC4AQwBvAG4AcwBvAGwAZQBdADoAOgBTAGUAdABDAG8AbgBzAG8AbABlAE0AbwBkAGUAKAAkAGgAYQBuAGQAbABlACwAIAAoACQAbQBvAGQAZQAgAC0AYgBvAHIAIAA0ACkAKQApACAAewAgAGUAeABpAHQAIAAxACAAfQA= 2>NUL
if errorlevel 1 goto pradzia

:ansi_colors
for /F "delims=" %%e in ('echo prompt $E^| cmd /d /q') do set "esc=%%e"
set "c_reset=%esc%[0m"
set "c_board=%esc%[90m"
set "c_x=%esc%[96m"
set "c_o=%esc%[95m"
set "c_error=%esc%[91m"
set "c_result=%esc%[96m"
set "c_win=%esc%[92m"
goto pradzia
:ikelti_kalba
rem Prefer an optional ASCII translation on legacy consoles; otherwise use English.
if defined legacy_console set "kalbos_failas=%script_dir%Language\en.csv"
if defined legacy_console if exist "%script_dir%Language\%language%.txt" set "kalbos_failas=%script_dir%Language\%language%.txt"
for /f "usebackq tokens=1,* delims=, eol=;" %%a in ("%kalbos_failas%") do (
    set vertimas[%%a]=%%b
)
exit /b

:nustatyti_kalba
set language=%1
shift
set "kalbos_failas=%script_dir%Language\%language%.csv"
if not exist "%kalbos_failas%" (
    set language=en
    echo "Warning: language not found. Switching to en."
    set "kalbos_failas=%script_dir%Language\en.csv"
)
goto skaityti_komandines_eilutes_parametra

:parodyti_pagalba
call :ikelti_kalba
echo.
echo %vertimas[parodyti_pagalba.sintakse]%
echo.   %app_name% [/?] [/L %vertimas[parodyti_pagalba.kodas]%] [/COLOR] [/MONO] [/ASCII] [/D easy^|normal^|hard]
echo.
echo %vertimas[parodyti_pagalba.parametrai]%
echo.   /D       %vertimas[difficulty.help]%
echo.   /?       %vertimas[parodyti_pagalba.parametras.pagalba]%
echo.   /L %vertimas[parodyti_pagalba.kodas]%  %vertimas[parodyti_pagalba.parametras.kalba]%
echo.
goto pabaiga

:pradzia
rem Here we setting default values for all of our variables
call :ikelti_kalba
if not defined difficulty call :choose_difficulty
if not defined difficulty_saved call :remember_difficulty
set tuscias_langelis=.
set zaidejas1=X
set zaidejas2=O
set e1=%tuscias_langelis%
set e2=%tuscias_langelis%
set e3=%tuscias_langelis%
set e4=%tuscias_langelis%
set e5=%tuscias_langelis%
set e6=%tuscias_langelis%
set e7=%tuscias_langelis%
set e8=%tuscias_langelis%
set e9=%tuscias_langelis%
set klaida=
set e_spc=
set emsg=
for /L %%n in (1,1,9) do set "winner%%n="
goto braizom

:braizom
rem This part is used for drawing the board
rem We need to specify value for griztam variable, before using this part (is use label names)
if defined legacy_console goto ascii_board
for %%n in (1 2 3 4 5 6 7 8 9) do call :cell_text %%n
cls
echo.
echo     %c_x%▀█▀ ▀█▀ █▀▀%c_result%   ▀█▀ ▄▀█ █▀▀%c_o%   ▀█▀ █▀█ █▀▀%c_reset%
echo     %c_x% █   █  █%c_result%      █  █▀█ █%c_o%      █  █ █ █▀▀%c_reset%
echo     %c_x% ▀  ▀▀▀ ▀▀▀%c_result%    ▀  ▀ ▀ ▀▀▀%c_o%    ▀  ▀▀▀ ▀▀▀%c_reset%
echo     %c_board%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%c_reset%
echo.
call echo     %vertimas[difficulty.label]%: %%vertimas[difficulty.%difficulty%]%%
echo.
echo     %c_board%┏━━━━━━━┯━━━━━━━┯━━━━━━━┓%c_reset%
echo     %c_board%┃%t1%│%t2%│%t3%┃%c_reset%    %c_x%╳  %vertimas[ui.player]%%c_reset%
echo     %c_board%┃%d1%│%d2%│%d3%┃%c_reset%
echo     %c_board%┃%b1%│%b2%│%b3%┃%c_reset%    %c_o%○  %vertimas[ui.computer]%%c_reset%
echo     %c_board%┠───────┼───────┼───────┨%c_reset%
echo     %c_board%┃%t4%│%t5%│%t6%┃%c_reset%    %c_board%──────────────%c_reset%
echo     %c_board%┃%d4%│%d5%│%d6%┃%c_reset%
echo     %c_board%┃%b4%│%b5%│%b6%┃%c_reset%    %c_result%1 - 9%c_reset%
echo     %c_board%┠───────┼───────┼───────┨%c_reset%    %vertimas[ui.choose]%
echo     %c_board%┃%t7%│%t8%│%t9%┃%c_reset%
echo     %c_board%┃%d7%│%d8%│%d9%┃%c_reset%    %c_result%ENTER%c_reset%
echo     %c_board%┃%b7%│%b8%│%b9%┃%c_reset%    %vertimas[ui.confirm]%
echo     %c_board%┗━━━━━━━┷━━━━━━━┷━━━━━━━┛%c_reset%
echo.
echo     %c_board%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%c_reset%
goto board_messages

:ascii_board
for /L %%n in (1,1,9) do call :ascii_cell %%n
cls
echo.
echo     %c_x%TIC%c_result% TAC %c_o%TOE%c_reset%
call echo     %vertimas[difficulty.label]%: %%vertimas[difficulty.%difficulty%]%%
echo     %c_x%X = %vertimas[ui.player]%%c_reset%    %c_o%O = %vertimas[ui.computer]%%c_reset%
echo.
echo     %c_board%+-------+-------+-------+%c_reset%
echo     %c_board%^|  %a1%  ^|  %a2%  ^|  %a3%  ^|%c_reset%
echo     %c_board%^|   1   ^|   2   ^|   3   ^|%c_reset%
echo     %c_board%+-------+-------+-------+%c_reset%
echo     %c_board%^|  %a4%  ^|  %a5%  ^|  %a6%  ^|%c_reset%
echo     %c_board%^|   4   ^|   5   ^|   6   ^|%c_reset%
echo     %c_board%+-------+-------+-------+%c_reset%
echo     %c_board%^|  %a7%  ^|  %a8%  ^|  %a9%  ^|%c_reset%
echo     %c_board%^|   7   ^|   8   ^|   9   ^|%c_reset%
echo     %c_board%+-------+-------+-------+%c_reset%
echo.
echo     1 - 9: %vertimas[ui.choose]%
echo     ENTER: %vertimas[ui.confirm]%
echo.
:board_messages
rem If there was an error, we show this here
if NOT "%e_spc%"=="" (
   echo            %c_result%%emsg%%c_reset%
   echo.
   goto %e_spc%
)
if NOT "%klaida%"=="" (
   echo            %c_error%[!] %vertimas[braizom.klaida]% %klaida%%c_reset%
   echo.
)
rem Here it's possible enter where to place mark
set zenklas=%zaidejas1%
echo     %c_x%X  %vertimas[ui.turn]%%c_reset%
echo.
setlocal EnableDelayedExpansion
set "move_hint=!vertimas[ui.exit]!"
echo     !move_hint:exit=%c_result%exit%c_reset%!
endlocal
set "ejimas="
set /P "ejimas=%c_x%    > %c_reset%"
rem Delayed expansion keeps typed shell characters out of command parsing.
setlocal EnableDelayedExpansion
if /I "!ejimas!"=="exit" (
    endlocal
    goto pabaiga
)
for /L %%n in (1,1,9) do if "!ejimas!"=="%%n" (
    endlocal
    goto tikrink
)
endlocal
set "klaida=%vertimas[tikrink.bloga_koordinate]%"
goto braizom

:tikrink
set klaida=
if "%ejimas%"=="1" (
    if "%e1%"=="%tuscias_langelis%" (
	    set e1=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
if "%ejimas%"=="2" (
    if "%e2%"=="%tuscias_langelis%" (
	    set e2=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
if "%ejimas%"=="3" (
    if "%e3%"=="%tuscias_langelis%" (
	    set e3=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
if "%ejimas%"=="4" (
    if "%e4%"=="%tuscias_langelis%" (
	    set e4=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
if "%ejimas%"=="5" (
    if "%e5%"=="%tuscias_langelis%" (
	    set e5=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
if "%ejimas%"=="6" (
    if "%e6%"=="%tuscias_langelis%" (
	    set e6=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
if "%ejimas%"=="7" (
    if "%e7%"=="%tuscias_langelis%" (
	    set e7=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
if "%ejimas%"=="8" (
    if "%e8%"=="%tuscias_langelis%" (
	    set e8=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
if "%ejimas%"=="9" (
    if "%e9%"=="%tuscias_langelis%" (
	    set e9=%zenklas%
    ) else (
	    set klaida=%vertimas[tikrink.jau_egzistuoja]%
    )
)
rem if entered number is lower than 1, also that was an error!
if /I %ejimas% LSS 1 (
    set klaida=%vertimas[tikrink.bloga_koordinate]%
)
rem if entered number is greater than 9, also that was an error!
if /I %ejimas% GTR 9 (
    set klaida=%vertimas[tikrink.bloga_koordinate]%
)
rem checking if there was a previous error
rem if that was the computer turn, we hide all errors
if NOT "%klaida%"=="" (
    if "%zenklas%"=="%zaidejas1%" (
	    goto braizom
    ) else (
	    goto kompiuteris
    )
)

rem here we are checking if somebody wins
if "%e1%%e2%%e3%" == "%zenklas%%zenklas%%zenklas%" goto laimejimas
if "%e4%%e5%%e6%" == "%zenklas%%zenklas%%zenklas%" goto laimejimas
if "%e7%%e8%%e9%" == "%zenklas%%zenklas%%zenklas%" goto laimejimas

if "%e1%%e4%%e7%" == "%zenklas%%zenklas%%zenklas%" goto laimejimas
if "%e2%%e5%%e8%" == "%zenklas%%zenklas%%zenklas%" goto laimejimas
if "%e3%%e6%%e9%" == "%zenklas%%zenklas%%zenklas%" goto laimejimas

if "%e1%%e5%%e9%" == "%zenklas%%zenklas%%zenklas%" goto laimejimas
if "%e3%%e5%%e7%" == "%zenklas%%zenklas%%zenklas%" goto laimejimas

if NOT "%e1%"=="%tuscias_langelis%" (
   if NOT "%e2%"=="%tuscias_langelis%" (
        if NOT "%e3%"=="%tuscias_langelis%" (
            if NOT "%e4%"=="%tuscias_langelis%" (
                if NOT "%e5%"=="%tuscias_langelis%" (
                    if NOT "%e6%"=="%tuscias_langelis%" (
	                    if NOT "%e7%"=="%tuscias_langelis%" (
                            if NOT "%e8%"=="%tuscias_langelis%" (
	                            if NOT "%e9%"=="%tuscias_langelis%" (
		                            goto lygiosios
                                )
           	                )
         	            )
    	            )
  	            )
	        )
        )
   )
)

rem if you are in this place, it means you have places a mark sucessfully!
rem now we thinking what to doo next
if "%zenklas%"=="%zaidejas1%" goto kompiuteris
set griztam=ivedimas
goto braizom

:kompiuteris
rem here is a computer turn
set zenklas=%zaidejas2%
set "ejimas="
if /I "%difficulty%"=="easy" goto random_move
if /I "%difficulty%"=="hard" (
    call :hard_move
    goto tikrink
)
call :winning_move O
if defined ejimas goto tikrink
call :winning_move X
if defined ejimas goto tikrink
:random_move
setlocal EnableDelayedExpansion
set /a count=0
for /L %%n in (1,1,9) do if "!e%%n!"=="." (
    set /a count+=1
    set "free!count!=%%n"
)
set /a pick=%RANDOM% %% count + 1
for %%n in (!pick!) do for %%m in (!free%%n!) do endlocal & set "ejimas=%%m"
goto tikrink

:winning_move
setlocal EnableDelayedExpansion
set "move="
set /a threat_count=0
for /L %%n in (1,1,9) do set "threat%%n="
for %%l in (123 456 789 147 258 369 159 357) do (
    set "line=%%l"
    set /a marks=0
    set "empty="
    for /L %%i in (0,1,2) do for %%n in ("!line:~%%i,1!") do (
        if "!e%%~n!"=="%1" set /a marks+=1
        if "!e%%~n!"=="." set "empty=%%~n"
    )
    if !marks!==2 if defined empty (
        set "move=!empty!"
        if not defined threat!empty! set /a threat_count+=1
        set "threat!empty!=1"
    )
)
endlocal & set "ejimas=%move%" & set "threat_count=%threat_count%"
exit /b

:hard_move
call :winning_move O
if defined ejimas exit /b
call :winning_move X
if defined ejimas exit /b
for %%n in (5 1 3 7 9 2 4 6 8) do (
    call :safe_move %%n
    if defined safe (
        set "ejimas=%%n"
        exit /b
    )
)
exit /b

:safe_move
setlocal EnableDelayedExpansion
set "safe="
if not "!e%1!"=="." goto unsafe_move
set "e%1=O"
for /L %%n in (1,1,9) do if "!e%%n!"=="." (
    set "e%%n=X"
    call :winning_move O
    if not defined ejimas (
        call :winning_move X
        if !threat_count! GEQ 2 goto unsafe_move
    )
    set "e%%n=."
)
endlocal & set "safe=1"
exit /b
:unsafe_move
endlocal & set "safe="
exit /b

:choose_difficulty
setlocal EnableDelayedExpansion
set "difficulty_default=2"
set "saved_choice="
if defined difficulty_file if exist "!difficulty_file!" (
    (set /p "saved_choice=" < "!difficulty_file!") 2>NUL
)
for %%n in (1 2 3) do if "!saved_choice!"=="%%n" set "difficulty_default=%%n"
:difficulty_prompt
echo.
echo !vertimas[difficulty.prompt]!
echo   1. !vertimas[difficulty.easy]!
echo   2. !vertimas[difficulty.normal]!
echo   3. !vertimas[difficulty.hard]!
echo !vertimas[difficulty.default]! !difficulty_default!
set "difficulty_choice=!difficulty_default!"
set /p "difficulty_choice=> "
set "difficulty_selected="
if "!difficulty_choice!"=="1" set "difficulty_selected=easy"
if "!difficulty_choice!"=="2" set "difficulty_selected=normal"
if "!difficulty_choice!"=="3" set "difficulty_selected=hard"
if defined difficulty_selected goto difficulty_chosen
echo !vertimas[difficulty.invalid]!
goto difficulty_prompt
:difficulty_chosen
endlocal & set "difficulty=%difficulty_selected%"
exit /b

:remember_difficulty
set "difficulty_saved=1"
if not defined difficulty_file exit /b
set "saved_choice=2"
if /I "%difficulty%"=="easy" set "saved_choice=1"
if /I "%difficulty%"=="hard" set "saved_choice=3"
rem Preferences are optional: a read-only profile must not prevent playing.
if not exist "%APPDATA%\kryziukai-nuliukai.bat\" md "%APPDATA%\kryziukai-nuliukai.bat" 2>NUL
(>"%difficulty_file%" echo %saved_choice%) 2>NUL
exit /b 0

:laimejimas
for %%l in (123 456 789 147 258 369 159 357) do call :mark_winning_line %%l
if "%zenklas%"=="%zaidejas1%" (
    set emsg=%vertimas[laimejimas.zaidejas]%
) else (
    set emsg=%vertimas[laimejimas.kompiuteris]%
)

set e_spc=arzaistidar
echo.
echo.
goto braizom

:lygiosios
set emsg=%vertimas[lygiosios.lygiosios]%
set e_spc=arzaistidar
echo.
echo.
goto braizom

:arzaistidar
echo            %vertimas[arzaistidar.klausimas]%
set "ats="
set /p "ats=           > "
setlocal EnableDelayedExpansion
if not defined ats goto replay_yes
if /I "!ats!"=="!vertimas[arzaistidar.taip]!" goto replay_yes
if /I "!ats!"=="!vertimas[arzaistidar.taip]:~0,1!" goto replay_yes
if /I "!ats!"=="!vertimas[arzaistidar.ne]!" goto replay_no
if /I "!ats!"=="!vertimas[arzaistidar.ne]:~0,1!" goto replay_no
endlocal
cls
goto arzaistidar

:replay_yes
endlocal
goto pradzia

:replay_no
endlocal
goto pabaiga

:pabaiga
exit /b

:cell_text
call set "cell=%%e%1%%"
set "mark_color=%c_x%"
if "%cell%"=="O" set "mark_color=%c_o%"
if defined winner%1 set "mark_color=%c_win%"
set "t%1=   "
set "d%1=%c_result% %1 %c_board%"
set "b%1=   "
if "%cell%"=="X" (
    set "t%1=%mark_color%╲ ╱%c_board%"
    set "d%1=%mark_color% ╳ %c_board%"
    set "b%1=%mark_color%╱ ╲%c_board%"
)
if "%cell%"=="O" (
    set "t%1=%mark_color%╭─╮%c_board%"
    set "d%1=%mark_color%│ │%c_board%"
    set "b%1=%mark_color%╰─╯%c_board%"
)
rem Full-height brackets surround the glyph without changing the cell width.
if not defined c_win if defined winner%1 (
    call set "t%1= ┌%%t%1%%┐ "
    call set "d%1= │%%d%1%%│ "
    call set "b%1= └%%b%1%%┘ "
    exit /b
)
call set "t%1=  %%t%1%%  "
call set "d%1=  %%d%1%%  "
call set "b%1=  %%b%1%%  "
exit /b

:mark_winning_line
setlocal EnableDelayedExpansion
set "line=%1"
set "marks="
for /L %%i in (0,1,2) do for %%n in ("!line:~%%i,1!") do set "marks=!marks!!e%%~n!"
if not "!marks!"=="%zenklas%%zenklas%%zenklas%" (
    endlocal
    exit /b
)
endlocal
for /L %%i in (0,1,2) do call :mark_winning_cell %1 %%i
exit /b

:mark_winning_cell
set "line=%1"
call set "winner%%line:~%2,1%%=1"
exit /b

:ascii_cell
call set "cell=%%e%1%%"
set "mark_color=%c_board%"
if "%cell%"=="X" set "mark_color=%c_x%"
if "%cell%"=="O" set "mark_color=%c_o%"
if defined winner%1 if defined c_win set "mark_color=%c_win%"
set "a%1=%mark_color% %cell% %c_board%"
if defined winner%1 if not defined c_win set "a%1=[%cell%]"
exit /b
