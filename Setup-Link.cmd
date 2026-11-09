@echo off
setlocal
echo 1. Enable and start Apple Music - Lyricify Fusion link
echo 2. Disable the link
choice /c 12 /n /m "Select 1 or 2: "
if errorlevel 255 exit /b 1
if errorlevel 2 (
    set "mode=Disable"
) else (
    set "mode=Enable"
)
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0AppleMusic-Lyricify.ps1" -Mode %mode%
pause
