@echo off
REM  WellTrack — run the automated test suite (Windows)
setlocal
cd /d "%~dp0"
if not exist out mkdir out
if not exist out-test mkdir out-test
dir /s /b src\main\java\*.java > "%TEMP%\wt-main.txt"
javac -d out -encoding UTF-8 "@%TEMP%\wt-main.txt" || exit /b 1
dir /s /b src\test\java\*.java > "%TEMP%\wt-test.txt"
javac -d out-test -cp out -encoding UTF-8 "@%TEMP%\wt-test.txt" || exit /b 1
java -Dfile.encoding=UTF-8 -cp out;out-test com.welltrack.TestRunner
endlocal
