@echo off
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0git-jgd.ps1" fresh %*
exit /b %ERRORLEVEL%
