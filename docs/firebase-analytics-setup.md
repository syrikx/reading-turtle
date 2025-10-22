# Firebase Analytics Setup Guide

This document provides comprehensive instructions for setting up Firebase Analytics in the Reading Turtle application. Firebase Analytics works across **Web, Android, and iOS platforms** and automatically integrates with Google Analytics 4.

## Table of Contents

1. [Overview](#overview)
2. [Creating Firebase Project](#creating-firebase-project)
3. [Web Configuration](#web-configuration)
4. [Android Configuration](#android-configuration)
5. [iOS Configuration](#ios-configuration)
6. [Flutter Application Setup](#flutter-application-setup)
7. [Testing Analytics](#testing-analytics)
8. [Event Tracking Usage](#event-tracking-usage)
9. [Troubleshooting](#troubleshooting)

---

## Overview

### What is Firebase Analytics?

Firebase Analytics is Google's free app measurement solution that provides insights on app usage and user engagement. It automatically integrates with Google Analytics 4 (GA4).

### Features

- **Cross-platform**: Works on Web, Android, and iOS with the same code
- **Automatic Integration**: Connects directly to Google Analytics 4
- **Rich Event Tracking**: Supports custom events and user properties
- **Real-time Dashboard**: View data in Firebase Console and Google Analytics
- **Free**: No cost for unlimited events and users

### Prerequisites

- Google account
- Reading Turtle Flutter project
- Internet connection

---

## Creating Firebase Project

### Step 1: Go to Firebase Console

1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Sign in with your Google account
3. Click **Add project** or **Create a project**

### Step 2: Configure Project

1. **Enter project name**: `reading-turtle` (or your preferred name)
2. Click **Continue**
3. **Google Analytics**: Enable Google Analytics for this project (recommended)
4. Click **Continue**
5. **Configure Google Analytics**:
   - Select or create a Google Analytics account
   - Choose analytics location (e.g., Republic of Korea)
   - Accept terms
6. Click **Create project**
7. Wait for project creation (takes about 30 seconds)
8. Click **Continue**

---

## Web Configuration

### Step 1: Add Web App to Firebase Project

1. In Firebase Console, select your project
2. Click the **Web icon** (</>) to add a web app
3. **Register app**:
   - App nickname: `Reading Turtle Web`
   - Check **"Also set up Firebase Hosting"** (optional)
4. Click **Register app**

### Step 2: Get Firebase Configuration

You'll see a screen with your Firebase configuration:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "reading-turtle.firebaseapp.com",
  projectId: "reading-turtle",
  storageBucket: "reading-turtle.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef123456",
  measurementId: "G-XXXXXXXXXX"
};
```

**Copy this configuration** - you'll need it in the next steps.

### Step 3: Update index.html

1. Open `flutter/web/index.html`
2. Find the Firebase configuration section (around line 40-60)
3. Replace the placeholder values with your actual Firebase config:

**Before:**
```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};
```

**After (example):**
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "reading-turtle.firebaseapp.com",
  projectId: "reading-turtle",
  storageBucket: "reading-turtle.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef123456",
  measurementId: "G-XXXXXXXXXX"
};
```

### Step 4: Update main.dart for Web

1. Open `flutter/lib/main.dart`
2. Find the Firebase initialization section (around line 14-25)
3. Replace with your Firebase config:

**Before:**
```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    measurementId: 'YOUR_MEASUREMENT_ID',
  ),
);
```

**After (example):**
```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:123456789012:web:abcdef123456',
    messagingSenderId: '123456789012',
    projectId: 'reading-turtle',
    storageBucket: 'reading-turtle.appspot.com',
    authDomain: 'reading-turtle.firebaseapp.com',
    measurementId: 'G-XXXXXXXXXX',
  ),
);
```

---

## Android Configuration

### Step 1: Add Android App to Firebase Project

1. In Firebase Console, click **Add app**
2. Select **Android** (robot icon)
3. **Register app**:
   - **Android package name**: `com.example.reading_turtle` (or your package name)
     - Find in `flutter/android/app/build.gradle` → `applicationId`
   - **App nickname**: `Reading Turtle Android` (optional)
   - **Debug signing certificate SHA-1**: (optional, for now)
4. Click **Register app**

### Step 2: Download google-services.json

1. Click **Download google-services.json**
2. Move the file to: `flutter/android/app/google-services.json`

```bash
# From your downloads folder
mv ~/Downloads/google-services.json /home/syrikx0/reading-turtle/flutter/android/app/
```

### Step 3: Update Android Gradle Files

**1. Project-level build.gradle** (`flutter/android/build.gradle`):

Add Google Services plugin:

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'  // Add this line
    }
}
```

**2. App-level build.gradle** (`flutter/android/app/build.gradle`):

Add at the bottom of the file:

```gradle
// At the very bottom
apply plugin: 'com.google.gms.google-services'
```

### Step 4: Update main.dart for Android

The Firebase initialization in `main.dart` should automatically work for Android if you've added `google-services.json`. No additional code needed!

---

## iOS Configuration

### Step 1: Add iOS App to Firebase Project

1. In Firebase Console, click **Add app**
2. Select **iOS** (Apple icon)
3. **Register app**:
   - **iOS bundle ID**: `com.example.readingTurtle` (or your bundle ID)
     - Find in `flutter/ios/Runner.xcodeproj/project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER`
   - **App nickname**: `Reading Turtle iOS` (optional)
   - **App Store ID**: (optional, leave blank for now)
4. Click **Register app**

### Step 2: Download GoogleService-Info.plist

1. Click **Download GoogleService-Info.plist**
2. Open Xcode:

```bash
cd /home/syrikx0/reading-turtle/flutter
open ios/Runner.xcworkspace
```

3. In Xcode, drag `GoogleService-Info.plist` into the Runner folder
4. Make sure **"Copy items if needed"** is checked
5. Make sure **Runner** target is selected

### Step 3: Update main.dart for iOS

The Firebase initialization in `main.dart` should automatically work for iOS if you've added `GoogleService-Info.plist`. No additional code needed!

---

## Flutter Application Setup

All platforms are now configured! The code in `main.dart` and `analytics_service.dart` works across Web, Android, and iOS.

### Rebuild the Application

```bash
cd /home/syrikx0/reading-turtle/flutter

# For Web
flutter build web --release

# For Android (requires Android SDK)
flutter build apk

# For iOS (requires macOS and Xcode)
flutter build ios
```

---

## Testing Analytics

### Web Testing

1. Run the Flutter web app:

```bash
cd /home/syrikx0/reading-turtle/flutter
flutter run -d chrome
# Or serve the built version
python3 -m http.server 8085 --bind 0.0.0.0
```

2. Open Firebase Console → Analytics → DebugView
3. Interact with the app (login, search books, take quiz)
4. You should see events appearing in DebugView in real-time

### Android Testing

1. Enable debug mode on your Android device:

```bash
adb shell setprop debug.firebase.analytics.app com.example.reading_turtle
```

2. Run the app on the device
3. Check Firebase Console → Analytics → DebugView
4. Interact with the app and see events

### iOS Testing

1. In Xcode, edit the scheme:
   - Product → Scheme → Edit Scheme
   - Select "Run"
   - Arguments tab → Add `-FIRAnalyticsDebugEnabled`
2. Run the app
3. Check Firebase Console → Analytics → DebugView

### Real-time Dashboard

1. Go to Firebase Console → Analytics → Realtime
2. See active users and events as they happen
3. After 24 hours, check Analytics → Events for historical data

---

## Event Tracking Usage

### Basic Usage

```dart
import 'package:reading_turtle/core/utils/analytics_service.dart';

final analytics = AnalyticsService();

// Track custom event
await analytics.trackEvent('button_clicked', parameters: {
  'button_name': 'start_quiz',
});
```

### Pre-built Event Methods

#### Authentication

```dart
// User login
await analytics.trackLogin('email');

// User signup
await analytics.trackSignUp('email');
```

#### Quiz Events

```dart
// Quiz start
await analytics.trackQuizStart(
  quizType: 'word_study',
  level: 'beginner',
);

// Quiz completion
await analytics.trackQuizComplete(
  quizType: 'word_study',
  score: 8,
  totalQuestions: 10,
);
```

#### Book Events

```dart
// Book search
await analytics.trackBookSearch('harry potter', resultsCount: 5);

// Book view
await analytics.trackBookView(
  '9780439708180',
  bookTitle: 'Harry Potter',
  isbn: '9780439708180',
);
```

#### Reading Sessions

```dart
// Start reading
await analytics.trackReadingStart('book_123', bookTitle: 'Sample Book');

// Complete reading
await analytics.trackReadingComplete(
  'book_123',
  durationMinutes: 30,
  bookTitle: 'Sample Book',
);
```

#### Word Study

```dart
await analytics.trackWordStudy(
  'word_456',
  word: 'ephemeral',
  level: 'advanced',
);
```

#### User Properties

```dart
// Set user ID (after login)
await analytics.setUserId('user_123');

// Set user properties
await analytics.setUserProperty(
  name: 'user_level',
  value: 'intermediate',
);

// Clear user ID (on logout)
await analytics.setUserId(null);
```

### Page View Tracking

Page views are automatically tracked when using GoRouter with the FirebaseAnalyticsObserver.

To manually track page views:

```dart
await analytics.trackPageView('quiz_screen', screenClass: 'QuizScreen');
```

---

## Troubleshooting

### Events Not Showing in Firebase Console

**Problem**: Events aren't appearing in Firebase Console

**Solutions**:
1. **Wait**: Events can take 1-3 hours to appear in standard reports
2. **Use DebugView**: For real-time testing, use DebugView (see Testing section)
3. **Check Configuration**: Verify Firebase config values are correct in both `index.html` and `main.dart`
4. **Check Internet**: Ensure device/browser has internet connection
5. **Check Logs**: Look for Firebase errors in Flutter logs

### Web: Firebase Not Initialized

**Problem**: Error message "Firebase has not been correctly initialized"

**Solutions**:
1. Verify `firebaseConfig` in `index.html` matches your project
2. Check browser console for JavaScript errors
3. Ensure Firebase SDK script is loading (check Network tab)
4. Clear browser cache and reload

### Android: Missing google-services.json

**Problem**: Build error about missing `google-services.json`

**Solutions**:
1. Download from Firebase Console
2. Place in `flutter/android/app/` directory
3. Ensure filename is exactly `google-services.json`
4. Run `flutter clean` and rebuild

### iOS: Missing GoogleService-Info.plist

**Problem**: Build error about missing `GoogleService-Info.plist`

**Solutions**:
1. Download from Firebase Console
2. Add to Xcode project (must use Xcode, not just copy file)
3. Verify it's in Runner folder and target is checked
4. Clean and rebuild

### Analytics Collection Disabled

**Problem**: Analytics not collecting data

**Solution**:
```dart
// Explicitly enable analytics collection
await analytics.setAnalyticsCollectionEnabled(true);
```

### Wrong Platform Configuration

**Problem**: Using web config for mobile or vice versa

**Solution**:
- Web: Configuration in `index.html` AND `main.dart`
- Android: Use `google-services.json` (no need to change `main.dart`)
- iOS: Use `GoogleService-Info.plist` (no need to change `main.dart`)

---

## Privacy Considerations

### GDPR Compliance

1. **User Consent**: Implement cookie/analytics consent banner for web
2. **Disable Collection**: Allow users to opt-out

```dart
// Disable analytics if user opts out
await analytics.setAnalyticsCollectionEnabled(false);
```

3. **Reset Data**: Clear analytics data on request

```dart
await analytics.resetAnalyticsData();
```

### Data Collection Best Practices

- **No PII**: Never track email, phone number, or real names
- **Use User IDs**: Use internal database IDs, not personal info
- **Anonymize**: Keep data anonymous and aggregated
- **Inform Users**: Clearly state what data you collect in privacy policy

---

## Comparison: Firebase vs. Direct GA4

| Feature | Firebase Analytics | Direct GA4 (gtag.js) |
|---------|-------------------|---------------------|
| **Platform Support** | Web, Android, iOS | Web only |
| **Setup Complexity** | Medium | Easy (web) |
| **Code Consistency** | Same code all platforms | Web-specific |
| **Google Analytics** | Auto-integrated | Manual setup |
| **Dashboard** | Firebase + GA4 | GA4 only |
| **Mobile Support** | Native | Requires WebView |
| **Recommended For** | Multi-platform apps | Web-only apps |

**For Reading Turtle**: Firebase Analytics is recommended because you plan to build Android and iOS apps in the future.

---

## Summary Checklist

### Web Setup
- [ ] Created Firebase project
- [ ] Added web app to Firebase
- [ ] Copied Firebase config to `index.html`
- [ ] Updated Firebase config in `main.dart`
- [ ] Tested in browser
- [ ] Verified events in Firebase DebugView

### Android Setup (Optional - for future)
- [ ] Added Android app to Firebase
- [ ] Downloaded `google-services.json`
- [ ] Placed file in `flutter/android/app/`
- [ ] Updated `android/build.gradle`
- [ ] Updated `android/app/build.gradle`
- [ ] Built and tested APK

### iOS Setup (Optional - for future)
- [ ] Added iOS app to Firebase
- [ ] Downloaded `GoogleService-Info.plist`
- [ ] Added file to Xcode project
- [ ] Built and tested on iOS device/simulator

---

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Analytics Events](https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event)
- [Google Analytics 4](https://support.google.com/analytics/answer/10089681)

---

## Support

For Firebase-specific issues:
- [Firebase Support](https://firebase.google.com/support)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)

For application-specific issues:
- Check application logs
- Review `analytics_service.dart` implementation
- Consult development team

---

**Document Version**: 1.0
**Last Updated**: 2025-10-22
**Author**: Reading Turtle Development Team
