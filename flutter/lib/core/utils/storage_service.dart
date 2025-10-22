import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Save string value
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  // Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Remove value
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
