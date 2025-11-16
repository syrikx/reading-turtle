/// App version information
/// Update this when deploying to production
class AppVersion {
  static const String version = '1.0.1';
  static const String buildNumber = '1';

  static String get fullVersion => 'v$version';
  static String get fullVersionWithBuild => 'v$version ($buildNumber)';
}
