# Always-On AirPlay 2 on Android TV: Technical Guide

This document details how **FreeAndroid-TV-OS** achieves an always-on Apple AirPlay receiver on Android 14 using open-source components, along with protocol realities and background service configurations.

---

## Architecture: UxPlay Ported to Android

The underlying engine used is [android-airplay-server](https://github.com/jqssun/android-airplay-server), a GPLv3 open-source AirPlay 2 receiver based on **UxPlay**:
* **Protocol:** RAOP (Remote Audio Output Protocol) for lossless audio + RTSP/FairPlay pairing for video and screen mirroring.
* **Audio Codecs:** Apple Lossless (ALAC), AAC-ELD, and AAC-LC with hardware or software decoding.
* **Video Codecs:** H.264 and H.265 (HEVC) decoded via Android's hardware `MediaCodec` into a native `SurfaceView`.
* **Discovery:** Native mDNS/Bonjour broadcast using Android `NsdManager` advertising `_raop._tcp` and `_airplay._tcp` on local port 5353.

---

## Overcoming Android 14 Background Restrictions

On Android 14 (API 34), Google introduced strict background execution limitations:
1. **Background Foreground Service Starts:** Apps cannot arbitrarily launch foreground services from the background unless granted specific exemptions.
2. **Cached App Freezing:** When an activity moves to the background, Android freezes its Linux cgroup (`ActivityManager: freezing <pid>`). If an AirPlay server process is frozen, its network sockets stop responding and the mDNS listener dies.

### The Fix Applied in This Setup:
```bash
# 1. Allow the app to launch its mirroring activity over other apps
adb shell appops set io.github.jqssun.airplay SYSTEM_ALERT_WINDOW allow

# 2. Grant notification permission for persistent Foreground Service
adb shell pm grant io.github.jqssun.airplay android.permission.POST_NOTIFICATIONS

# 3. Whitelist package from Android Doze / power standby
adb shell dumpsys deviceidle whitelist +io.github.jqssun.airplay

# 4. Enable internal background and auto-boot preferences
adb shell am broadcast -n io.github.jqssun.airplay/.SettingsReceiver -a io.github.jqssun.airplay.SET_SETTING --es key "run_in_background" --es value "true"
adb shell am broadcast -n io.github.jqssun.airplay/.SettingsReceiver -a io.github.jqssun.airplay.SET_SETTING --es key "boot_auto_start" --es value "true"
adb shell am broadcast -n io.github.jqssun.airplay/.SettingsReceiver -a io.github.jqssun.airplay.SET_SETTING --es key "launch_on_connect" --es value "true"
```

---

## Understanding Apple DRM (What Works vs What Doesn't)

* **What Works Seamlessly:**
  * iPhone, iPad, and Mac **Screen Mirroring** (photos, safari tabs, camera roll, Keynote/PowerPoint, games, Zoom, personal videos).
  * Streaming audio from **Apple Music**, **Spotify (iOS)**, **Apple Podcasts**, YouTube Music, or any web browser media stream.
  * System audio and track metadata (title, artist, album art) with lockscreen controls.
* **What Does Not Work (Hardware FairPlay DRM):**
  * Mirroring protected video streams from commercial iOS subscription apps (e.g. Netflix, Disney+, Apple TV+ app inside iOS).
  * Apple encrypts these video streams with hardware-level FairPlay DRM keys that non-Apple certified receivers cannot decrypt (resulting in black video with audio only).
  * **Solution:** Use the native Google TV apps (Netflix, Disney+ Hotstar, Prime Video) installed directly on the TV, which run in full 4K HDR Dolby Vision natively.
