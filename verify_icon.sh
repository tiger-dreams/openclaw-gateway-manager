#!/bin/bash
echo "Set: Checking App Bundle..."
APP="OpenClawManager.app"

if [ -f "$APP/Contents/Resources/AppIcon.icns" ]; then
    echo "✅ AppIcon.icns exists."
else
    echo "❌ AppIcon.icns MISSING!"
fi

echo "Checking Info.plist..."
grep "CFBundleIconFile" "$APP/Contents/Info.plist" -A 1
