#!/bin/bash
set -e

SOURCE_ICON="/Users/tiger/.gemini/antigravity/brain/4f6c86e7-83d8-4388-9a64-57c8861993f7/openclaw_app_icon_1769936547758.png"

echo "Creating iconset..."
mkdir -p OpenClawManager.iconset

sips -z 16 16     -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_16x16.png
sips -z 32 32     -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_16x16@2x.png
sips -z 32 32     -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_32x32.png
sips -z 64 64     -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_32x32@2x.png
sips -z 128 128   -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_128x128.png
sips -z 256 256   -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_128x128@2x.png
sips -z 256 256   -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_256x256.png
sips -z 512 512   -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_256x256@2x.png
sips -z 512 512   -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_512x512.png
sips -z 1024 1024 -s format png "$SOURCE_ICON" --out OpenClawManager.iconset/icon_512x512@2x.png

echo "Converting to icns..."
iconutil -c icns OpenClawManager.iconset

echo "Moving to Resources..."
mkdir -p Sources/OpenClawManager/Resources
mv OpenClawManager.icns Sources/OpenClawManager/Resources/AppIcon.icns

# Clean up
rm -rf OpenClawManager.iconset

echo "Icon created successfully!"
