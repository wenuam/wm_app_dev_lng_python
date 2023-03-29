@echo off && setlocal enabledelayedexpansion && chcp 65001>nul
if "%~dp0" neq "%tmp%\%guid%\" (set "guid=%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "%tmp%\%~nx0.%~z0\%~nx0" (mkdir "%tmp%\%~nx0.%~z0" 2>nul & find "" /v<"%~f0" >"%tmp%\%~nx0.%~z0\%~nx0")) & call "%tmp%\%~nx0.%~z0\%~nx0" %* & rmdir /s /q "%tmp%\%~nx0.%~z0" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Compile Blockdiag files, by wenuam 2023
rem https://github.com/blockdiag/blockdiag

set "PYTHONIOENCODING=utf8"

rem Set look-up parameters
set "cext=.diag"
set "cout=svg"
set "clib=blockdiag"
set "cstr=/S /I /M"
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
REM	echo NO PARAM
)

if !vchk! gtr 0 (
REM	echo Check dependencies...
	call :check_prog "dot"
	call :check_prog "python"
REM	call :check_prog "todo"

REM	echo List input...
	if !vchk! equ 1 (
REM		echo ...file
		findstr %cstr% /C:"%clib%" "%~1">"%clst%"
		findstr %cstr% /C:"diagram admin" "%~1" >>"%clst%"
	) else if !vchk! equ 2 (
REM		echo ...folder
		findstr %cstr% /C:"%clib%" "%~f1\*%cext%">"%clst%"
		findstr %cstr% /C:"diagram admin" "%~f1\*%cext%" >>"%clst%"
	)

REM	echo Merge lines...
	call :sortmerge "%clst%"

REM	echo Run pytm...
	if exist "%clst%" (
		for /f "delims=" %%i in (%clst%) do (
REM			echo   Analysing %%~nxi...

REM			set "vdir=%%~dpi\"
			set "vdir=%%~dpi\%~n0\%%~ni"
			set "vdir=!vdir:\\=\!"
REM			echo "%%~fi"

			if not exist "!vdir!\*" (
				mkdir "!vdir!" 2>nul
			)

			set "vout=!vdir!\%~n1.%cout%"
			set /a "vchk=0"

			if exist "!vout!" (
				xcopy /D /L /Y "%%~fi" "!vout!" | findstr /BC:"1 ">nul && set /a "vchk=2"
			) else (
				set /a "vchk=1"
			)

REM			echo vchk=!vchk!

			if !vchk! gtr 0 (
				set "vdisp=%%~fi"
				set "vdisp=!vdisp:%cd%=.!"
				echo Processing "!vdisp!"

REM				pushd "!vdir!"

				echo   ...Blockdiag
				blockdiag -T%cout% -o "!vout!" "%%~fi"

REM				popd
			)
		)
	)

REM	echo Delete list...
	del "%clst%" %fquiet%
)
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
