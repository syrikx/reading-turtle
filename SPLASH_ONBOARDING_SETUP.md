# Splash Screen & Onboarding Tutorial Setup Guide

**Date**: 2025-10-24
**Features Added**: 3-second splash screen, Multi-step onboarding tutorial

---

## ✅ Implemented Features

### 1. Splash Screen (3 seconds)
- **Location**: `flutter/lib/presentation/screens/splash/splash_screen.dart`
- **Duration**: 3 seconds with fade-in and scale animations
- **Design**:
  - Circular green logo with book icon
  - "Reading Turtle" title
  - "영어 독서 학습 플랫폼" subtitle
  - Loading spinner

### 2. Onboarding Tutorial (5 steps)
- **Location**: `flutter/lib/presentation/screens/onboarding/onboarding_screen.dart`
- **Features**:
  - Multi-page tutorial (swipeable)
  - "Skip" button (top-right)
  - Page indicators (dots)
  - "Next" / "Start" button

**Tutorial Pages**:
1. **Book Search** (Blue)
   - Icon: Search
   - Description: 121,000+ books with level/genre filters

2. **Quiz** (Orange)
   - Icon: Quiz
   - Description: Comprehension quizzes for books

3. **Word Study** (Purple)
   - Icon: Book
   - Description: Learn and bookmark important words

4. **Reading Calendar** (Green)
   - Icon: Calendar
   - Description: Track daily reading progress

5. **Customer Support** (Teal)
   - Icon: Support Agent
   - Description: Help desk for questions

### 3. App Initialization Flow
- **Location**: `flutter/lib/presentation/screens/app_wrapper.dart`
- **Logic**:
  1. Show splash screen (3 seconds)
  2. Check if user has seen onboarding (`has_seen_onboarding` in SharedPreferences)
  3. If first-time user → Show onboarding
  4. If returning user → Go directly to app

### 4. State Management
- **Storage Key**: Added `hasSeenOnboarding` to `StorageKeys`
- **Provider**: `appInitializationProvider` in `app_wrapper.dart`
- **Persistence**: Uses SharedPreferences via StorageService

---

## 📁 Files Modified/Created

### New Files
```
flutter/lib/presentation/screens/splash/splash_screen.dart
flutter/lib/presentation/screens/onboarding/onboarding_screen.dart
flutter/lib/presentation/screens/app_wrapper.dart
```

### Modified Files
```
flutter/lib/main.dart
  - Added AppWrapper integration
  - Imports splash/onboarding screens

flutter/lib/core/constants/storage_keys.dart
  - Added hasSeenOnboarding key

flutter/lib/core/config/router_config.dart
  - Added /splash and /onboarding routes
  - Imported splash/onboarding screens
```

---

## 🎨 Customization Guide

### Change Splash Screen Duration

Edit `flutter/lib/presentation/screens/app_wrapper.dart`:

```dart
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Change this duration (currently 3 seconds)
  await Future.delayed(const Duration(seconds: 3));

  // ... rest of code
});
```

### Modify Onboarding Pages

Edit `flutter/lib/presentation/screens/onboarding/onboarding_screen.dart`:

```dart
final List<OnboardingPage> _pages = [
  OnboardingPage(
    icon: Icons.your_icon,      // Change icon
    title: 'Your Title',         // Change title
    description: 'Your text',    // Change description
    color: Colors.blue,          // Change color
  ),
  // Add more pages...
];
```

### Reset Onboarding (for testing)

To see the onboarding again:

**Option 1: Clear SharedPreferences (Dev Tools)**
- Open browser DevTools > Application > Storage > Clear site data

**Option 2: Programmatically**
```dart
await StorageService.remove(StorageKeys.hasSeenOnboarding);
```

---

## 🖼️ Favicon Change Guide

Currently, the favicon is a default Flutter icon. To replace it with a "turtle reading a book" icon:

### Method 1: Using Online Tools

1. **Create Icon with AI/Design Tool**:
   - Use tools like:
     - [DALL-E](https://openai.com/dall-e-2)
     - [Midjourney](https://www.midjourney.com)
     - [Canva](https://www.canva.com)
     - [Figma](https://www.figma.com)
   - Generate: "cute green turtle reading a book, simple icon, flat design"

2. **Convert to Required Sizes**:
   - Use [favicon.io](https://favicon.io) or [realfavicongenerator.net](https://realfavicongenerator.net)
   - Generate multiple sizes:
     - `favicon.png` (32x32 or 64x64)
     - `Icon-192.png` (192x192)
     - `Icon-512.png` (512x512)
     - `Icon-maskable-192.png` (192x192 with padding)
     - `Icon-maskable-512.png` (512x512 with padding)

3. **Replace Files**:
   ```bash
   # Replace these files:
   /home/syrikx0/reading-turtle-v2/flutter/web/favicon.png
   /home/syrikx0/reading-turtle-v2/flutter/web/icons/Icon-192.png
   /home/syrikx0/reading-turtle-v2/flutter/web/icons/Icon-512.png
   /home/syrikx0/reading-turtle-v2/flutter/web/icons/Icon-maskable-192.png
   /home/syrikx0/reading-turtle-v2/flutter/web/icons/Icon-maskable-512.png
   ```

4. **Rebuild App**:
   ```bash
   cd /home/syrikx0/reading-turtle-v2/flutter
   flutter build web --release
   ```

### Method 2: Using Flutter Assets

You can also update the splash screen icon programmatically:

Edit `flutter/lib/presentation/screens/splash/splash_screen.dart`:

```dart
// Replace the Container with an Image widget
Image.asset(
  'assets/images/turtle_reading.png',
  width: 120,
  height: 120,
),
```

Don't forget to add the asset in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/turtle_reading.png
```

---

## 🧪 Testing

### Test Splash Screen
1. Clear browser cache
2. Refresh app at `https://v2.reading-turtle.com`
3. Should see splash screen for 3 seconds

### Test Onboarding (First-time user)
1. Clear SharedPreferences (browser DevTools)
2. Refresh app
3. After splash, should see onboarding tutorial
4. Swipe through 5 pages or click "Next"
5. Click "Start" on last page

### Test Skip Functionality
1. Clear SharedPreferences
2. Refresh app
3. Click "Skip" button (top-right)
4. Should go directly to home screen

### Test Returning User
1. Complete onboarding once
2. Refresh app
3. Should skip onboarding and go directly to home

---

## 🚀 Deployment

After building, restart the server:

```bash
# Kill existing server
pkill -f "python3.*8090"

# Start new server
cd /home/syrikx0/reading-turtle-v2/flutter/build/web
python3 -m http.server 8090 --bind 0.0.0.0 &
```

Or rebuild and restart automatically:

```bash
cd /home/syrikx0/reading-turtle-v2/flutter
flutter build web --release
pkill -f "python3.*8090"
cd build/web && python3 -m http.server 8090 --bind 0.0.0.0 &
```

---

## 📱 User Flow Diagram

```
App Start
    ↓
Splash Screen (3 sec)
    ↓
Check hasSeenOnboarding?
    ├─ No → Onboarding Tutorial (5 pages)
    │         ↓
    │       Mark as seen
    │         ↓
    │       Home Screen
    └─ Yes → Home Screen
```

---

## 🔧 Troubleshooting

### Onboarding shows every time
- Check if SharedPreferences is being cleared
- Verify `StorageService.setBool()` is called after completing onboarding

### Splash screen too fast/slow
- Adjust duration in `app_wrapper.dart`
- Current: `Duration(seconds: 3)`

### Onboarding layout issues
- Check viewport sizes in onboarding_screen.dart
- Adjust padding/font sizes for responsiveness

### Navigation error after onboarding
- Verify router configuration includes home route (`/`)
- Check `context.go('/')` in onboarding completion

---

## 🎯 Future Enhancements

1. **Animated Favicon**:
   - Use animated GIF or CSS animation
   - Show turtle "reading" with page-turning animation

2. **Interactive Tutorial**:
   - Add clickable hotspots
   - Highlight actual UI elements

3. **Progress Tracking**:
   - Show tutorial progress (e.g., "Step 2 of 5")
   - Save which steps user has seen

4. **Localization**:
   - Add English translations
   - Support multiple languages

5. **Video Tutorial**:
   - Embed short video clips
   - Show actual feature usage

---

## 📋 Checklist

- [x] 3-second splash screen with animations
- [x] 5-step onboarding tutorial
- [x] Page indicators and navigation
- [x] Skip button functionality
- [x] SharedPreferences persistence
- [x] Router integration
- [ ] Custom favicon with turtle reading book
- [ ] Test on mobile devices
- [ ] Add accessibility labels

---

## 📞 Support

For questions or issues:
1. Check browser console for errors
2. Verify SharedPreferences storage
3. Test with cleared cache
4. Review router navigation logs

**Last Updated**: 2025-10-24
