import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:reading_turtle/core/utils/api_client.dart';
import 'package:reading_turtle/core/utils/storage_service.dart';
import 'package:reading_turtle/data/repositories/auth_repository_impl.dart';
import 'package:reading_turtle/domain/entities/user.dart';
import 'package:dio/dio.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([ApiClient, StorageService])
import 'auth_repository_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late MockStorageService mockStorageService;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockStorageService = MockStorageService();
    authRepository = AuthRepositoryImpl(mockApiClient, mockStorageService);
  });

  group('AuthRepository Tests', () {
    group('login', () {
      test('should login successfully and return user', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final responseData = {
          'token': 'jwt_token_here',
          'user': {
            'id': '1',
            'email': email,
            'name': 'Test User',
          }
        };

        when(mockApiClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: responseData,
              statusCode: 200,
            ));

        when(mockStorageService.saveString(any, any))
            .thenAnswer((_) async => true);

        // Act
        final result = await authRepository.login(email, password);

        // Assert
        expect(result, isA<User>());
        expect(result.email, email);
        expect(result.name, 'Test User');
        verify(mockApiClient.post(
          '/api/auth/login',
          data: {'email': email, 'password': password},
        )).called(1);
        verify(mockStorageService.saveString('jwt_token', 'jwt_token_here'))
            .called(1);
      });

      test('should throw exception on invalid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';

        when(mockApiClient.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 401,
              data: {'message': 'Invalid credentials'},
            ),
          ),
        );

        // Act & Assert
        expect(
          () => authRepository.login(email, password),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signup', () {
      test('should signup successfully and return user', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const name = 'New User';
        final responseData = {
          'token': 'jwt_token_here',
          'user': {
            'id': '2',
            'email': email,
            'name': name,
          }
        };

        when(mockApiClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: responseData,
              statusCode: 201,
            ));

        when(mockStorageService.saveString(any, any))
            .thenAnswer((_) async => true);

        // Act
        final result = await authRepository.signup(email, password, name);

        // Assert
        expect(result, isA<User>());
        expect(result.email, email);
        expect(result.name, name);
        verify(mockApiClient.post(
          '/api/auth/signup',
          data: {'email': email, 'password': password, 'name': name},
        )).called(1);
      });

      test('should throw exception on duplicate email', () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'password123';
        const name = 'Existing User';

        when(mockApiClient.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 409,
              data: {'message': 'Email already exists'},
            ),
          ),
        );

        // Act & Assert
        expect(
          () => authRepository.signup(email, password, name),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('logout', () {
      test('should clear storage on logout', () async {
        // Arrange
        when(mockStorageService.clear()).thenAnswer((_) async => true);

        // Act
        await authRepository.logout();

        // Assert
        verify(mockStorageService.clear()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return null if no token stored', () async {
        // Arrange
        when(mockStorageService.getString('jwt_token')).thenReturn(null);

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });

      test('should return user if valid token exists', () async {
        // Arrange
        when(mockStorageService.getString('jwt_token'))
            .thenReturn('valid_token');
        when(mockStorageService.getString('user_id')).thenReturn('1');
        when(mockStorageService.getString('user_email'))
            .thenReturn('test@example.com');
        when(mockStorageService.getString('user_name')).thenReturn('Test User');

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, isA<User>());
        expect(result?.email, 'test@example.com');
        expect(result?.name, 'Test User');
      });
    });
  });
}
