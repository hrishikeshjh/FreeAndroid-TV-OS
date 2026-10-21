#!/usr/bin/env bash
# ==============================================================================
# 04_install_smarttube.sh
# Download and install SmartTube (Ad-Free YouTube with SponsorBlock for Android TV)
# ==============================================================================
set -euo pipefail

TARGET_DEVICE="${1:-}"
ADB_CMD="adb"
if [ -n "$TARGET_DEVICE" ]; then
    ADB_CMD="adb -s $TARGET_DEVICE"
fi

TMP_DIR="$(mktemp -d)"
APK_PATH="${TMP_DIR}/smarttube_stable.apk"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "[*] Fetching latest SmartTube Stable download URL from GitHub API..."
DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/yuliskov/SmartTube/releases/latest \
    | grep -oE 'https://github.com/yuliskov/SmartTube/releases/download/[^"]+/smarttube_stable_armeabi-v7a_[^"]+\.apk' \
    | head -n 1 || true)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "[!] Fallback: using default official stable release direct link..."
    DOWNLOAD_URL="https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_stable.apk"
fi

echo "[*] Downloading SmartTube from: ${DOWNLOAD_URL}..."
curl -L "$DOWNLOAD_URL" -o "$APK_PATH"

echo "[*] Pushing APK to TV temporary storage..."
$ADB_CMD push "$APK_PATH" /data/local/tmp/smarttube_stable.apk

echo "[*] Installing SmartTube on TV..."
$ADB_CMD shell "pm install -r /data/local/tmp/smarttube_stable.apk && rm /data/local/tmp/smarttube_stable.apk"

echo ""
echo "[✓] SmartTube successfully installed! (Package: org.smarttube.stable)"
echo "    Enjoy 4K HDR playback, zero video ads, and integrated SponsorBlock."
