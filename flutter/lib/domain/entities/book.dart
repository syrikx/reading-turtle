import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';

@freezed
class Book with _$Book {
  const factory Book({
    required String isbn,
    required String title,
    required String author,
    String? series,
    double? btLevel,
    String? lexile,
    int? quiz,
    String? quizUrl,
    String? vocab,
    String? imageUrl,
    bool? hasWords,
    String? status, // started, reading, completed
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      isbn: json['isbn'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      series: json['series'] as String?,
      btLevel: json['btLevel'] as double?,
      lexile: json['lexile'] as String?,
      quiz: json['quiz'] as int?,
      quizUrl: json['quizUrl'] as String?,
      vocab: json['vocab'] as String?,
      imageUrl: json['imageUrl'] as String?,
      hasWords: json['hasWords'] as bool?,
      status: json['status'] as String?,
    );
  }
}
