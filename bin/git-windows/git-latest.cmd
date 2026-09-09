@echo off
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0git-jgd.ps1" latest %*
exit /b %ERRORLEVEL%
