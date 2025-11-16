import 'package:firebase_analytics/firebase_analytics.dart';

/// Google Analytics service for tracking events and page views
///
/// This service provides methods to track user interactions and page views
/// using Firebase Analytics which integrates with Google Analytics 4 (GA4).
/// Works across Web, Android, and iOS platforms.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  /// Initialize Firebase Analytics
  /// Call this after Firebase.initializeApp() in main.dart
  static void initialize() {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics!);

    // Enable debug mode for immediate event visibility in Firebase Console
    _analytics!.setAnalyticsCollectionEnabled(true);
  }

  /// Get the analytics observer for navigation tracking
  /// Use this with MaterialApp's navigatorObservers
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Get the Firebase Analytics instance
  FirebaseAnalytics? get analytics => _analytics;

  /// Check if Firebase Analytics is available
  bool get isAvailable => _analytics != null;

  /// Track a page view
  ///
  /// [screenName] - The name of the screen (e.g., 'home', 'quiz_screen')
  /// [screenClass] - Optional screen class name
  Future<void> trackPageView(String screenName, {String? screenClass}) async {
    if (!isAvailable) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      print('Error tracking page view: $e');
    }
  }

  /// Track a custom event
  ///
  /// [eventName] - Name of the event (e.g., 'login', 'quiz_completed')
  /// [parameters] - Optional event parameters (max 25 parameters)
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    if (!isAvailable) return;

    try {
      await _analytics!.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('Error tracking event: $e');
    }
  }

  /// Track user login
  ///
  /// [method] - Login method (e.g., 'email', 'google', 'kakao')
  Future<void> trackLogin(String method) async {
    try {
      await _analytics?.logLogin(loginMethod: method);
    } catch (e) {
      print('Error tracking login: $e');
    }
  }

  /// Track user signup
  ///
  /// [method] - Signup method (e.g., 'email', 'google', 'kakao')
  Future<void> trackSignUp(String method) async {
    try {
      await _analytics?.logSignUp(signUpMethod: method);
    } catch (e) {
      print('Error tracking sign up: $e');
    }
  }

  /// Track quiz start
  ///
  /// [quizType] - Type of quiz (e.g., 'word_study', 'reading_comprehension')
  /// [level] - Quiz difficulty level
  Future<void> trackQuizStart({String? quizType, String? level}) async {
    await trackEvent('quiz_start', parameters: {
      if (quizType != null) 'quiz_type': quizType,
      if (level != null) 'level': level,
    });
  }

  /// Track quiz completion
  ///
  /// [quizType] - Type of quiz
  /// [score] - User's score
  /// [totalQuestions] - Total number of questions
  Future<void> trackQuizComplete({
    String? quizType,
    int? score,
    int? totalQuestions,
  }) async {
    final parameters = <String, Object>{
      if (quizType != null) 'quiz_type': quizType,
      if (score != null) 'score': score,
      if (totalQuestions != null) 'total_questions': totalQuestions,
    };

    if (score != null && totalQuestions != null && totalQuestions > 0) {
      parameters['accuracy'] = ((score / totalQuestions) * 100).toInt();
    }

    await trackEvent('quiz_complete', parameters: parameters);
  }

  /// Track book search
  ///
  /// [searchTerm] - The search term used
  /// [resultsCount] - Number of results returned
  Future<void> trackBookSearch(String searchTerm, {int? resultsCount}) async {
    try {
      await _analytics?.logSearch(
        searchTerm: searchTerm,
        parameters: {
          'content_type': 'book',
          if (resultsCount != null) 'results_count': resultsCount,
        },
      );
    } catch (e) {
      print('Error tracking book search: $e');
    }
  }

  /// Track book view
  ///
  /// [bookId] - ID of the book
  /// [bookTitle] - Title of the book
  /// [isbn] - ISBN of the book
  Future<void> trackBookView(
    String bookId, {
    String? bookTitle,
    String? isbn,
  }) async {
    try {
      await _analytics?.logViewItem(
        currency: 'KRW',
        value: 0,
        items: [
          AnalyticsEventItem(
            itemId: bookId,
            itemName: bookTitle ?? bookId,
            itemCategory: 'book',
            quantity: 1,
          ),
        ],
        parameters: {
          if (isbn != null) 'isbn': isbn,
        },
      );
    } catch (e) {
      print('Error tracking book view: $e');
    }
  }

  /// Track reading session start
  ///
  /// [bookId] - ID of the book being read
  /// [bookTitle] - Title of the book
  Future<void> trackReadingStart(String bookId, {String? bookTitle}) async {
    await trackEvent('reading_start', parameters: {
      'book_id': bookId,
      if (bookTitle != null) 'book_title': bookTitle,
    });
  }

  /// Track reading session complete
  ///
  /// [bookId] - ID of the book read
  /// [durationMinutes] - Duration of reading session in minutes
  /// [bookTitle] - Title of the book
  Future<void> trackReadingComplete(
    String bookId, {
    int? durationMinutes,
    String? bookTitle,
  }) async {
    await trackEvent('reading_complete', parameters: {
      'book_id': bookId,
      if (bookTitle != null) 'book_title': bookTitle,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
    });
  }

  /// Track word study
  ///
  /// [wordId] - ID of the word studied
  /// [word] - The word being studied
  /// [level] - Difficulty level of the word
  Future<void> trackWordStudy(
    String wordId, {
    String? word,
    String? level,
  }) async {
    await trackEvent('word_study', parameters: {
      'word_id': wordId,
      if (word != null) 'word': word,
      if (level != null) 'level': level,
    });
  }

  /// Track support post creation
  Future<void> trackSupportPostCreate() async {
    await trackEvent('support_post_create');
  }

  /// Track support post view
  ///
  /// [postId] - ID of the support post
  Future<void> trackSupportPostView(String postId) async {
    await trackEvent('support_post_view', parameters: {
      'post_id': postId,
    });
  }

  /// Track support reply creation
  ///
  /// [postId] - ID of the parent post
  Future<void> trackSupportReplyCreate(String postId) async {
    await trackEvent('support_reply_create', parameters: {
      'post_id': postId,
    });
  }

  /// Set user ID (for authenticated users)
  ///
  /// [userId] - Unique user identifier
  /// Important: Do not use PII (email, name, etc.) as user ID
  Future<void> setUserId(String? userId) async {
    if (!isAvailable) return;

    try {
      await _analytics!.setUserId(id: userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  /// Set user properties
  ///
  /// [name] - Property name (e.g., 'user_level', 'subscription_type')
  /// [value] - Property value
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!isAvailable) return;

    try {
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (e) {
      print('Error setting user property: $e');
    }
  }

  /// Set default event parameters
  ///
  /// These parameters will be logged with every event
  /// [parameters] - Default parameters to set
  Future<void> setDefaultEventParameters(
    Map<String, Object> parameters,
  ) async {
    if (!isAvailable) return;

    try {
      await _analytics!.setDefaultEventParameters(parameters);
    } catch (e) {
      print('Error setting default event parameters: $e');
    }
  }

  /// Enable/disable analytics collection
  ///
  /// [enabled] - Whether to enable analytics collection
  /// Useful for implementing user privacy preferences
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    if (!isAvailable) return;

    try {
      await _analytics!.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      print('Error setting analytics collection enabled: $e');
    }
  }

  /// Reset analytics data
  ///
  /// Clears all analytics data for this app instance
  Future<void> resetAnalyticsData() async {
    if (!isAvailable) return;

    try {
      await _analytics!.resetAnalyticsData();
    } catch (e) {
      print('Error resetting analytics data: $e');
    }
  }

  /// Track tutorial begin
  Future<void> trackTutorialBegin() async {
    try {
      await _analytics?.logTutorialBegin();
    } catch (e) {
      print('Error tracking tutorial begin: $e');
    }
  }

  /// Track tutorial complete
  Future<void> trackTutorialComplete() async {
    try {
      await _analytics?.logTutorialComplete();
    } catch (e) {
      print('Error tracking tutorial complete: $e');
    }
  }

  /// Track level up
  ///
  /// [level] - The new level
  /// [character] - Optional character or category
  Future<void> trackLevelUp({required int level, String? character}) async {
    try {
      await _analytics?.logLevelUp(level: level, character: character);
    } catch (e) {
      print('Error tracking level up: $e');
    }
  }

  /// Track share event
  ///
  /// [contentType] - Type of content shared (e.g., 'book', 'quiz_result')
  /// [itemId] - ID of the shared item
  Future<void> trackShare({
    required String contentType,
    required String itemId,
  }) async {
    try {
      await _analytics?.logShare(
        contentType: contentType,
        itemId: itemId,
        method: 'share',
      );
    } catch (e) {
      print('Error tracking share: $e');
    }
  }
}
