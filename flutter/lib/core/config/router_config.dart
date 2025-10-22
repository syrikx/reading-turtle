import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/quiz/quiz_screen.dart';
import '../../presentation/screens/word_study/word_study_screen.dart';
import '../../presentation/screens/mypage/my_page_screen.dart';
import '../../presentation/screens/mypage/my_words_screen.dart';
import '../../presentation/screens/quiz/quiz_config_screen.dart';
import '../../presentation/screens/quiz/filtered_quiz_screen.dart';
import '../../presentation/screens/quiz/wrong_answers_list_screen.dart';
import '../../presentation/screens/support/support_list_screen.dart';
import '../../presentation/screens/support/support_detail_screen.dart';
import '../../presentation/screens/support/support_form_screen.dart';
import '../../features/reading_calendar/screens/reading_calendar_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/scaffold_with_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // If authenticated and trying to access auth route, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      // Allow all other routes without authentication
      return null;
    },
    routes: [
      // Main app routes with persistent navigation bar
      ShellRoute(
        builder: (context, state, child) {
          // Get title from route metadata or default
          String title = 'ReadingTurtle';
          if (state.matchedLocation == '/') {
            title = 'Home';
          } else if (state.matchedLocation == '/search') {
            title = 'Search Books';
          } else if (state.matchedLocation == '/mypage') {
            title = 'My Page';
          } else if (state.matchedLocation.startsWith('/quiz/')) {
            title = 'Quiz';
          } else if (state.matchedLocation.startsWith('/word-study/')) {
            title = 'Word Study';
          }

          return ScaffoldWithNavBar(
            title: title,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/quiz/:isbn',
            pageBuilder: (context, state) {
              final isbn = state.pathParameters['isbn']!;
              return NoTransitionPage(
                child: QuizScreen(isbn: isbn),
              );
            },
          ),
          GoRoute(
            path: '/word-study/:isbn',
            pageBuilder: (context, state) {
              final isbn = state.pathParameters['isbn']!;
              return NoTransitionPage(
                child: WordStudyScreen(isbn: isbn),
              );
            },
          ),
          GoRoute(
            path: '/mypage',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const MyPageScreen(),
            ),
          ),
          GoRoute(
            path: '/my-words/:filterType',
            pageBuilder: (context, state) {
              final filterType = state.pathParameters['filterType']!;
              return NoTransitionPage(
                child: MyWordsScreen(filterType: filterType),
              );
            },
          ),
          GoRoute(
            path: '/quiz-config',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const QuizConfigScreen(),
            ),
          ),
          GoRoute(
            path: '/quiz-level',
            pageBuilder: (context, state) {
              final params = state.uri.queryParameters;
              return NoTransitionPage(
                child: FilteredQuizScreen(
                  quizType: 'level',
                  queryParams: params,
                ),
              );
            },
          ),
          GoRoute(
            path: '/quiz-user-words',
            pageBuilder: (context, state) {
              final params = state.uri.queryParameters;
              return NoTransitionPage(
                child: FilteredQuizScreen(
                  quizType: 'user_words',
                  queryParams: params,
                ),
              );
            },
          ),
          GoRoute(
            path: '/quiz-wrong-answers',
            pageBuilder: (context, state) {
              final params = state.uri.queryParameters;
              return NoTransitionPage(
                child: FilteredQuizScreen(
                  quizType: 'wrong_answers',
                  queryParams: params,
                ),
              );
            },
          ),
          GoRoute(
            path: '/wrong-answers-list',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const WrongAnswersListScreen(),
            ),
          ),
          GoRoute(
            path: '/reading-calendar',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ReadingCalendarScreen(),
            ),
          ),
        ],
      ),
      // Support routes without navigation bar
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportListScreen(),
      ),
      GoRoute(
        path: '/support/new',
        builder: (context, state) => const SupportFormScreen(),
      ),
      GoRoute(
        path: '/support/:postId',
        builder: (context, state) {
          final postId = int.parse(state.pathParameters['postId']!);
          return SupportDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/support/:postId/edit',
        builder: (context, state) {
          final postId = int.parse(state.pathParameters['postId']!);
          return SupportFormScreen(postId: postId);
        },
      ),
      // Auth routes without navigation bar
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
    ],
  );
});
