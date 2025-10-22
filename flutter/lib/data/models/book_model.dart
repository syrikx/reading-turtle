import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/book.dart';

part 'book_model.freezed.dart';

@freezed
class BookModel with _$BookModel {
  const BookModel._();

  const factory BookModel({
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
  }) = _BookModel;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    // Handle numeric fields that might come as different types
    double? parseBtLevel(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseQuiz(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return BookModel(
      isbn: json['isbn'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      series: json['series'] as String?,
      btLevel: parseBtLevel(json['bt_level']),
      lexile: json['lexile'] as String?,
      quiz: parseQuiz(json['quiz']),
      quizUrl: json['quiz_url'] as String?,
      vocab: json['vocab']?.toString(),
      imageUrl: json['image_url'] as String?,
      hasWords: json['has_words'] as bool?,
      status: json['status'] as String?,
    );
  }

  // Convert to domain entity
  Book toEntity() {
    return Book(
      isbn: isbn,
      title: title,
      author: author,
      series: series,
      btLevel: btLevel,
      lexile: lexile,
      quiz: quiz,
      quizUrl: quizUrl,
      vocab: vocab,
      imageUrl: imageUrl,
      hasWords: hasWords,
      status: status,
    );
  }

  // Create from domain entity
  factory BookModel.fromEntity(Book book) {
    return BookModel(
      isbn: book.isbn,
      title: book.title,
      author: book.author,
      series: book.series,
      btLevel: book.btLevel,
      lexile: book.lexile,
      quiz: book.quiz,
      quizUrl: book.quizUrl,
      vocab: book.vocab,
      imageUrl: book.imageUrl,
      hasWords: book.hasWords,
      status: book.status,
    );
  }
}
