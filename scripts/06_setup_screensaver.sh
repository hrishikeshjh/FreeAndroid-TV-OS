#!/usr/bin/env bash
# ==============================================================================
# 06_setup_screensaver.sh
# Install and configure Aerial Views (Apple TV 4K cinematic screensavers)
# ==============================================================================
set -euo pipefail

TARGET_DEVICE="${1:-}"
ADB_CMD="adb"
if [ -n "$TARGET_DEVICE" ]; then
    ADB_CMD="adb -s $TARGET_DEVICE"
fi

INACTIVITY_TIMEOUT_MS="${2:-90000}" # 90 seconds (1.5 min) default

TMP_DIR="$(mktemp -d)"
APK_PATH="${TMP_DIR}/aerial_views.apk"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "[*] Fetching latest Aerial Views release from GitHub..."
DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/theothernt/AerialViews/releases/latest \
    | grep -oE 'https://github.com/theothernt/AerialViews/releases/download/[^"]+/aerial-views-[^"]+\.apk' \
    | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    DOWNLOAD_URL="https://github.com/theothernt/AerialViews/releases/download/1.8.5/aerial-views-1.8.5.apk"
fi

echo "[*] Downloading Aerial Views APK from: ${DOWNLOAD_URL}..."
curl -L "$DOWNLOAD_URL" -o "$APK_PATH"

echo "[*] Installing Aerial Views on TV..."
$ADB_CMD push "$APK_PATH" /data/local/tmp/aerial_views.apk
$ADB_CMD shell "pm install -r /data/local/tmp/aerial_views.apk && rm /data/local/tmp/aerial_views.apk"

echo "[*] Configuring Aerial Views as the primary system DreamService screensaver..."
$ADB_CMD shell "settings put secure screensaver_components com.neilturner.aerialviews/com.neilturner.aerialviews.ui.screensaver.DreamActivity"
$ADB_CMD shell "settings put secure screensaver_enabled 1"
$ADB_CMD shell "settings put secure screensaver_activate_on_sleep 1"
$ADB_CMD shell "settings put secure screensaver_activate_on_dock 1"

echo "[*] Setting inactivity screensaver timeout to $((INACTIVITY_TIMEOUT_MS / 1000)) seconds..."
$ADB_CMD shell "settings put system screen_off_timeout ${INACTIVITY_TIMEOUT_MS}"

echo ""
echo "[✓] Aerial Views successfully configured!"
echo "    The TV will now play Apple TV 4K HDR cinematic footage after $((INACTIVITY_TIMEOUT_MS / 1000)) seconds of idle."
