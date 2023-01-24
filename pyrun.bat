@echo off && setlocal enabledelayedexpansion
if "%~dp0" neq "%tmp%\%guid%\" (set "guid=%~nx0.%~z0" & set "cd=%~dp0" & (if not exist "%tmp%\%~nx0.%~z0\%~nx0" (mkdir "%tmp%\%~nx0.%~z0" 2>nul & find "" /v<"%~f0" >"%tmp%\%~nx0.%~z0\%~nx0")) & call "%tmp%\%~nx0.%~z0\%~nx0" %* & rmdir /s /q "%tmp%\%~nx0.%~z0" 2>nul & exit /b) else (if "%cd:~-1%"=="\" set "cd=%cd:~0,-1%")

rem Save code page then set it to utf-8 (/!\ this file MUST be in utf-8)
for /f "tokens=2 delims=:." %%x in ('chcp') do set cp=%%x
chcp 65001>nul

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

set "PATH=%PATH%;%PYTHONROOT%"
set "PATH=%PATH%;%PYTHONROOT%\Scripts"

rem Clean PATH
set "PATH=%PATH:\\=\%"
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
	echo Installation done...
)

rem Execution : 'run' or nothing (default)
if "%1" == "" set "todo=run"
if "%1" == "run" set "todo=run"
if "%todo%" == "run" (
	if not "%2" == "" (
		rem Run specified client (in '%PYTHONROOT%\Scripts')
		echo Running specified "%2.exe"...
		"%2"
	) else (
		rem Run default client (same name as batch file)
		echo Running default "%~n0.py"...
		"%PYTHONROOT%\python" "%~n0.py"
		echo;
	)
)

rem Command line : 'cmd'
rem   (useful to launch commands by hand with a configured Python setup)
if "%1" == "cmd" set "todo=cmd"
if "%todo%" == "cmd" (
	echo Opening pre-configured "cmd" console...
	start "" /d "%cd%" "cmd" ""
)

rem Restore saved code page
chcp %cp%>nul

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
			echo Installing "%BOOTSTRAP_URL%"...
			"%PYTHONROOT%\python" "%GET_PIP%"
		) || (
			echo Cannot get "%BOOTSTRAP_URL%"...
		)
	)

	if "1"=="1" (
		call :pip_install pip
REM		pip cache dir
REM		pip cache purge
	)

	rem === VENV and stuff (doesn't quite work as expected though)
	if ""=="1" (
REM		call :pip_install virtualenv
REM		call :pip_install virtualenvwrapper-win
REM		cd %USERPROFILE%\Envs
REM		cd %WORKON_HOME%
	)

	rem === Path and folder
	if ""=="1" (
		call :pip_install pyfolder
		call :pip_install pyzip
REM		call :pip_install remotezip
	)

	rem === Editor
	if ""=="1" (
REM		call :pip_install ash-editor
		call :pip_install suplemon
REM		call :pip_install tui-editor
	)

	rem === Tui related
	if ""=="1" (
		call :pip_install Pygments
		call :pip_install pytermgui
		call :pip_install pyTermTk
		call :pip_install rich
		call :pip_install rich-cli
		call :pip_install textual
		call :pip_install tlogg
		call :pip_install ttkode
		call :pip_install urwid
	)

	rem === Debugging
	if ""=="1" (
		call :pip_install better_exceptions
REM		call :pip_install boofuzz
REM		call :pip_install ddebug
REM		call :pip_install epdb
		call :pip_install icecream
		call :pip_install objprint
		call :pip_install pdbpp
		call :pip_install pdbr
		call :pip_install pretty_errors
REM		call :pip_install prettyexc
REM		call :pip_install profiling
		call :pip_install pudb
		call :pip_install PySnooper
REM		call :pip_install scalene
		call :pip_install snoop
REM		call :pip_install snoop-tensor
		call :pip_install stackprinter
REM		call :pip_install torchsnooper
REM		call :pip_install undent
		call :pip_install viztracer
REM		call :pip_install vizplugins
REM		call :pip_install voltron
REM		call :pip_install watchpoints
REM		call :pip_install web-pdb
	)

	rem === Hot reloading
	if ""=="1" (
REM		call :pip_install hotreload
		call :pip_install jurigged
REM		call :pip_install python-hmr
		call :pip_install reloadium
	)

	rem === Binary parser
	if ""=="1" (
REM		call :pip_install auto-struct
REM		call :pip_install binmap
REM		call :pip_install bread
REM		call :pip_install construct
REM		call :pip_install construct-classes
REM		call :pip_install construct-editor
REM		call :pip_install construct-typing
		call :pip_install deconstruct
REM		call :pip_install destructify
		call :pip_install hachoir
		call :pip_install iofree
REM		call :pip_install pabo
		call :pip_install structures
	)

	rem === Gui related (enaml, declarative and functional oriented)
	if ""=="1" (
REM		call :pip_install rtree
REM		call :pip_install intervaltree
REM		call :pip_install traits
REM		call :pip_install vtk
		call :pip_install qtpy
		call :pip_install qasync
REM		call :pip_install PySide6
		call :pip_install enaml
	)

	rem === Gui related (enamlx, maybe outdated a bit)
	if ""=="1" (
		call :pip_install pyqtgraph
		call :pip_install enamlx
	)

	rem === Gui related (enaml-web, maybe not mature)
	if ""=="1" (
		call :pip_install enaml-web
	)

	rem === Wui
	if ""=="1" (
		call :pip_install pyodide
		call :pip_install shiny
	)

	rem === Cryptography
	if ""=="1" (
		call :pip_install ciphey
	)

	rem === Generative AI
	if ""=="1" (
		call :pip_install discoart
		call :pip_install docarray
		call :pip_install jina
REM		call :pip_install norfair
	)

	rem === Opcua related (aka FreeOpcUa/opcua-asyncio, some Qt5 dependencies)
	if ""=="1" (
		call :pip_install asyncua
		call :pip_install opcua
		call :pip_install opcua-webclient
		call :pip_install opcua-client
		call :pip_install opcua-modeler
		call :pip_install "git+https://github.com/PrediktorAS/opcua-tools.git"
	)
goto :eof

:pip_install
	echo;
	echo; - - - Installing "%~1" - - - - - - - - - - - - - - - - - - - - - - - -
	echo;
	"%PYTHONROOT%\python" -m pip install %PIP_PATH% %PIP_OPTS% --upgrade %~1  | findstr /V /C:"already satisfied"
	rem set -o pipefail; pip install -r requirements.txt | { grep -v "already satisfied" || :; }
goto :eof
