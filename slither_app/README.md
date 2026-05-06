# 🐍 Slither.io Android App

Play Slither.io with **Mobile** and **Desktop** mode toggle!

## 📱 Features
- Full Slither.io gameplay
- Switch between **Mobile** and **Desktop** mode
- Reload button
- Dark themed UI

## 🚀 Get APK from GitHub

### Step 1 — Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/slither-app.git
git push -u origin main
```

### Step 2 — Get APK
- Go to your repo → **Actions** tab
- Wait for build to finish (~5 min)
- Go to **Releases** → download `app-release.apk`

OR go to **Actions** → click the latest run → **Artifacts** → download `slither-apk`

## 🛠 Local Build (optional)
Requires Flutter SDK installed:
```bash
flutter pub get
flutter build apk --release
# APK at: build/app/outputs/flutter-apk/app-release.apk
```

## 📋 Requirements
- Android 5.0+ (API 21+)
- Internet connection
