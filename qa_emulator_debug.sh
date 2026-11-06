#!/usr/bin/env bash
set -u
adb install -r app/build/outputs/apk/debug/app-debug.apk || exit 1
adb shell pm grant com.pirateradio.w92lf android.permission.POST_NOTIFICATIONS || true
echo "=== Android activity launch ==="
adb shell am start -W -n com.pirateradio.w92lf/au.com.nightwaveradio.MainActivity || true
sleep 8
echo "=== App PID ==="
adb shell pidof com.pirateradio.w92lf || true
echo "=== UI smoke ==="
python3 scripts/smoke_emulator.py
result=$?
if [ "$result" -ne 0 ]; then
 echo "=== UI hierarchy ==="
 adb shell uiautomator dump /sdcard/window.xml || true
 adb shell cat /sdcard/window.xml | head -c 14000 || true
 echo ""
 echo "=== Android runtime errors ==="
 adb logcat -d -s AndroidRuntime:E ActivityManager:E ActivityTaskManager:E | tail -n 120 || true
 echo "=== Recent activity state ==="
 adb shell dumpsys activity activities | grep -E 'mResumedActivity|topResumed|mFocused|Hist #' | tail -n 40 || true
fi
exit "$result"
