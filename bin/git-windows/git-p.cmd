@echo off
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0git-jgd.ps1" p %*
exit /b %ERRORLEVEL%
