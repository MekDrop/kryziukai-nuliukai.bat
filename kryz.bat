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
REM ---------------------------------------- NOTE -------------------------------------------------------
REM
REM    This app is can run only on Windows 2000 or newer

rem Setting default data
setlocal DisableDelayedExpansion
set app_name=%0
set language=en
set kalbos_failas=.\Language\%language%.csv
chcp 65001 >NUL
rem Try colors by default; /MONO and NO_COLOR opt out.
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

rem Parsing command line options
:skaityti_komandines_eilutes_parametra
SET parsed_param=%1
shift
if "%parsed_param%"=="" goto setup_colors
if /I "%parsed_param%"=="/COLOR" set "use_color=1"
if /I "%parsed_param%"=="/MONO" set "use_color="
if "%parsed_param%"=="/?" goto parodyti_pagalba
if "%parsed_param%"=="/L" goto nustatyti_kalba
goto skaityti_komandines_eilutes_parametra

:setup_colors
if not defined use_color goto pradzia
rem Known ANSI terminals already support escape sequences.
if defined WT_SESSION goto ansi_colors
if defined ANSICON goto ansi_colors
if /I "%ConEmuANSI%"=="ON" goto ansi_colors
rem Enable ENABLE_VIRTUAL_TERMINAL_PROCESSING on the shared console output.
rem Encoded PowerShell calls GetStdHandle(-11), GetConsoleMode, SetConsoleMode(mode OR 4).
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
echo.   %app_name% [/?] [/L %vertimas[parodyti_pagalba.kodas]%] [/COLOR] [/MONO]
echo.
echo %vertimas[parodyti_pagalba.parametrai]%
echo.   /?       %vertimas[parodyti_pagalba.parametras.pagalba]%
echo.   /L %vertimas[parodyti_pagalba.kodas]%  %vertimas[parodyti_pagalba.parametras.kalba]%
echo.
goto pabaiga

:pradzia
rem Here we setting default values for all of our variables
call :ikelti_kalba
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
rem This part is used for drawing the board
rem We need to specify value for griztam variable, before using this part (is use label names)
for %%n in (1 2 3 4 5 6 7 8 9) do call :cell_text %%n
cls
echo.
echo     %c_x%▀█▀ ▀█▀ █▀▀%c_result%   ▀█▀ ▄▀█ █▀▀%c_o%   ▀█▀ █▀█ █▀▀%c_reset%
echo     %c_x% █   █  █%c_result%      █  █▀█ █%c_o%      █  █ █ █▀▀%c_reset%
echo     %c_x% ▀  ▀▀▀ ▀▀▀%c_result%    ▀  ▀ ▀ ▀▀▀%c_o%    ▀  ▀▀▀ ▀▀▀%c_reset%
echo     %c_board%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%c_reset%
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
set /A ejimas=%RANDOM%/(32752/(9-1))+1
goto tikrink

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
