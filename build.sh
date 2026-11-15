#!/bin/sh
set -e
cd "$(dirname "$0")"
APP=StayAwake.app
rm -rf "$APP" && mkdir -p "$APP/Contents/MacOS"
swiftc -O Sources/main.swift -o "$APP/Contents/MacOS/StayAwake"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.mwolfe.stayawake</string>
<key>CFBundleName</key><string>StayAwake</string>
<key>CFBundleExecutable</key><string>StayAwake</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign -s - --force "$APP"
