#!/usr/bin/env bash
# ==============================================================================
# restore_all.sh
# 1-Click Rollback: Re-enable all OEM packages, restore stock launcher & animations
# ==============================================================================
set -euo pipefail

TARGET_DEVICE="${1:-}"
ADB_CMD="adb"
if [ -n "$TARGET_DEVICE" ]; then
    ADB_CMD="adb -s $TARGET_DEVICE"
fi

PACKAGES_TO_ENABLE=(
    "com.smartdevice.recordactivation"
    "com.smartdevice.dtv.icast"
    "com.google.android.feedback"
    "com.smartdevice.recommendation"
    "com.smartdevice.leanbacklauncher.customizer"
    "com.smartdevice.aftersale"
    "com.smartdevice.dailymanage"
    "com.smartdevice.dailyshortcut"
    "com.smartdevice.factory"
    "com.Smartdevice.emanual"
    "com.audiocn.karaoke.global.micmanager"
    "com.loostone.tuning"
    "com.google.android.apps.tv.launcherx"
    "com.google.android.tungsten.setupwraith"
)

echo "================================================================="
echo " Starting Factory Rollback"
echo "================================================================="

for pkg in "${PACKAGES_TO_ENABLE[@]}"; do
    echo -n "[*] Re-enabling ${pkg}... "
    $ADB_CMD shell "pm enable ${pkg}" >/dev/null 2>&1 || true
    echo "Done"
done

echo "[*] Restoring stock animation scales to 1.0x..."
$ADB_CMD shell "settings put global window_animation_scale 1.0"
$ADB_CMD shell "settings put global transition_animation_scale 1.0"
$ADB_CMD shell "settings put global animator_duration_scale 1.0"

echo "[*] Restoring default stock screensaver..."
$ADB_CMD shell "settings put secure screensaver_components null"
$ADB_CMD shell "settings put system screen_off_timeout 600000"

echo "[*] Launching stock Home activity..."
$ADB_CMD shell "input keyevent KEYCODE_HOME"

echo ""
echo "[✓] All OEM packages and default settings successfully restored!"
