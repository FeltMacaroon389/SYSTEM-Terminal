@echo off

REM Check if running with admin privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges
    set "admin=1"
) else (
    echo Not running with administrator privileges. Attempting to elevate...
    set "admin=0"
)

REM If not running with admin privileges, elevate
if "%admin%"=="0" (
    echo Elevating privileges...
    >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" || (
        echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
        echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
        "%temp%\getadmin.vbs"
        del "%temp%\getadmin.vbs"
        exit /B
    )
    echo Successfully elevated privileges!
)

REM Download and extract PsExec
echo Downloading PsExec...
set "tempDir=%temp%\PSTools"
set "zipFile=%tempDir%\PSTools.zip"
set "exeFile=%tempDir%\PsExec.exe"

mkdir "%tempDir%" 2>nul
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/PSTools.zip', '%zipFile%')"
powershell Expand-Archive -Path "%zipFile%" -DestinationPath "%tempDir%" -Force

REM Elevating to SYSTEM
echo Getting system...
start /wait cmd /c "%exeFile% -i -s cmd.exe"

REM Clean up
echo Cleaning up...
timeout /t 1 /nobreak >nul
del "%zipFile%" /f /q
rmdir "%tempDir%" /s /q
echo Cleanup complete.
