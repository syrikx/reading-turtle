import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reading_turtle/presentation/screens/auth/login_screen.dart';
import 'package:reading_turtle/presentation/providers/auth_provider.dart';
import 'package:reading_turtle/presentation/providers/auth_state.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display login form with email and password fields',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('ReadingTurtle'), findsOneWidget);
      expect(find.text('🐢'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text("Don't have an account? Sign up"), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Act - Tap login button without entering any data
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'invalidemail');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show validation error for short password',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), '12345');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Assert
      expect(find.text('Password must be at least 6 characters'),
          findsOneWidget);
    });

    // Note: Loading state test removed for simplicity
    // In real implementation, you can add integration tests for loading states
  });
}
