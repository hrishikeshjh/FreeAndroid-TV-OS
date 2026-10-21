#!/usr/bin/env bash
# ==============================================================================
# 08_tune_performance.sh
# Tune Android TV animation and transition scales to 0.5x for zero-latency response
# ==============================================================================
set -euo pipefail

TARGET_DEVICE="${1:-}"
ADB_CMD="adb"
if [ -n "$TARGET_DEVICE" ]; then
    ADB_CMD="adb -s $TARGET_DEVICE"
fi

echo "[*] Setting Window Animation Scale to 0.5x..."
$ADB_CMD shell "settings put global window_animation_scale 0.5"

echo "[*] Setting Transition Animation Scale to 0.5x..."
$ADB_CMD shell "settings put global transition_animation_scale 0.5"

echo "[*] Setting Animator Duration Scale to 0.5x..."
$ADB_CMD shell "settings put global animator_duration_scale 0.5"

echo ""
echo "[✓] Animation scales successfully tuned to 0.5x!"
echo "    Current values:"
echo "    - window_animation_scale:     $($ADB_CMD shell settings get global window_animation_scale)"
echo "    - transition_animation_scale: $($ADB_CMD shell settings get global transition_animation_scale)"
echo "    - animator_duration_scale:   $($ADB_CMD shell settings get global animator_duration_scale)"
