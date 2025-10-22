import 'package:flutter/material.dart';
import 'analytics_service.dart';

/// Route observer for tracking page views with Google Analytics
class AnalyticsRouteObserver extends NavigatorObserver {
  final AnalyticsService _analytics = AnalyticsService();

  /// Get page name from route settings
  String _getPageName(Route<dynamic>? route) {
    if (route == null || route.settings.name == null) {
      return 'unknown';
    }
    return route.settings.name!;
  }

  /// Get page title from route settings or name
  String? _getPageTitle(Route<dynamic>? route) {
    if (route == null) return null;

    // Try to get title from route settings arguments
    final arguments = route.settings.arguments;
    if (arguments is Map && arguments.containsKey('title')) {
      return arguments['title'] as String?;
    }

    return null;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    final pageName = _getPageName(route);
    final pageTitle = _getPageTitle(route);

    _analytics.trackPageView(pageName, pageTitle: pageTitle);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    if (previousRoute != null) {
      final pageName = _getPageName(previousRoute);
      final pageTitle = _getPageTitle(previousRoute);

      _analytics.trackPageView(pageName, pageTitle: pageTitle);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    if (newRoute != null) {
      final pageName = _getPageName(newRoute);
      final pageTitle = _getPageTitle(newRoute);

      _analytics.trackPageView(pageName, pageTitle: pageTitle);
    }
  }
}
