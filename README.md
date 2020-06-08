# Philotic Handler [Mobile App]

## Build APKs
```bash
sudo sh ./bin/build.sh

# Install apk on mobile
adb -s 9224a6d8 install ./apks/app-arm64-v8a-release.apk

```

## Development
```bash
flutter emulators --launch Pixel_API_29
flutter run
```

**Notes**
- Use `r` to hotreload in the run terminal

## Debugging on Mobile
```bash
adb -s 9224a6d8 logcat | grep flutter
```
