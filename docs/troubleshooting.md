# Troubleshooting & FAQ

### 1. Wireless ADB Drops After TV Idles / Goes to Sleep
* **Cause:** In Android 11–14, Google TV's dynamic wireless debugging port changes or stops when the screen turns off.
* **Solution:** 
  1. Wake the TV with the remote.
  2. In Developer Options, enable Wireless debugging and connect once:
     ```bash
     adb connect <TV_IP>:<PORT>
     ```
  3. Immediately lock in the standard port 5555:
     ```bash
     adb tcpip 5555
     adb connect <TV_IP>:5555
     ```
  4. Port 5555 will remain accessible as long as the TV is on the Wi-Fi network.

---

### 2. Live TV / HDMI Inputs Can't Be Switched
* **Check:** Ensure you did **not** disable `com.mediatek.tis` or `com.google.android.tv.googletvremotepairer`.
* **Fix:** Re-enable the hardware input switcher:
  ```bash
  adb shell pm enable com.mediatek.wwtv.tvcenter
  ```
* In the FreeAndroid-TV-OS launcher, open the **Inputs** tile on the dock to switch between HDMI 1, HDMI 2, and AV directly.

---

### 3. AirPlay Device Name Doesn't Match My TV
* **Check:** Query the device name:
  ```bash
  adb shell settings get global device_name
  ```
* **Set AirPlay Name:**
  ```bash
  adb shell am broadcast -n io.github.jqssun.airplay/.SettingsReceiver -a io.github.jqssun.airplay.SET_SETTING --es key "server_name" --es value "Living room TV"
  ```

---

### 4. How to Completely Undo All Changes
Run the 1-click restore script:
```bash
./scripts/restore_all.sh
```
This restores the stock Google TV LauncherX, re-enables all disabled OEM packages, restores animation scales to 1.0x, and resets the screensaver back to default. No factory reset required.
