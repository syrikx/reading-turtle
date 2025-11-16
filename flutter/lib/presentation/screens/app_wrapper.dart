import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/storage_service.dart';
import '../../presentation/providers/auth_provider.dart';
import 'splash/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';

/// App initialization state provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Wait for 3 seconds (splash screen duration)
  await Future.delayed(const Duration(seconds: 3));

  // Check if user has seen onboarding
  final storageService = ref.read(storageServiceProvider);
  final hasSeenOnboarding = await storageService.getBool(StorageKeys.hasSeenOnboarding) ?? false;

  return hasSeenOnboarding;
});

class AppWrapper extends ConsumerWidget {
  final Widget child;

  const AppWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitializationProvider);

    return initState.when(
      data: (hasSeenOnboarding) {
        if (!hasSeenOnboarding) {
          // First time user - show onboarding
          return const OnboardingScreen();
        }
        // Regular user - show app
        return child;
      },
      loading: () => const SplashScreen(),
      error: (error, stack) {
        // On error, skip to app
        debugPrint('AppWrapper error: $error');
        return child;
      },
    );
  }
}
