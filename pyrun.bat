@echo off && setlocal enabledelayedexpansion

rem Python runner
rem   (can be used for any project)

cls
echo Running "%~f0" :

set "quiet=1>nul 2>nul"
set "fquiet=/f /q 1>nul 2>nul"

rem === Setup PYTHON local path (maybe duplicates)
rem https://docs.python.org/3/using/cmdline.html#environment-variables
set "PYTHONROOT=%cd%\Python"
set "PYTHONPATH=%PYTHONROOT%;%PYTHONROOT%\DLLs;%PYTHONROOT%\Lib"

set "PATH=%PATH%;%PYTHONROOT%;%PYTHONROOT%\Scripts"
set "PATH=%PATH:;;=;%"
set "PATH=%PATH: ;=;%"
set "PATH=%PATH:; =;%"
rem echo %PATH%

rem Local constants
set "PIP_PATH="
set "PIP_OPTS=--no-cache-dir"
set "GET_PIP=get-pip.py"
set "BOOTSTRAP_URL=https://bootstrap.pypa.io/%GET_PIP%"

rem Installation : 'install' (default if 'get-pip.py' not present)
rem   (could be quite long depending on the packages to install)
if "%1" == "inst" set "todo=inst"
if "%1" == "install" set "todo=inst"
if not exist "%GET_PIP%" set "todo=inst"
if "%todo%" == "inst" (
	call :py_install
	echo.
)

rem Execution : 'run' or nothing (default)
if "%1" == "" set "todo=run"
if "%1" == "run" set "todo=run"
if "%todo%" == "run" (
	if not "%2" == "" (
		rem Run specified client (in '%PYTHONROOT%\Scripts')
		"%2"
	) else (
		rem Run default client (same name as batch file)
		"%PYTHONROOT%\python" "%~n0.py"
		echo.
	)
)

rem Command line : 'cmd'
rem   (useful to launch commands by hand with a configured Python setup)
if "%1" == "cmd" set "todo=cmd"
if "%todo%" == "cmd" (
	start "" /d "%cd%" "cmd" ""
)

goto :eof

rem - - - Subroutines - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

:py_install
	rem === Remove fake links for Windows Store
	del "%LOCALAPPDATA%\Microsoft\WindowsApps\Python*.exe" %quiet%

	rem === Installing Python from command line
	rem https://docs.python.org/3/using/windows.html#installing-without-ui

	rem === Install and update PIP (https://pypi.org/project/pip/)
	if not exist "%GET_PIP%" (
		curl "%BOOTSTRAP_URL%" >"%GET_PIP%" && (
			"%PYTHONROOT%\python" "%GET_PIP%"
		) || (
			echo Cannot get "%BOOTSTRAP_URL%"...
		)
	)

	call :pip_install pip
	REM pip cache dir
	REM pip cache purge

	if "0"=="" (
	rem === VENV and stuff (doesn't quite work as expected though)
	REM call :pip_install virtualenv
	REM call :pip_install virtualenvwrapper-win
	REM cd %USERPROFILE%\Envs
	REM cd %WORKON_HOME%
	)

	rem === Gui related (enaml, declarative and functional oriented)
	REM call :pip_install rtree
	REM call :pip_install intervaltree
	REM call :pip_install traits
	REM call :pip_install vtk
	REM call :pip_install qtpy
	REM call :pip_install enaml

	rem === Gui related (enamlx, maybe outdated a bit)
	REM call :pip_install pyqtgraph
	REM call :pip_install enamlx

	rem === Gui related (enaml-web, maybe not mature)
	REM call :pip_install enaml-web
goto :eof

:pip_install
	echo.
	echo Installing "%~1"...
	echo.
	"%PYTHONROOT%\python" -m pip install %PIP_PATH% %PIP_OPTS% --upgrade %~1
goto :eof
