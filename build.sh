#!/bin/bash
# Builds a native arm64 (Apple Silicon) WiFiName.app without needing the Xcode IDE.
# Requires macOS 13+ on an Apple Silicon Mac with Xcode or the Command Line Tools.
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release --arch arm64
BIN="$(swift build -c release --arch arm64 --show-bin-path)/WiFiName"

APP="build/WiFiName.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN" "$APP/Contents/MacOS/WiFiName"
cp Resources/Info.plist "$APP/Contents/Info.plist"

# Ad-hoc sign so macOS will attach a Location permission to the bundle.
codesign --force --sign - "$APP"

echo "Built $APP"
lipo -archs "$APP/Contents/MacOS/WiFiName"
echo "Run with: open $APP"
