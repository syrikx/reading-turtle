import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:reading_turtle/core/utils/api_client.dart';
import 'package:reading_turtle/data/api/quiz_api_service.dart';

@GenerateMocks([ApiClient])
import 'quiz_api_test.mocks.dart';

void main() {
  late QuizApiService quizApiService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    quizApiService = QuizApiService(mockApiClient);
  });

  group('QuizApiService', () {
    test('should call correct API endpoint with /api/ prefix', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'book': {
            'isbn': '9781338832556',
            'title': 'Test Book',
            'author': 'Test Author',
            'bt_level': 4,
            'image_url': '/test.jpg',
          },
          'quizzes': [],
        },
      );

      when(mockApiClient.get('/api/books/9781338832556/quizzes'))
          .thenAnswer((_) async => mockResponse);

      // Act
      await quizApiService.getQuizzes('9781338832556');

      // Assert
      verify(mockApiClient.get('/api/books/9781338832556/quizzes')).called(1);
    });

    test('should parse quiz API response correctly', () async {
      // Arrange - Real API response format
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'book': {
            'isbn': '9781338832556',
            'title': 'The Shadow Returns',
            'author': 'Charman, Katrina',
            'series': 'Branches; Last Firehawk',
            'bt_level': 4,
            'lexile': null,
            'quiz': 1,
            'quiz_url': '/public_uploads/html5/quiz/1/index.html',
            'image_url': '/bookimg/9781338832556.jpg',
          },
          'quizzes': [
            {
              'question_id': 232601,
              'quiz_id': 33733,
              'question_number': 1,
              'question_text': 'What does Claw\'s reaction to Talia\'s words show?',
              'choice_1': 'He doesn\'t believe her.',
              'choice_2': 'He is confused.',
              'choice_3': 'He agrees with her.',
              'choice_4': 'He wants to leave.',
              'correct_answer': 'He agrees with her.',
              'correct_choice_number': 3,
            },
          ],
        },
      );

      when(mockApiClient.get('/api/books/9781338832556/quizzes'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await quizApiService.getQuizzes('9781338832556');

      // Assert
      expect(result.book.isbn, '9781338832556');
      expect(result.book.title, 'The Shadow Returns');
      expect(result.book.btLevel, 4.0);
      expect(result.quizzes.length, 1);
      expect(result.quizzes[0].questionId, 232601);
      expect(result.quizzes[0].questionNumber, 1);
      expect(result.quizzes[0].correctChoiceNumber, 3);
    });

    test('should handle int bt_level correctly', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'book': {
            'isbn': '123',
            'title': 'Test Book',
            'author': 'Test Author',
            'bt_level': 5, // int instead of double
            'image_url': '/test.jpg',
          },
          'quizzes': [],
        },
      );

      when(mockApiClient.get('/api/books/123/quizzes'))
          .thenAnswer((_) async => mockResponse);

      final result = await quizApiService.getQuizzes('123');

      expect(result.book.btLevel, 5.0);
    });

    test('should handle numeric fields as strings in quiz data', () async {
      // Some APIs might return numeric fields as strings
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'book': {
            'isbn': '123',
            'title': 'Test',
            'author': 'Test',
            'bt_level': 4,
            'image_url': '/test.jpg',
          },
          'quizzes': [
            {
              'question_id': '100',  // String instead of int
              'quiz_id': 200,
              'question_number': '1', // String instead of int
              'question_text': 'Test question?',
              'choice_1': 'A',
              'choice_2': 'B',
              'choice_3': 'C',
              'choice_4': 'D',
              'correct_answer': 'A',
              'correct_choice_number': '1', // String instead of int
            },
          ],
        },
      );

      when(mockApiClient.get('/api/books/123/quizzes'))
          .thenAnswer((_) async => mockResponse);

      final result = await quizApiService.getQuizzes('123');

      expect(result.quizzes[0].questionId, 100);
      expect(result.quizzes[0].questionNumber, 1);
      expect(result.quizzes[0].correctChoiceNumber, 1);
    });
  });
}
