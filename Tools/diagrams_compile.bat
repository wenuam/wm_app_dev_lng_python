@echo off && setlocal EnableDelayedExpansion && chcp 65001>nul
if "%~dp0" neq "!guid!\" (set "guid=%tmp%\crlf.%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "!guid!\%~nx0" (mkdir "!guid!" 2>nul & find "" /v<"%~f0" >"!guid!\%~nx0")) & call "!guid!\%~nx0" %* & rmdir /s /q "!guid!" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Compile Diagrams files, by wenuam 2023
rem https://github.com/mingrammer/diagrams

set "PYTHONIOENCODING=utf8"

rem Set look-up parameters
set "cext=.py"
set "cout=svg"
set "clib=diagrams"
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
	del "%clst%" %fquiet%
	if !vchk! equ 1 (
REM		echo   ...file
		findstr %cstr% /C:"import %clib%" "%~1">>"%clst%"
		findstr %cstr% /C:"from %clib%" "%~1" >>"%clst%"
	) else if !vchk! equ 2 (
REM		echo   ...folder
		findstr %cstr% /C:"import %clib%" "%~f1\*%cext%">>"%clst%"
		findstr %cstr% /C:"from %clib%" "%~f1\*%cext%" >>"%clst%"
	)

REM	echo Merge lines...
	call :sortmerge "%clst%"

REM	echo Run pytm...
	if exist "%clst%" (
		for /f "delims=" %%i in (%clst%) do (
REM			echo   Analysing %%~nxi...

            rem Looking for output filename (specific to Diagrams)
			for /f "tokens=1* delims=:" %%j in ('findstr /n /c:"with Diagram" "%%~fi"') do (
				rem Check output filename format
REM				echo j=%%j, k=%%k
				set "vrep=%%k"
				set "vrep=!vrep:filename=!"

				rem Check if 'filename' parameter specified
				if not "!vrep!"=="%%k" (
					rem Output filename specified, use input filename
					set "vrep=%~n1"
				) else (
					rem Use title string as filename
					for /f "tokens=1,2,3* delims=(,):" %%l in ("%%k") do (
REM						echo l=%%l, m=%%m, n=%%n, o=%%o
						set "vrep=%%m"
						set "vrep=!vrep:"=!"
						set "vrep=!vrep: =_!"
						for %%b in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "vrep=!vrep:%%b=%%b!"
					)
				)
			)

REM			echo vrep=!vrep!

			rem Set and clean-up destination folder
			set "vdir=%%~dpi"
REM			set "vdir=%%~dpi\%~n0\%%~ni"
			set "vdir=!vdir:\\=\!"
			for /l %%l in (1,1,2) do if "!vdir:~-1!"=="\" set "vdir=!vdir:~0,-1!"

REM			echo vdir=!vdir!

			rem Create destination folder
			if not exist "!vdir!\*" (
				mkdir "!vdir!" 2>nul
			)

			rem Set destination file
			set "vout=!vdir!\!vrep!.%cout%"
			set /a "vchk=0"

REM			echo vout=!vout!

			rem Check destination file presence and date
			if exist "!vout!" (
				xcopy /D /L /Y "%%~fi" "!vout!" | findstr /BC:"1 ">nul && set /a "vchk=2"
			) else (
				set /a "vchk=1"
			)

REM			echo vchk=!vchk!

			rem Only if destination file absent or older
			if !vchk! gtr 0 (
				set "vdisp=%%~fi"
				set "vdisp=!vdisp:%cd%=.!"
				echo Processing "!vdisp!"

				pushd "!vdir!"

				echo   ...Diagrams
				python "%%~fi"

				popd
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
