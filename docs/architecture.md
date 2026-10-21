# FreeAndroid-TV-OS: Architecture & Design

```
+--------------------------------------------------------------------------+
|                        Apple tvOS Clean Home UI                          |
|  +--------------------------------------------------------------------+  |
|  | Status Bar: Clock, Date, Ambient Solar Pills, 1-Click RAM Cleaner  |  |
|  +--------------------------------------------------------------------+  |
|  | Dock Row (5 Cols): YouTube | Hotstar | SonyLIV | Spotify | Inputs  |  |
|  +--------------------------------------------------------------------+  |
|  | Pinned Favorites: Xiaomi TV+ | SmartTube | AirPlay | RetroArch     |  |
|  +--------------------------------------------------------------------+  |
|  | All Sideloaded & Leanback Apps Grid (Dynamic Discovery)            |  |
+--------------------------------------------------------------------------+
         |                                                 |
         v (Intent / Process Management)                   v (Hardware Interop)
+--------------------------------------+      +----------------------------+
|        ActivityManager & LMK         |      |    MediaCodec & AudioTrack |
| - 0.5x Scale Performance Booster     |      | - 4K HEVC / H.264 Mirroring|
| - Process Freeze Exemptions          |      | - Lossless ALAC & AAC      |
| - Memory Reclamation Service         |      | - Apple TV 4K Aerial Video |
+--------------------------------------+      +----------------------------+
         |                                                 |
         v                                                 v
+--------------------------------------+      +----------------------------+
|         Network & Protocols          |      |    Android 14 Subsystem    |
| - mDNS / Bonjour Advertising         |      | - Safe User-0 Debloating   |
| - RAOP / RTSP AirPlay 2 Service      |      | - DreamService Integration |
| - SponsorBlock & Ad-Free Streams     |      | - Hardware Remote Remap    |
+--------------------------------------+      +----------------------------+
```

## System Components

### 1. The tvOS-Inspired Launcher (`com.gathin.tvhome`)
Built specifically for Android TV (Leanback API 34), replacing the bloated, ad-injected Google TV LauncherX (`com.google.android.apps.tv.launcherx`).
* **Zero Recommendations / Promoted Content:** Strips all algorithmic recommendation feeds, sponsored video carousels, and tracking hooks.
* **Dual Intent Discovery:** Dynamically resolves both `CATEGORY_LEANBACK_LAUNCHER` and standard mobile `CATEGORY_LAUNCHER`, guaranteeing every sideloaded APK shows up on the TV grid with appropriate icons or banners.
* **Ambient Lighting / Solar Wallpapers:** Day and night image switching reacting to sunrise and sunset cycles.
* **1-Click Memory Recovery:** Top-bar pill and remote hardware key listener executing Android's `ActivityManager.killBackgroundProcesses()` to terminate cached, empty background processes instantly.

### 2. Ad-Free YouTube Pipeline (`org.smarttube.stable`)
* Native Android TV media engine utilizing ExoPlayer with AV1/VP9 hardware acceleration.
* Client-side regex parsing bypassing Google Video ad-insertion payloads.
* Community-driven SponsorBlock integration automatically skipping non-music sponsorships, intros, and subscription nags.

### 3. Open-Source AirPlay 2 Engine (`io.github.jqssun.airplay`)
* Native C JNI bridge wrapping **UxPlay** on Android.
* Advertises `_raop._tcp` and `_airplay._tcp` on local mDNS port 5353 using Android `NsdManager`.
* Implements `SYSTEM_ALERT_WINDOW` and foreground service type `connectedDevice|mediaPlayback` to immediately present mirroring surfaces over any active TV task upon iPhone / Mac handshake.

### 4. Apple TV 4K Screensaver (`com.neilturner.aerialviews`)
* Android `DreamService` integration streaming public 4K HDR Apple ProRes/H.265 drone files from Apple's public CDNs.
* Managed via `screen_off_timeout` (90s / 1.5 min), waking up upon any standard remote key event.
