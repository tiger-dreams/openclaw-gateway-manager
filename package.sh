#!/bin/bash
set -e

APP_NAME="OpenClawManager"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
RESOURCES_DIR="${APP_BUNDLE}/Contents/Resources"
ICON_NAME="AppIcon"
ICNS_NAME="${ICON_NAME}.icns"

echo "Building ${APP_NAME}..."
swift build -c release

echo "Creating App Bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"

# Copy ICNS icon file (macOS requires .icns format)
if [ -f "Sources/${APP_NAME}/Resources/${ICNS_NAME}" ]; then
    cp "Sources/${APP_NAME}/Resources/${ICNS_NAME}" "${RESOURCES_DIR}/"
    echo "Icon (ICNS) copied to Resources"
fi

# Create Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>ai.openclaw.manager</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>${ICON_NAME}</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "App Bundle created at ${APP_BUNDLE}"

echo "Creating DMG..."
DMG_NAME="${APP_NAME}.dmg"
if [ -f "${DMG_NAME}" ]; then
    rm "${DMG_NAME}"
fi

# Check if create-dmg is available
if command -v create-dmg &> /dev/null; then
    # Use create-dmg for visual drag-install interface
    DMG_BG="Sources/${APP_NAME}/Resources/dmg-background.png"
    create-dmg \
        --volname "${APP_NAME}" \
        --background "${DMG_BG}" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "${APP_BUNDLE}" 150 190 \
        --app-drop-link 450 190 \
        "${DMG_NAME}" \
        "${APP_BUNDLE}"
else
    echo "Warning: create-dmg not found. Using basic DMG creation."
    echo "Install with: brew install create-dmg"

    # Fallback to basic DMG creation
    STAGING_DIR="dmg_root"
    rm -rf "${STAGING_DIR}"
    mkdir -p "${STAGING_DIR}"

    cp -r "${APP_BUNDLE}" "${STAGING_DIR}/"
    ln -s /Applications "${STAGING_DIR}/Applications"

    hdiutil create -volname "${APP_NAME}" -srcfolder "${STAGING_DIR}" -ov -format UDZO "${DMG_NAME}"

    rm -rf "${STAGING_DIR}"
fi

echo "Done! Installer created: ${DMG_NAME}"
