#!/usr/bin/env bash
# ==============================================================================
# 05_setup_airplay.sh
# Install and configure open-source AirPlay 2 receiver for always-on background use
# ==============================================================================
set -euo pipefail

TARGET_DEVICE="${1:-}"
ADB_CMD="adb"
if [ -n "$TARGET_DEVICE" ]; then
    ADB_CMD="adb -s $TARGET_DEVICE"
fi

TMP_DIR="$(mktemp -d)"
APK_PATH="${TMP_DIR}/airplay-release.apk"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "[*] Fetching latest android-airplay-server release from GitHub..."
DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/jqssun/android-airplay-server/releases/latest \
    | grep -oE 'https://github.com/jqssun/android-airplay-server/releases/download/[^"]+/app-release\.apk' \
    | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    DOWNLOAD_URL="https://github.com/jqssun/android-airplay-server/releases/download/v0.0.36/app-release.apk"
fi

echo "[*] Downloading AirPlay APK from: ${DOWNLOAD_URL}..."
curl -L "$DOWNLOAD_URL" -o "$APK_PATH"

echo "[*] Installing android-airplay-server on TV..."
$ADB_CMD push "$APK_PATH" /data/local/tmp/airplay.apk
$ADB_CMD shell "pm install -r /data/local/tmp/airplay.apk && rm /data/local/tmp/airplay.apk"

echo "[*] Configuring background permissions & battery optimizations..."
# Allow pop-up over other apps when mirroring starts
$ADB_CMD shell "appops set io.github.jqssun.airplay SYSTEM_ALERT_WINDOW allow"
# Grant persistent notification permission
$ADB_CMD shell "pm grant io.github.jqssun.airplay android.permission.POST_NOTIFICATIONS" 2>/dev/null || true
# Whitelist from Doze mode
$ADB_CMD shell "dumpsys deviceidle whitelist +io.github.jqssun.airplay" >/dev/null 2>&1 || true

# Get TV system name to match in AirPlay mDNS broadcast
TV_NAME=$($ADB_CMD shell "settings get global device_name" 2>/dev/null | tr -d '\r\n' || echo "Living room TV")
if [ -z "$TV_NAME" ] || [ "$TV_NAME" = "null" ]; then
    TV_NAME="Living room TV"
fi

echo "[*] Setting AirPlay broadcast name to: '${TV_NAME}'..."
$ADB_CMD shell "am broadcast -n io.github.jqssun.airplay/.SettingsReceiver -a io.github.jqssun.airplay.SET_SETTING --es key 'server_name' --es value '${TV_NAME}'" >/dev/null

echo "[*] Enabling always-on background mode and auto-boot start..."
$ADB_CMD shell "am broadcast -n io.github.jqssun.airplay/.SettingsReceiver -a io.github.jqssun.airplay.SET_SETTING --es key 'run_in_background' --es value 'true'" >/dev/null
$ADB_CMD shell "am broadcast -n io.github.jqssun.airplay/.SettingsReceiver -a io.github.jqssun.airplay.SET_SETTING --es key 'boot_auto_start' --es value 'true'" >/dev/null
$ADB_CMD shell "am broadcast -n io.github.jqssun.airplay/.SettingsReceiver -a io.github.jqssun.airplay.SET_SETTING --es key 'launch_on_connect' --es value 'true'" >/dev/null

echo "[*] Starting AirPlay service..."
$ADB_CMD shell "am start -n io.github.jqssun.airplay/.MainActivity" >/dev/null 2>&1
sleep 2
$ADB_CMD shell "input keyevent KEYCODE_HOME" >/dev/null 2>&1

echo ""
echo "[✓] Always-On AirPlay is active! Broadcast name: '${TV_NAME}'"
echo "    You can now stream audio or mirror screens from iPhone, iPad, or Mac."
