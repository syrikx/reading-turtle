import 'dart:js' as js;

/// Google Analytics service for tracking events and page views
///
/// This service provides methods to track user interactions and page views
/// using Google Analytics 4 (GA4) via the gtag.js library loaded in index.html
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  /// Check if Google Analytics is available
  bool get isAvailable {
    try {
      return js.context.hasProperty('gtag');
    } catch (e) {
      return false;
    }
  }

  /// Track a page view
  ///
  /// [pagePath] - The path of the page (e.g., '/home', '/quiz')
  /// [pageTitle] - Optional title of the page
  void trackPageView(String pagePath, {String? pageTitle}) {
    if (!isAvailable) return;

    try {
      js.context.callMethod('gtag', [
        'event',
        'page_view',
        js.JsObject.jsify({
          'page_path': pagePath,
          if (pageTitle != null) 'page_title': pageTitle,
        })
      ]);
    } catch (e) {
      print('Error tracking page view: $e');
    }
  }

  /// Track a custom event
  ///
  /// [eventName] - Name of the event (e.g., 'login', 'quiz_completed')
  /// [parameters] - Optional event parameters
  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (!isAvailable) return;

    try {
      js.context.callMethod('gtag', [
        'event',
        eventName,
        if (parameters != null) js.JsObject.jsify(parameters),
      ]);
    } catch (e) {
      print('Error tracking event: $e');
    }
  }

  /// Track user login
  ///
  /// [method] - Login method (e.g., 'email', 'google', 'kakao')
  void trackLogin(String method) {
    trackEvent('login', parameters: {'method': method});
  }

  /// Track user signup
  ///
  /// [method] - Signup method (e.g., 'email', 'google', 'kakao')
  void trackSignUp(String method) {
    trackEvent('sign_up', parameters: {'method': method});
  }

  /// Track quiz start
  ///
  /// [quizType] - Type of quiz (e.g., 'word_study', 'reading_comprehension')
  /// [level] - Quiz difficulty level
  void trackQuizStart({String? quizType, String? level}) {
    trackEvent('quiz_start', parameters: {
      if (quizType != null) 'quiz_type': quizType,
      if (level != null) 'level': level,
    });
  }

  /// Track quiz completion
  ///
  /// [quizType] - Type of quiz
  /// [score] - User's score
  /// [totalQuestions] - Total number of questions
  void trackQuizComplete({
    String? quizType,
    int? score,
    int? totalQuestions,
  }) {
    trackEvent('quiz_complete', parameters: {
      if (quizType != null) 'quiz_type': quizType,
      if (score != null) 'score': score,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (score != null && totalQuestions != null)
        'accuracy': ((score / totalQuestions) * 100).toStringAsFixed(1),
    });
  }

  /// Track book search
  ///
  /// [searchTerm] - The search term used
  /// [resultsCount] - Number of results returned
  void trackBookSearch(String searchTerm, {int? resultsCount}) {
    trackEvent('search', parameters: {
      'search_term': searchTerm,
      if (resultsCount != null) 'results_count': resultsCount,
    });
  }

  /// Track book view
  ///
  /// [bookId] - ID of the book
  /// [bookTitle] - Title of the book
  void trackBookView(String bookId, {String? bookTitle}) {
    trackEvent('view_item', parameters: {
      'item_id': bookId,
      if (bookTitle != null) 'item_name': bookTitle,
      'item_category': 'book',
    });
  }

  /// Track reading session start
  ///
  /// [bookId] - ID of the book being read
  void trackReadingStart(String bookId) {
    trackEvent('reading_start', parameters: {
      'book_id': bookId,
    });
  }

  /// Track reading session complete
  ///
  /// [bookId] - ID of the book read
  /// [durationMinutes] - Duration of reading session in minutes
  void trackReadingComplete(String bookId, {int? durationMinutes}) {
    trackEvent('reading_complete', parameters: {
      'book_id': bookId,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
    });
  }

  /// Track word study
  ///
  /// [wordId] - ID of the word studied
  /// [word] - The word being studied
  void trackWordStudy(String wordId, {String? word}) {
    trackEvent('word_study', parameters: {
      'word_id': wordId,
      if (word != null) 'word': word,
    });
  }

  /// Track support post creation
  void trackSupportPostCreate() {
    trackEvent('support_post_create');
  }

  /// Track support post view
  ///
  /// [postId] - ID of the support post
  void trackSupportPostView(String postId) {
    trackEvent('support_post_view', parameters: {
      'post_id': postId,
    });
  }

  /// Set user ID (for authenticated users)
  ///
  /// [userId] - Unique user identifier
  void setUserId(String? userId) {
    if (!isAvailable || userId == null) return;

    try {
      js.context.callMethod('gtag', [
        'config',
        'GA_MEASUREMENT_ID',
        js.JsObject.jsify({
          'user_id': userId,
        })
      ]);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  /// Set user properties
  ///
  /// [properties] - User properties to set
  void setUserProperties(Map<String, dynamic> properties) {
    if (!isAvailable) return;

    try {
      js.context.callMethod('gtag', [
        'set',
        'user_properties',
        js.JsObject.jsify(properties),
      ]);
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }
}
