# Philotic Handler [Mobile App]

## Build APKs
```bash
rm -rf apks
mkdir apks
sudo docker stop philotic-app-runner || true && sudo docker rm philotic-app-runner || true
sudo docker build -t philotic-app-builder .
sudo docker run --name philotic-app-runner philotic-app-builder:latest
sudo docker cp philotic-app-runner:/apps/philotic/build/app/outputs/apk/release/app-armeabi-v7a-release.apk ./apks/app-armeabi-v7a-release.apk
sudo docker cp philotic-app-runner:/apps/philotic/build/app/outputs/apk/release/app-arm64-v8a-release.apk ./apks/app-arm64-v8a-release.apk
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
# Install apk on mobile
adb -s 9224a6d8 install ./apks/app-arm64-v8a-release.apk

# Run logcat
adb -s 9224a6d8 logcat | grep flutter
```
