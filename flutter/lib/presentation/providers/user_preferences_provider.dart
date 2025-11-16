import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preference for book level display type
enum LevelDisplayType {
  btLevel,  // Display Level as "Lv."
  lexile,   // Display Lexile
}

/// State for user preferences
class UserPreferences {
  final LevelDisplayType levelDisplayType;

  const UserPreferences({
    this.levelDisplayType = LevelDisplayType.btLevel,
  });

  UserPreferences copyWith({
    LevelDisplayType? levelDisplayType,
  }) {
    return UserPreferences(
      levelDisplayType: levelDisplayType ?? this.levelDisplayType,
    );
  }
}

/// Provider for user preferences
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  static const String _keyLevelDisplayType = 'level_display_type';

  UserPreferencesNotifier() : super(const UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final levelTypeString = prefs.getString(_keyLevelDisplayType);

    if (levelTypeString != null) {
      final levelType = levelTypeString == 'lexile'
          ? LevelDisplayType.lexile
          : LevelDisplayType.btLevel;
      state = state.copyWith(levelDisplayType: levelType);
    }
  }

  Future<void> setLevelDisplayType(LevelDisplayType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyLevelDisplayType,
      type == LevelDisplayType.lexile ? 'lexile' : 'bt_level',
    );
    state = state.copyWith(levelDisplayType: type);
  }
}

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});
