#!/usr/bin/env bash
# ==============================================================================
# 03_debloat_safe.sh
# Safely debloat Android TV telemetry, adware rows, and OEM background killers.
# Uses `pm disable-user --user 0` (Non-destructive, completely reversible).
# ==============================================================================
set -euo pipefail

TARGET_DEVICE="${1:-}"
ADB_CMD="adb"
if [ -n "$TARGET_DEVICE" ]; then
    ADB_CMD="adb -s $TARGET_DEVICE"
fi

# List of OEM telemetry, adware, and bloatware packages
PACKAGES_TO_DISABLE=(
    # Telemetry, Diagnostics & Activation Trackers
    "com.smartdevice.recordactivation"
    "com.smartdevice.dtv.icast"
    "com.google.android.feedback"

    # Adware & Sponsored Recommendation Injectors
    "com.smartdevice.recommendation"
    "com.smartdevice.leanbacklauncher.customizer"

    # Unnecessary OEM Background Services & Aggressive Cleaners
    "com.smartdevice.aftersale"
    "com.smartdevice.dailymanage"
    "com.smartdevice.dailyshortcut"
    "com.smartdevice.factory"
    "com.Smartdevice.emanual"
    "com.audiocn.karaoke.global.micmanager"
    "com.loostone.tuning"

    # Stock Google TV Launcher (Disabled after installing custom launcher)
    "com.google.android.apps.tv.launcherx"
    "com.google.android.tungsten.setupwraith"
)

echo "================================================================="
echo " Starting Safe Debloat Process"
echo "================================================================="
echo "Note: Critical system services (HDMI inputs, TV Tuner, Bluetooth"
echo "remote pairing, and Google Play Store) are strictly preserved."
echo "================================================================="
echo ""

DISABLED_COUNT=0
SKIPPED_COUNT=0

for pkg in "${PACKAGES_TO_DISABLE[@]}"; do
    if $ADB_CMD shell "pm list packages" | grep -q "^package:${pkg}$"; then
        echo -n "[*] Disabling ${pkg}... "
        $ADB_CMD shell "pm disable-user --user 0 ${pkg}" >/dev/null 2>&1 || true
        echo "Done"
        DISABLED_COUNT=$((DISABLED_COUNT + 1))
    else
        echo "[!] Skipping ${pkg} (not installed on device)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    fi
done

echo ""
echo "================================================================="
echo "[✓] Debloating complete!"
echo "    Packages disabled: ${DISABLED_COUNT}"
echo "    Packages skipped:  ${SKIPPED_COUNT}"
echo "================================================================="
echo "To revert at any time, run: ./scripts/restore_all.sh"
