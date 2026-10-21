#!/usr/bin/env bash
# ==============================================================================
# 01_connect_wireless_adb.sh
# Connect to Android / Google TV via Wireless ADB and persist TCP/IP port 5555
# ==============================================================================
set -euo pipefail

TV_IP="${1:-}"
PORT="${2:-5555}"

if [ -z "$TV_IP" ]; then
    echo "Usage: $0 <TV_IP_ADDRESS> [PORT]"
    echo ""
    echo "Tip: On your TV, navigate to:"
    echo "  Settings -> System -> About -> Tap 'Build' 7 times (Enables Developer options)"
    echo "  Settings -> System -> Developer options -> Enable 'Wireless debugging'"
    echo ""
    read -rp "Enter TV IP address: " TV_IP
    read -rp "Enter Port (default 5555): " input_port
    PORT="${input_port:-5555}"
fi

echo "[*] Connecting to TV at ${TV_IP}:${PORT}..."
adb connect "${TV_IP}:${PORT}"

echo "[*] Setting persistent ADB TCP/IP port 5555..."
adb -s "${TV_IP}:${PORT}" tcpip 5555 || true
sleep 2

echo "[*] Reconnecting on default port 5555..."
adb connect "${TV_IP}:5555"

echo ""
echo "[+] Connected Devices:"
adb devices -l
echo ""
echo "[✓] Connected successfully! You can now run the next script."
