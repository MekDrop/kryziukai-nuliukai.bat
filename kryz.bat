@echo off

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

setlocal DisableDelayedExpansion
set app_name=%0
set language=en
set "difficulty="
set kalbos_failas=.\Language\%language%.csv
chcp 65001 >NUL
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

:skaityti_komandines_eilutes_parametra
SET parsed_param=%1
shift
if "%parsed_param%"=="" goto setup_colors
if /I "%parsed_param%"=="/COLOR" set "use_color=1"
if /I "%parsed_param%"=="/MONO" set "use_color="
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
if defined WT_SESSION goto ansi_colors
if defined ANSICON goto ansi_colors
if /I "%ConEmuANSI%"=="ON" goto ansi_colors
powershell.exe -NoLogo -NoProfile -NonInteractive -EncodedCommand QQBkAGQALQBUAHkAcABlACAALQBOAGEAbQBlAHMAcABhAGMAZQAgAEsAcgB5AHoAIAAtAE4AYQBtAGUAIABDAG8AbgBzAG8AbABlACAALQBNAGUAbQBiAGUAcgBEAGUAZgBpAG4AaQB0AGkAbwBuACAAQAAnAAoAWwBTAHkAcwB0AGUAbQAuAFIAdQBuAHQAaQBtAGUALgBJAG4AdABlAHIAbwBwAFMAZQByAHYAaQBjAGUAcwAuAEQAbABsAEkAbQBwAG8AcgB0ACgAIgBrAGUAcgBuAGUAbAAzADIALgBkAGwAbAAiACkAXQAgAHAAdQBiAGwAaQBjACAAcwB0AGEAdABpAGMAIABlAHgAdABlAHIAbgAgAFMAeQBzAHQAZQBtAC4ASQBuAHQAUAB0AHIAIABHAGUAdABTAHQAZABIAGEAbgBkAGwAZQAoAGkAbgB0ACAAbgApADsACgBbAFMAeQBzAHQAZQBtAC4AUgB1AG4AdABpAG0AZQAuAEkAbgB0AGUAcgBvAHAAUwBlAHIAdgBpAGMAZQBzAC4ARABsAGwASQBtAHAAbwByAHQAKAAiAGsAZQByAG4AZQBsADMAMgAuAGQAbABsACIAKQBdACAAcAB1AGIAbABpAGMAIABzAHQAYQB0AGkAYwAgAGUAeAB0AGUAcgBuACAAYgBvAG8AbAAgAEcAZQB0AEMAbwBuAHMAbwBsAGUATQBvAGQAZQAoAFMAeQBzAHQAZQBtAC4ASQBuAHQAUAB0AHIAIABoACwAIABvAHUAdAAgAHUAaQBuAHQAIABtAG8AZABlACkAOwAKAFsAUwB5AHMAdABlAG0ALgBSAHUAbgB0AGkAbQBlAC4ASQBuAHQAZQByAG8AcABTAGUAcgB2AGkAYwBlAHMALgBEAGwAbABJAG0AcABvAHIAdAAoACIAawBlAHIAbgBlAGwAMwAyAC4AZABsAGwAIgApAF0AIABwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIABiAG8AbwBsACAAUwBlAHQAQwBvAG4AcwBvAGwAZQBNAG8AZABlACgAUwB5AHMAdABlAG0ALgBJAG4AdABQAHQAcgAgAGgALAAgAHUAaQBuAHQAIABtAG8AZABlACkAOwAKACcAQAAKACQAaABhAG4AZABsAGUAIAA9ACAAWwBLAHIAeQB6AC4AQwBvAG4AcwBvAGwAZQBdADoAOgBHAGUAdABTAHQAZABIAGEAbgBkAGwAZQAoAC0AMQAxACkACgBbAHUAaQBuAHQAMwAyAF0AJABtAG8AZABlACAAPQAgADAACgBpAGYAIAAoACEAWwBLAHIAeQB6AC4AQwBvAG4AcwBvAGwAZQBdADoAOgBHAGUAdABDAG8AbgBzAG8AbABlAE0AbwBkAGUAKAAkAGgAYQBuAGQAbABlACwAIABbAHIAZQBmAF0AJABtAG8AZABlACkAKQAgAHsAIABlAHgAaQB0ACAAMQAgAH0ACgBpAGYAIAAoACEAWwBLAHIAeQB6AC4AQwBvAG4AcwBvAGwAZQBdADoAOgBTAGUAdABDAG8AbgBzAG8AbABlAE0AbwBkAGUAKAAkAGgAYQBuAGQAbABlACwAIAAoACQAbQBvAGQAZQAgAC0AYgBvAHIAIAA0ACkAKQApACAAewAgAGUAeABpAHQAIAAxACAAfQA= 2>NUL
if errorlevel 1 goto pradzia
:ansi_colors
for /F "delims=" %%e in ('echo prompt $E^| cmd /d /q') do set "esc=%%e"
set "c_reset=%esc%[0m"
set "c_board=%esc%[90m"
set "c_x=%esc%[96m"
set "c_o=%esc%[95m"
set "c_error=%esc%[91m"
set "c_result=%esc%[96m"
goto pradzia
:ikelti_kalba
for /f "tokens=1,* delims=, eol=;" %%a in (%kalbos_failas%) do (
    set vertimas[%%a]=%%b
)
exit /b

:nustatyti_kalba
set language=%1
shift
set kalbos_failas=.\Language\%language%.csv
if not exist %kalbos_failas% (
    set language=en
    echo "Warning: language not found. Switching to en."
    set kalbos_failas=.\Language\%language%.csv
)
goto skaityti_komandines_eilutes_parametra

:parodyti_pagalba
call :ikelti_kalba
echo.
echo %vertimas[parodyti_pagalba.sintakse]%
echo.   %app_name% [/?] [/L %vertimas[parodyti_pagalba.kodas]%] [/COLOR] [/MONO] [/D easy^|normal^|hard]
echo.
echo %vertimas[parodyti_pagalba.parametrai]%
echo.   /D       %vertimas[difficulty.help]%
echo.   /?       %vertimas[parodyti_pagalba.parametras.pagalba]%
echo.   /L %vertimas[parodyti_pagalba.kodas]%  %vertimas[parodyti_pagalba.parametras.kalba]%
echo.
goto pabaiga

:pradzia
call :ikelti_kalba
if not defined difficulty call :choose_difficulty
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
goto braizom

:braizom
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
echo     %c_board%┃  %t1%  │  %t2%  │  %t3%  ┃%c_reset%    %c_x%╳  %vertimas[ui.player]%%c_reset%
echo     %c_board%┃  %d1%  │  %d2%  │  %d3%  ┃%c_reset%
echo     %c_board%┃  %b1%  │  %b2%  │  %b3%  ┃%c_reset%    %c_o%○  %vertimas[ui.computer]%%c_reset%
echo     %c_board%┠───────┼───────┼───────┨%c_reset%
echo     %c_board%┃  %t4%  │  %t5%  │  %t6%  ┃%c_reset%    %c_board%──────────────%c_reset%
echo     %c_board%┃  %d4%  │  %d5%  │  %d6%  ┃%c_reset%
echo     %c_board%┃  %b4%  │  %b5%  │  %b6%  ┃%c_reset%    %c_result%1 - 9%c_reset%
echo     %c_board%┠───────┼───────┼───────┨%c_reset%    %vertimas[ui.choose]%
echo     %c_board%┃  %t7%  │  %t8%  │  %t9%  ┃%c_reset%
echo     %c_board%┃  %d7%  │  %d8%  │  %d9%  ┃%c_reset%    %c_result%ENTER%c_reset%
echo     %c_board%┃  %b7%  │  %b8%  │  %b9%  ┃%c_reset%    %vertimas[ui.confirm]%
echo     %c_board%┗━━━━━━━┷━━━━━━━┷━━━━━━━┛%c_reset%
echo.
echo     %c_board%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%c_reset%
if NOT "%e_spc%"=="" (
   echo            %c_result%%emsg%%c_reset%
   echo.
   goto %e_spc%
)
if NOT "%klaida%"=="" (
   echo            %c_error%[!] %vertimas[braizom.klaida]% %klaida%%c_reset%
   echo.
)
set zenklas=%zaidejas1%
echo     %c_x%●  %vertimas[ui.turn]%%c_reset%
set /P "ejimas=%c_x%    › %c_reset%"
goto tikrink

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
if /I %ejimas% LSS 1 (
    set klaida=%vertimas[tikrink.bloga_koordinate]%
)
if /I %ejimas% GTR 9 (
    set klaida=%vertimas[tikrink.bloga_koordinate]%
)
if NOT "%klaida%"=="" (
    if "%zenklas%"=="%zaidejas1%" (
	    goto braizom
    ) else (
	    goto kompiuteris
    )
)

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

if "%zenklas%"=="%zaidejas1%" goto kompiuteris
set griztam=ivedimas
goto braizom

:kompiuteris
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
echo.
echo %vertimas[difficulty.prompt]%
echo   1. %vertimas[difficulty.easy]%
echo   2. %vertimas[difficulty.normal]%
echo   3. %vertimas[difficulty.hard]%
set "difficulty_choice="
set /p "difficulty_choice=> "
if "%difficulty_choice%"=="1" set "difficulty=easy"
if "%difficulty_choice%"=="2" set "difficulty=normal"
if "%difficulty_choice%"=="3" set "difficulty=hard"
if defined difficulty exit /b
echo %vertimas[difficulty.invalid]%
goto choose_difficulty

:laimejimas
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
set /p "ats=           > "
if "%ats%" == "%vertimas[arzaistidar.taip]%" goto pradzia
if "%ats%" == "%vertimas[arzaistidar.taip]:~0,1%" goto pradzia
if "%ats%" == "%vertimas[arzaistidar.ne]%" goto pabaiga
if "%ats%" == "%vertimas[arzaistidar.ne]:~0,1%" goto pabaiga
cls
goto arzaistidar

:pabaiga
exit /b

:cell_text
call set "cell=%%e%1%%"
set "t%1=   "
set "d%1=%c_result% %1 %c_board%"
set "b%1=   "
if "%cell%"=="X" (
    set "t%1=%c_x%╲ ╱%c_board%"
    set "d%1=%c_x% ╳ %c_board%"
    set "b%1=%c_x%╱ ╲%c_board%"
)
if "%cell%"=="O" (
    set "t%1=%c_o%╭─╮%c_board%"
    set "d%1=%c_o%│ │%c_board%"
    set "b%1=%c_o%╰─╯%c_board%"
)
exit /b
