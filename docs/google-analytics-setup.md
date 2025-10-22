# Google Analytics Setup Guide

This document provides step-by-step instructions for setting up and using Google Analytics 4 (GA4) in the Reading Turtle application.

## Table of Contents

1. [Creating Google Analytics Account](#creating-google-analytics-account)
2. [Getting Measurement ID](#getting-measurement-id)
3. [Configuring the Application](#configuring-the-application)
4. [Event Tracking Usage](#event-tracking-usage)
5. [Available Events](#available-events)
6. [Testing Analytics](#testing-analytics)

---

## Creating Google Analytics Account

### Step 1: Sign Up for Google Analytics

1. Go to [Google Analytics](https://analytics.google.com/)
2. Click **Start measuring** or **Sign in** if you already have a Google account
3. Follow the prompts to create a new Google Analytics account

### Step 2: Create a Property

1. After creating an account, you'll be prompted to create a **Property**
2. Enter property details:
   - **Property name**: Reading Turtle
   - **Reporting time zone**: Select your timezone (e.g., Korea Standard Time)
   - **Currency**: Select your currency (e.g., South Korean Won)
3. Click **Next**

### Step 3: Configure Business Information

1. Select your industry category (Education)
2. Select business size
3. Choose how you intend to use Google Analytics
4. Click **Create**

### Step 4: Accept Terms of Service

1. Select your country (Republic of Korea)
2. Read and accept the Google Analytics Terms of Service
3. Click **I Accept**

---

## Getting Measurement ID

### Step 1: Set Up Data Stream

1. After creating the property, you'll be prompted to set up a data stream
2. Select **Web** as the platform
3. Enter your website details:
   - **Website URL**: `https://reading-turtle.com` (or your actual domain)
   - **Stream name**: Reading Turtle Web App
4. Enable **Enhanced measurement** (recommended)
5. Click **Create stream**

### Step 2: Find Your Measurement ID

1. After creating the stream, you'll see your **Measurement ID**
2. It will look like: `G-XXXXXXXXXX`
3. **Copy this Measurement ID** - you'll need it for configuration

---

## Configuring the Application

### Step 1: Update index.html

1. Open the file: `flutter/web/index.html`
2. Find the Google Analytics script section (around line 37-47)
3. Replace **all occurrences** of `GA_MEASUREMENT_ID` with your actual Measurement ID

**Before:**
```html
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID', {
    'page_title': document.title,
    'page_location': window.location.href,
    'page_path': window.location.pathname
  });
</script>
```

**After (example with G-ABC123DEF4):**
```html
<script async src="https://www.googletagmanager.com/gtag/js?id=G-ABC123DEF4"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-ABC123DEF4', {
    'page_title': document.title,
    'page_location': window.location.href,
    'page_path': window.location.pathname
  });
</script>
```

### Step 2: Update analytics_service.dart

1. Open the file: `flutter/lib/core/utils/analytics_service.dart`
2. Find the `setUserId` method (around line 193)
3. Replace `GA_MEASUREMENT_ID` with your actual Measurement ID

**Before:**
```dart
js.context.callMethod('gtag', [
  'config',
  'GA_MEASUREMENT_ID',
  js.JsObject.jsify({
    'user_id': userId,
  })
]);
```

**After (example):**
```dart
js.context.callMethod('gtag', [
  'config',
  'G-ABC123DEF4',
  js.JsObject.jsify({
    'user_id': userId,
  })
]);
```

### Step 3: Rebuild the Application

```bash
cd /home/syrikx0/reading-turtle/flutter
flutter build web --release
```

### Step 4: Restart the Web Server

```bash
# If using Python server
cd /home/syrikx0/reading-turtle/flutter/build/web
python3 -m http.server 8085 --bind 0.0.0.0

# Or if using Flutter run
cd /home/syrikx0/reading-turtle/flutter
flutter run -d web-server --web-port=8085 --web-hostname=0.0.0.0
```

---

## Event Tracking Usage

### Basic Usage

Import the analytics service in any Dart file:

```dart
import 'package:reading_turtle/core/utils/analytics_service.dart';

final analytics = AnalyticsService();
```

### Example: Track User Login

```dart
// In login_screen.dart or auth_provider.dart
void handleLoginSuccess(String method) {
  analytics.trackLogin(method); // method: 'email', 'google', 'kakao', etc.
}
```

### Example: Track Quiz Completion

```dart
// In quiz_screen.dart or quiz_provider.dart
void handleQuizComplete(int score, int total) {
  analytics.trackQuizComplete(
    quizType: 'word_study',
    score: score,
    totalQuestions: total,
  );
}
```

### Example: Track Book Search

```dart
// In search_screen.dart
void handleSearch(String query, List results) {
  analytics.trackBookSearch(query, resultsCount: results.length);
}
```

### Example: Set User ID (after login)

```dart
// In auth_provider.dart
void handleLoginSuccess(User user) {
  analytics.setUserId(user.userId.toString());
}

// On logout
void handleLogout() {
  analytics.setUserId(null);
}
```

---

## Available Events

### Authentication Events

| Method | Event Name | Parameters |
|--------|------------|------------|
| `trackLogin(method)` | `login` | `method` |
| `trackSignUp(method)` | `sign_up` | `method` |

### Quiz Events

| Method | Event Name | Parameters |
|--------|------------|------------|
| `trackQuizStart(quizType, level)` | `quiz_start` | `quiz_type`, `level` |
| `trackQuizComplete(quizType, score, totalQuestions)` | `quiz_complete` | `quiz_type`, `score`, `total_questions`, `accuracy` |

### Book Events

| Method | Event Name | Parameters |
|--------|------------|------------|
| `trackBookSearch(searchTerm, resultsCount)` | `search` | `search_term`, `results_count` |
| `trackBookView(bookId, bookTitle)` | `view_item` | `item_id`, `item_name`, `item_category` |

### Reading Session Events

| Method | Event Name | Parameters |
|--------|------------|------------|
| `trackReadingStart(bookId)` | `reading_start` | `book_id` |
| `trackReadingComplete(bookId, durationMinutes)` | `reading_complete` | `book_id`, `duration_minutes` |

### Word Study Events

| Method | Event Name | Parameters |
|--------|------------|------------|
| `trackWordStudy(wordId, word)` | `word_study` | `word_id`, `word` |

### Support Board Events

| Method | Event Name | Parameters |
|--------|------------|------------|
| `trackSupportPostCreate()` | `support_post_create` | - |
| `trackSupportPostView(postId)` | `support_post_view` | `post_id` |

### Page View Tracking

| Method | Event Name | Parameters |
|--------|------------|------------|
| `trackPageView(pagePath, pageTitle)` | `page_view` | `page_path`, `page_title` |

### Custom Events

For any custom event not covered above:

```dart
analytics.trackEvent('custom_event_name', parameters: {
  'param1': 'value1',
  'param2': 123,
  'param3': true,
});
```

---

## Testing Analytics

### Real-time Testing

1. Go to [Google Analytics](https://analytics.google.com/)
2. Select your property (Reading Turtle)
3. Navigate to **Reports** > **Realtime**
4. Open your application in a browser
5. Interact with the app (login, search, take quiz, etc.)
6. You should see events appearing in real-time in the Google Analytics dashboard

### Debug View (Optional)

For more detailed debugging, enable debug mode:

1. Install the [Google Analytics Debugger Chrome Extension](https://chrome.google.com/webstore/detail/google-analytics-debugger/jnkmfdileelhofjcijamephohjechhna)
2. Enable the extension
3. Open Chrome DevTools (F12)
4. Go to the Console tab
5. Interact with your app
6. You'll see detailed GA events logged in the console

### Verify Data Collection

After 24-48 hours of data collection:

1. Go to **Reports** > **Engagement** > **Events**
2. You should see all your custom events listed
3. Click on any event to see detailed parameters and user behavior

---

## Best Practices

### 1. Event Naming Convention

- Use lowercase with underscores: `quiz_complete`, `reading_start`
- Be descriptive but concise
- Follow Google's recommended events when possible

### 2. Parameter Naming

- Use lowercase with underscores: `quiz_type`, `book_id`
- Avoid using PII (Personally Identifiable Information) like email addresses or names
- Keep parameter values consistent (e.g., always use same format for dates)

### 3. User Privacy

- **Never track sensitive information** (passwords, credit card numbers, etc.)
- For user IDs, use internal database IDs, not email addresses or usernames
- Consider GDPR and local privacy regulations
- Implement cookie consent if required

### 4. Performance

- Analytics calls are already optimized to not block UI
- The service checks if GA is available before making calls
- Failed tracking calls are silently caught and logged to console

---

## Troubleshooting

### Events Not Showing in GA Dashboard

1. **Check Measurement ID**: Verify the ID in `index.html` and `analytics_service.dart` is correct
2. **Wait for Processing**: Real-time events appear within seconds, but reports can take 24-48 hours
3. **Check Browser Console**: Look for any JavaScript errors related to gtag
4. **Ad Blockers**: Disable ad blockers and privacy extensions that might block GA

### Analytics Service Not Available

If `analytics.isAvailable` returns false:

1. Check that the GA script is loaded in `index.html`
2. Verify the script URL is correct
3. Check browser console for script loading errors
4. Ensure the app is running on a web browser (not desktop/mobile Flutter)

### User ID Not Set

If user tracking isn't working:

1. Verify `setUserId()` is called after successful login
2. Check that the Measurement ID is correct in the `setUserId` method
3. Enable user-ID feature in GA property settings if needed

---

## Support

For Google Analytics support:
- [Google Analytics Help Center](https://support.google.com/analytics)
- [GA4 Documentation](https://developers.google.com/analytics/devguides/collection/ga4)

For application-specific analytics issues:
- Check application logs
- Review `analytics_service.dart` implementation
- Consult development team

---

## Summary Checklist

- [ ] Created Google Analytics account
- [ ] Created property for Reading Turtle
- [ ] Set up web data stream
- [ ] Copied Measurement ID
- [ ] Updated `flutter/web/index.html` with Measurement ID
- [ ] Updated `analytics_service.dart` with Measurement ID
- [ ] Rebuilt Flutter web app
- [ ] Restarted web server
- [ ] Tested events in GA Real-time dashboard
- [ ] Verified events are being collected

---

**Document Version**: 1.0
**Last Updated**: 2025-10-22
**Author**: Reading Turtle Development Team
