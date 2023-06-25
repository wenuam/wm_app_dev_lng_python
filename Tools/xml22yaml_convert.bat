@echo off && setlocal EnableDelayedExpansion
if "%~dp0" neq "!guid!\" (set "guid=%tmp%\crlf.%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "!guid!\%~nx0" (mkdir "!guid!" 2>nul & find "" /v<"%~f0" >"!guid!\%~nx0")) & call "!guid!\%~nx0" %* & rmdir /s /q "!guid!" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Convert files using Yaplon, by wenuam 2023
rem https://github.com/twardoch/yaplon
rem https://pypi.org/project/yaplon/
rem https://twardoch.github.io/yaplon/

rem Set code page to utf-8 (/!\ this file MUST be in utf-8, BOM or not)
for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
chcp 65001>nul

set "PYTHONIOENCODING=utf8"

rem Set look-up parameters
set "cext="
set "cout="
set "clib=xml22yaml"

rem "^\xEF\xBB\xBF"
set "cutf=|((pause&pause&pause)>nul&findstr "^^")"

rem Set look-up parameters
set "carg=/B /A:-D /ON /S"
set "clst=.%~n0.lst.txt"

rem Change default helpers
set "quiet=1>nul 2>nul"
set "fquiet=/f /q 1>nul 2>nul"

rem echo Check parameter...
if not "%1"=="" (
	if exist "%~f1\*" (
REM		echo IS DIR
		set /a "vchk=2"
	) else if exist "%~f1" if "%~x1"=="%cext%" (
REM		echo IS FILE
		set /a "vchk=1"
	) else (
REM		echo NO THING
		set /a "vchk=0"
	)
) else (
	echo NO PARAM
)

if !vchk! gtr 0 (
REM	echo Check dependencies...
REM	call :check_prog "dot"
REM	call :check_prog "python"
REM	call :check_prog "todo"

REM	Get Yaplon 'xxx' to 'yyy' command from batch file name ('xxx22yyy_convert')
REM	xxx/yyy = csv/json/plist/xml/yaml
	for /f "delims=2_ tokens=1,2*" %%i in ("%~n0") do (
REM		echo "i=%%i" "j=%%j" "k=%%k" "l=%%l" "m=%%m"
		if "%%k"=="convert" (
			set "cext=%%i"
			set "cout=%%j"
			set "clib=%%i22%%j"
		)
	)

	if not "!cext!"=="" if not "!cout!"=="" (
REM		echo List input...
		del "%clst%" %fquiet%
		if !vchk! equ 1 (
			echo   ...file
			echo "%~f1">>"%clst%"
		) else if !vchk! equ 2 (
			echo   ...folder
			dir %carg% "%~f1\*.!cext!">>"%clst%"
		)

REM		echo Merge lines...
		call :sortmerge "%clst%"

REM		echo Run Yaplon...
		if exist "%clst%" (
			for /f "delims=" %%i in (%clst%) do (
REM				echo   Analysing %%~nxi...

				rem Set and clean-up destination folder
				set "vdir=%%~dpi"
REM				set "vdir=%%~dpi\%~n0\%%~ni"
				set "vdir=!vdir:\\=\!"
				for /l %%l in (1,1,2) do if "!vdir:~-1!"=="\" set "vdir=!vdir:~0,-1!"

REM				echo vdir=!vdir!

				rem Create destination folder
				if not exist "!vdir!\*" (
					mkdir "!vdir!" 2>nul
				)

				rem Set destination file
				set "vout=!vdir!\%%~ni.!cout!"
				set /a "vchk=0"

REM				echo vout=!vout!

				rem Check destination file presence and date
				if exist "!vout!" (
					xcopy /D /L /Y "%%~fi" "!vout!" | findstr /BC:"1 ">nul && set /a "vchk=2"
				) else (
					set /a "vchk=1"
				)

REM				echo vchk=!vchk!

				rem Only if destination file absent or older
				if !vchk! gtr 0 (
					set "vdisp=%%~fi"
					set "vdisp=!vdisp:%cd%=.!"
					echo Processing "!vdisp!"

REM					pushd "!vdir!"

					echo   ...!clib!
					if not "1"=="" (
						!clib! -i "%%~fi" -o "!vout!"
					) else (
						rem Remove BOM
						(type "%%~fi" %cutf%) >"!guid!\%%~nxi"
REM						type "%%~fi">"!guid!\%%~nxi"
						!clib! -i "!guid!\%%~nxi" -o "!vout!"
						del "!guid!\%%~nxi" %fquiet%
					)

REM					popd
				)
			)
		)
	) else (
		echo No Yaplon command found...
	)

REM	echo Delete list...
	del "%clst%" %fquiet%
)

rem Restore code page
chcp %cp%>nul

goto :eof

rem Check a program is present (current dir or PATH)
:check_prog
	if not "%~1"=="" (
		where /q "%~1" || echo ERROR: "%~1" not found...
	)
goto :eof

rem Sort and merge lines
:sortmerge
	if not "%~1"=="" if exist "%~1" (
		sort "%~1">"%~1.sorted"
		if exist "%~1.sorted" (
			del "%~1" %fquiet%
			for /f "delims=" %%a in (%~1.sorted) do (
REM				echo   a=%%a
				if not "!vdup!"=="%%a" (
					set "vdup=%%a"
					echo:%%a>>"%~1"
				)
			)
			del "%~1.sorted" %fquiet%
		)
	)
goto :eof
