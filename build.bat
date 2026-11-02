@echo off
REM Agervis Desktop App - Setup and Build Script (Windows)

echo.
echo === Agervis Desktop App Builder ===
echo.
echo Installing dependencies...
call npm install

echo.
echo Building Electron app...
call npm run build:electron

echo.
echo Building React app...
call npm run build:react

echo.
echo Build complete!
echo.
echo To package for Windows:
echo   npm run package:win
echo.
