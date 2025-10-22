import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:reading_turtle/core/utils/api_client.dart';
import 'package:reading_turtle/data/api/word_api_service.dart';

@GenerateMocks([ApiClient])
import 'word_api_test.mocks.dart';

void main() {
  late WordApiService wordApiService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    wordApiService = WordApiService(mockApiClient);
  });

  group('WordApiService', () {
    test('should call correct API endpoint with /api/ prefix', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'data': {
            'isbn': '9781338832556',
            'word_count': 0,
            'words': [],
          },
        },
      );

      when(mockApiClient.get('/api/books/9781338832556/words'))
          .thenAnswer((_) async => mockResponse);

      // Act
      await wordApiService.getWords('9781338832556');

      // Assert - 반드시 /api/ prefix 포함되어야 함
      verify(mockApiClient.get('/api/books/9781338832556/words')).called(1);
    });

    test('should parse word API response correctly', () async {
      // Arrange - Real API response format
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'data': {
            'isbn': '9781338832556',
            'word_count': 2,
            'words': [
              {
                'word': 'example',
                'word_order': 1,
                'word_id': 123,
                'definition': 'a thing characteristic of its kind',
                'example_sentence': 'This is an example sentence.',
                'min_bt_level': 3,
                'min_lexile': 500,
              },
              {
                'word': 'test',
                'word_order': 2,
                'word_id': 124,
                'definition': 'a procedure to establish quality',
                'example_sentence': 'We need to test this code.',
                'min_bt_level': 2,
                'min_lexile': 400,
              },
            ],
          },
        },
      );

      when(mockApiClient.get('/api/books/9781338832556/words'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await wordApiService.getWords('9781338832556');

      // Assert
      expect(result.isbn, '9781338832556');
      expect(result.wordCount, 2);
      expect(result.words.length, 2);
      expect(result.words[0].word, 'example');
      expect(result.words[0].wordId, 123);
      expect(result.words[0].definition, 'a thing characteristic of its kind');
      expect(result.words[0].exampleSentence, 'This is an example sentence.');
      expect(result.words[0].minBtLevel, 3);
      expect(result.words[0].minLexile, 500);
    });

    test('should handle empty word list', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'message': '해당 도서에 등록된 단어가 없습니다.',
          'data': {
            'isbn': '9781338832556',
            'word_count': 0,
            'words': [],
          },
        },
      );

      when(mockApiClient.get('/api/books/9781338832556/words'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await wordApiService.getWords('9781338832556');

      // Assert
      expect(result.isbn, '9781338832556');
      expect(result.wordCount, 0);
      expect(result.words.isEmpty, true);
    });

    test('should handle nullable fields correctly', () async {
      // Arrange - Some words might not have all fields
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'data': {
            'isbn': '123',
            'word_count': 1,
            'words': [
              {
                'word': 'incomplete',
                'word_order': 1,
                'word_id': null,
                'definition': null,
                'example_sentence': null,
                'min_bt_level': null,
                'min_lexile': null,
              },
            ],
          },
        },
      );

      when(mockApiClient.get('/api/books/123/words'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await wordApiService.getWords('123');

      // Assert
      expect(result.words[0].word, 'incomplete');
      expect(result.words[0].wordId, null);
      expect(result.words[0].definition, null);
      expect(result.words[0].exampleSentence, null);
      expect(result.words[0].minBtLevel, null);
      expect(result.words[0].minLexile, null);
    });
  });
}
