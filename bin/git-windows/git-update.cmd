@echo off
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0git-jgd.ps1" update %*
exit /b %ERRORLEVEL%
