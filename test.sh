#!/usr/bin/env bash
#  WellTrack — run the automated test suite (macOS / Linux)
set -e
cd "$(dirname "$0")"
mkdir -p out out-test
find src/main/java -name '*.java' > /tmp/wt-main.txt && javac -d out -encoding UTF-8 @/tmp/wt-main.txt
find src/test/java -name '*.java' > /tmp/wt-test.txt && javac -d out-test -cp out -encoding UTF-8 @/tmp/wt-test.txt
java -Dfile.encoding=UTF-8 -cp out:out-test com.welltrack.TestRunner
