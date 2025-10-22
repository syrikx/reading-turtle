import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/word.dart';

part 'word_state.freezed.dart';

@freezed
class WordState with _$WordState {
  const factory WordState({
    @Default(false) bool isLoading,
    @Default([]) List<Word> words,
    String? isbn,
    int? wordCount,
    String? error,
  }) = _WordState;
}
