#!/usr/bin/env bash
# ==============================================================================
# 07_install_retroarch.sh
# Download and install RetroArch (Universal Retro Gaming Emulator for Android TV)
# ==============================================================================
set -euo pipefail

TARGET_DEVICE="${1:-}"
ADB_CMD="adb"
if [ -n "$TARGET_DEVICE" ]; then
    ADB_CMD="adb -s $TARGET_DEVICE"
fi

TMP_DIR="$(mktemp -d)"
APK_PATH="${TMP_DIR}/retroarch.apk"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "[*] Downloading official RetroArch Android TV APK from Libretro buildbot..."
RETROARCH_URL="https://buildbot.libretro.com/stable/1.22.2/android/RetroArch.apk"

curl -L "$RETROARCH_URL" -o "$APK_PATH"

echo "[*] Pushing RetroArch APK (~190 MB) to TV storage..."
$ADB_CMD push "$APK_PATH" /data/local/tmp/retroarch.apk

echo "[*] Installing RetroArch on TV..."
$ADB_CMD shell "pm install -r /data/local/tmp/retroarch.apk && rm /data/local/tmp/retroarch.apk"

echo ""
echo "[✓] RetroArch successfully installed! (Package: com.retroarch)"
echo "    Full Leanback TV UI enabled with Bluetooth controller and remote support."
