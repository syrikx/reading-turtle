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
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/tutorial/search_tutorial_screen.dart';
import '../../presentation/screens/tutorial/quiz_tutorial_screen.dart';
import '../../presentation/screens/tutorial/words_tutorial_screen.dart';
import '../../presentation/screens/tutorial/calendar_tutorial_screen.dart';
import '../../features/reading_calendar/screens/reading_calendar_screen.dart';
import '../../features/reading_calendar/screens/monthly_calendar_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/scaffold_with_nav_bar.dart';
import '../constants/storage_keys.dart';

// Router refresh notifier to prevent "ref after disposed" errors
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

// Provider to check if user has seen onboarding
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  return await storageService.getBool(StorageKeys.hasSeenOnboarding) ?? false;
});

// Provider to track initialization state
final isInitializingProvider = StateProvider<bool>((ref) => true);

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplashRoute = state.matchedLocation == '/splash';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      // Allow splash and onboarding routes
      if (isSplashRoute || isOnboardingRoute) {
        return null;
      }

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
      // Reading calendar monthly view (without navigation bar)
      GoRoute(
        path: '/reading-calendar/monthly',
        builder: (context, state) => const MonthlyCalendarScreen(),
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
      // Splash and onboarding routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Tutorial routes (without navigation bar)
      GoRoute(
        path: '/tutorial/search',
        builder: (context, state) => const SearchTutorialScreen(),
      ),
      GoRoute(
        path: '/tutorial/quiz',
        builder: (context, state) => const QuizTutorialScreen(),
      ),
      GoRoute(
        path: '/tutorial/words',
        builder: (context, state) => const WordsTutorialScreen(),
      ),
      GoRoute(
        path: '/tutorial/calendar',
        builder: (context, state) => const CalendarTutorialScreen(),
      ),
    ],
  );
});
