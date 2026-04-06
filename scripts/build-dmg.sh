#!/bin/bash
set -euo pipefail

# Configuration
APP_NAME="InDraft"
SCHEME="InDraft"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
RELEASE_DIR="${PROJECT_DIR}/release"
APP_PATH="${BUILD_DIR}/Build/Products/Release/${APP_NAME}.app"

# Get version from arg or fallback
VERSION="${1:-$(defaults read "${PROJECT_DIR}/InDraft/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "0.0.0")}"
DMG_NAME="${APP_NAME}-v${VERSION}.dmg"
DMG_PATH="${RELEASE_DIR}/${DMG_NAME}"

echo "==> Building ${APP_NAME} v${VERSION}..."

# Step 1: Build the app
xcodebuild -scheme "${SCHEME}" \
    -configuration Release \
    -derivedDataPath "${BUILD_DIR}" \
    clean build 2>&1 | tail -5

if [ ! -d "${APP_PATH}" ]; then
    echo "ERROR: Build failed - ${APP_PATH} not found"
    exit 1
fi

echo "==> Build succeeded"

# Step 2: Create DMG with create-dmg (handles Applications symlink + layout)
echo "==> Creating DMG..."
mkdir -p "${RELEASE_DIR}"
rm -f "${DMG_PATH}"

create-dmg \
    --volname "${APP_NAME}" \
    --window-pos 200 120 \
    --window-size 500 270 \
    --icon-size 80 \
    --icon "${APP_NAME}.app" 125 135 \
    --app-drop-link 375 135 \
    --no-internet-enable \
    "${DMG_PATH}" \
    "${APP_PATH}"

echo "==> DMG created: ${DMG_PATH}"
echo "==> Size: $(du -h "${DMG_PATH}" | cut -f1)"
