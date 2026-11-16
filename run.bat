@echo off
REM ===========================================================================
REM  WellTrack — build and run (Windows)
REM
REM  Requires nothing but a JDK 17 or newer on the PATH.
REM  No Maven, no Gradle, no internet connection, no database server.
REM ===========================================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo   WellTrack - AI Student Burnout Detection System
echo   ================================================
echo.

where javac >nul 2>nul
if errorlevel 1 (
    echo   [ERROR] javac was not found on your PATH.
    echo           Install JDK 17 or newer, or run this from the IntelliJ terminal.
    pause
    exit /b 1
)

echo   [1/3] Compiling Java sources...
if not exist out mkdir out
dir /s /b src\main\java\*.java > "%TEMP%\welltrack-sources.txt"
javac -d out -encoding UTF-8 "@%TEMP%\welltrack-sources.txt"
if errorlevel 1 (
    echo   [ERROR] Compilation failed.
    pause
    exit /b 1
)

echo   [2/3] Copying web resources...
xcopy /E /I /Y /Q src\main\resources\* out\ >nul

echo   [3/3] Starting the server...
echo.
java -Dfile.encoding=UTF-8 -cp out com.welltrack.WellTrackApplication

endlocal
