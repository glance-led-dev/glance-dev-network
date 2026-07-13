@echo off
REM ===========================================================================
REM  Glance Dev Studio launcher
REM
REM  Double-click this file to open Glance Dev Studio in your web browser.
REM  (Or run it from a terminal by typing:  studio )
REM
REM  It always starts from this folder, so it finds your apps no matter what,
REM  and you never have to remember a command or which directory you're in.
REM ===========================================================================

REM Always run from the folder this file lives in (the project root).
cd /d "%~dp0"

echo Starting Glance Dev Studio...
echo Your browser will open at http://localhost:8766
echo Close this window when you are done.
echo.

REM Prefer the installed `gdn` command; fall back to the Python module if the
REM command isn't on PATH (e.g. a fresh copy that hasn't been installed yet).
where gdn >nul 2>nul
if %errorlevel%==0 (
    gdn studio %*
) else (
    python -m gdn.cli studio %*
)

REM If it stopped with an error, keep the window open so the message is readable.
if errorlevel 1 (
    echo.
    echo Studio stopped. Read the message above, then press any key to close.
    pause >nul
)
