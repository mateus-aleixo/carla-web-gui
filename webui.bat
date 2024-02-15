@echo off

if not defined PYTHON (
    set PYTHON=python
)
if defined GIT (
    set "GIT_PYTHON_GIT_EXECUTABLE=%GIT%"
)
if not defined VENV_DIR (
    set "VENV_DIR=%~dp0%venv"
)

mkdir tmp 2> NUL
%PYTHON% -c "" > tmp/stdout.txt 2> tmp/stderr.txt

if %ERRORLEVEL% == 0 goto :check_pip
echo Couldn't find python
goto :show_stdout_stderr

:check_pip
%PYTHON% -m pip --help > tmp/stdout.txt 2> tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :start_venv
if %PIP_INSTALLER_LOCATION% == "" goto :show_stdout_stderr
%PYTHON% "%PIP_INSTALLER_LOCATION%" > tmp/stdout.txt 2> tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :start_venv
echo Couldn't install pip
goto :show_stdout_stderr

:start_venv
if ["%VENV_DIR%"] == ["-"] goto :launch
if ["%SKIP_VENV%"] == ["1"] goto :launch
dir "%VENV_DIR%\Scripts\Python.exe" > tmp/stdout.txt 2> tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :activate_venv
for /f "delims=" %%i in ('call %PYTHON% -c "import sys; print(sys.executable)"') do set PYTHON_FULLNAME="%%i"
echo Creating venv in directory %VENV_DIR% using python %PYTHON_FULLNAME%
%PYTHON_FULLNAME% -m venv "%VENV_DIR%" > tmp/stdout.txt 2> tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :activate_venv
echo Unable to create venv in directory %VENV_DIR%
goto :show_stdout_stderr

:activate_venv
set PYTHON="%VENV_DIR%\Scripts\Python.exe"
echo venv %PYTHON%

:launch
%PYTHON% launch.py %*
pause
exit /b

:show_stdout_stderr
echo.
echo exit code: %ERRORLEVEL%
for /f %%i in ("tmp\stdout.txt") do set size=%%~zi
if %size% equ 0 goto :show_stderr
echo.
echo stdout:
type tmp\stdout.txt

:show_stderr
for /f %%i in ("tmp\stderr.txt") do set size=%%~zi
if %size% equ 0 goto :show_stderr
echo.
echo stderr:
type tmp\stderr.txt

:endofscript
echo.
echo Launch unsuccessful. Exiting.
pause
