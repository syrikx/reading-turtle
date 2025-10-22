class ApiConfig {
  // Dynamic base URL detection
  // - If running on localhost: use http://localhost:8010
  // - If running on reading-turtle.com: use relative path (same origin)
  static String get baseUrl {
    // Check if we're running in web
    const isWeb = bool.fromEnvironment('dart.library.html', defaultValue: false);

    if (isWeb) {
      // In web, use relative URLs to avoid CORS issues
      // This works for both localhost:8080 and reading-turtle.com
      final hostname = Uri.base.host;

      if (hostname == 'localhost' || hostname == '127.0.0.1') {
        // Development: explicit localhost:8010
        return 'http://localhost:8010';
      } else {
        // Production: use same origin (nginx will proxy to backend)
        return '';  // Empty string means same origin
      }
    }

    // For mobile/desktop, use environment variable or default
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8010',
    );
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String signupEndpoint = '/api/auth/register';
  static const String searchBooksEndpoint = '/api/books/search';
  static const String wordStudyEndpoint = '/api/words/study';
  static const String wordToggleEndpoint = '/api/words/study/toggle';
  static const String quizGenerateEndpoint = '/api/quiz/generate';
  static const String readingHistoryEndpoint = '/api/reading-history';
}
