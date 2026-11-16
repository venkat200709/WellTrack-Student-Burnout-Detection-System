#!/usr/bin/env bash
# ===========================================================================
#  WellTrack — build and run (macOS / Linux)
#  Requires only a JDK 17 or newer. No build tool, no database, no network.
# ===========================================================================
set -e
cd "$(dirname "$0")"

echo
echo "  WellTrack - AI Student Burnout Detection System"
echo "  ================================================"
echo

command -v javac >/dev/null || { echo "  [ERROR] javac not found. Install JDK 17+."; exit 1; }

echo "  [1/3] Compiling Java sources..."
mkdir -p out
find src/main/java -name '*.java' > /tmp/welltrack-sources.txt
javac -d out -encoding UTF-8 @/tmp/welltrack-sources.txt

echo "  [2/3] Copying web resources..."
cp -r src/main/resources/* out/ 2>/dev/null || true

echo "  [3/3] Starting the server..."
echo
java -Dfile.encoding=UTF-8 -cp out com.welltrack.WellTrackApplication
