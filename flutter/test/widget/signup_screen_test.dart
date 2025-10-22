import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reading_turtle/presentation/screens/auth/signup_screen.dart';

void main() {
  group('SignUpScreen Widget Tests', () {
    testWidgets('should display signup form with name, email and password fields',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('🐢'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );

      // Act - Tap signup button without entering any data
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );

      // Act
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Name'), 'Test User');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'invalidemail');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });
}
