# GitHub & CI/CD Setup Guide

## Step 1: Install Git on Your Local Machine

1. Download from: https://git-scm.com/download/win
2. Run the installer and complete installation
3. Open PowerShell and verify: `git --version`

## Step 2: Initialize Git Repository Locally

```powershell
cd D:\app
git init
git add .
git commit -m "Initial commit: Bike Rental Management App"
```

## Step 3: Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository named `bike-rental-app`
3. **DO NOT** initialize with README (we already have one)
4. Copy the repository URL

## Step 4: Push to GitHub

```powershell
cd D:\app
git remote add origin https://github.com/YOUR_USERNAME/bike-rental-app.git
git branch -M main
git push -u origin main
```

**Note:** Replace `YOUR_USERNAME` with your actual GitHub username.

---

## Option A: GitHub Actions (Recommended - Free)

### Setup Instructions:

1. Push code to GitHub (steps above)
2. Go to your GitHub repository
3. Click **Settings** → **Secrets and variables** → **Actions**
4. No secrets needed for basic build (APK artifacts stored automatically)
5. The workflow will run automatically on push to `main` or `develop` branch

### What it does:
- ✅ Runs on every push to `main` and `develop`
- ✅ Builds APK in release mode
- ✅ Runs tests and analysis
- ✅ Stores APK as artifact for 30 days
- ✅ Creates releases when you push tags (e.g., `v1.0.0`)

### View Workflow Status:
- Go to **Actions** tab in your GitHub repo
- See build logs and download APK artifacts

### To Create a Release:
```powershell
git tag v1.0.0
git push origin v1.0.0
```

---

## Option B: Codemagic (Free Alternative)

### Setup Instructions:

1. Go to https://codemagic.io
2. Sign in with GitHub
3. Click **Add application** and select your repository
4. Select Flutter project
5. Codemagic will auto-detect `codemagic.yaml`
6. Configure Android signing:
   - Go to **Build Settings** → **Android signing**
   - Upload your keystore file
   - Add keystore details

### What it does:
- ✅ Builds Android APK
- ✅ Optionally builds iOS app
- ✅ Email notifications on build completion
- ✅ Automatic artifact storage
- ✅ Free tier includes 500 build minutes/month

### View Build Status:
- Go to Codemagic dashboard
- See build history and download APKs

---

## File Structure After Push

```
bike-rental-app/
├── .github/
│   └── workflows/
│       └── build.yml              ← GitHub Actions config
├── .gitignore
├── codemagic.yaml                 ← Codemagic config
├── pubspec.yaml
├── README.md
├── DOCUMENTATION.md
├── ARCHITECTURE.md
├── lib/
│   ├── main.dart
│   ├── helpers/
│   │   └── db_helper.dart
│   ├── models/
│   │   ├── bike.dart
│   │   └── rental_record.dart
│   └── screens/
│       ├── main_dashboard.dart
│       ├── add_bike_screen.dart
│       ├── scan_and_cart_screen.dart
│       ├── proof_upload_screen.dart
│       ├── finalize_rental_screen.dart
│       ├── status_screen.dart
│       └── history_screen.dart
├── assets/
│   └── icon.png
└── android/
    ├── app/
    └── build.gradle
```

---

## Troubleshooting

### Git Not Found in PowerShell
```powershell
# Close and reopen PowerShell after installing Git
# Or add to PATH manually:
$env:PATH += ";C:\Program Files\Git\bin"
```

### Push Fails: "Authentication Failed"
```powershell
# Use GitHub Personal Access Token instead of password:
# 1. Go to https://github.com/settings/tokens
# 2. Create new token with 'repo' scope
# 3. Use token as password when pushing
git remote set-url origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/bike-rental-app.git
```

### Workflow Doesn't Run
- Check `.github/workflows/build.yml` exists
- Verify branch name is `main` (not `master`)
- Check Actions tab for errors

### Build Fails in CI/CD
- Check workflow logs in Actions tab
- Common issues:
  - `flutter pub get` failed → Check pubspec.yaml
  - `flutter analyze` failed → Check Dart syntax
  - APK path wrong → Verify build output location

---

## Download APK from CI/CD

### From GitHub Actions:
1. Go to **Actions** tab
2. Click latest workflow run
3. Scroll to **Artifacts**
4. Download `bike-rental-apk`

### From Codemagic:
1. Go to build details
2. Click **Build artifacts**
3. Download APK

---

## Next Steps

1. **Install Git**: https://git-scm.com/download/win
2. **Push code** using PowerShell commands above
3. **Verify workflow** runs in GitHub Actions or Codemagic
4. **Download APK** from artifacts after first build
5. **Test APK** on Android device or emulator

---

## Commands Reference

```powershell
# Initialize repo
git init
git add .
git commit -m "message"

# Add remote
git remote add origin https://github.com/USERNAME/bike-rental-app.git

# Push
git branch -M main
git push -u origin main

# Create release tag
git tag v1.0.0
git push origin v1.0.0

# Check status
git status
git log
```

---

Questions? Check GitHub Actions docs: https://docs.github.com/en/actions
