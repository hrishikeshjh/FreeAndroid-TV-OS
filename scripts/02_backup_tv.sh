#!/usr/bin/env bash
# ==============================================================================
# 02_backup_tv.sh
# Full state backup of Android TV settings, packages, and system properties
# ==============================================================================
set -euo pipefail

TARGET_DEVICE="${1:-}"
ADB_CMD="adb"
if [ -n "$TARGET_DEVICE" ]; then
    ADB_CMD="adb -s $TARGET_DEVICE"
fi

BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "[*] Backing up system properties to ${BACKUP_DIR}/getprop.txt..."
$ADB_CMD shell getprop > "${BACKUP_DIR}/getprop.txt"

echo "[*] Backing up package lists..."
$ADB_CMD shell pm list packages -f > "${BACKUP_DIR}/packages_full.txt"
$ADB_CMD shell pm list packages -e > "${BACKUP_DIR}/packages_enabled.txt"
$ADB_CMD shell pm list packages -d > "${BACKUP_DIR}/packages_disabled.txt"
$ADB_CMD shell pm list packages -s > "${BACKUP_DIR}/packages_system.txt"
$ADB_CMD shell pm list packages -3 > "${BACKUP_DIR}/packages_thirdparty.txt"

echo "[*] Backing up Android settings tables..."
$ADB_CMD shell settings list global > "${BACKUP_DIR}/settings_global.txt" 2>/dev/null || true
$ADB_CMD shell settings list secure > "${BACKUP_DIR}/settings_secure.txt" 2>/dev/null || true
$ADB_CMD shell settings list system > "${BACKUP_DIR}/settings_system.txt" 2>/dev/null || true

echo "[*] Backing up current default launcher..."
$ADB_CMD shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME > "${BACKUP_DIR}/current_launcher.txt" 2>/dev/null || true

echo ""
echo "[✓] Backup complete! Saved in: ${BACKUP_DIR}/"
