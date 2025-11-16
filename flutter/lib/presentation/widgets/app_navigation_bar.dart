import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AppNavigationBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const AppNavigationBar({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentPath = GoRouterState.of(context).uri.path;

    return AppBar(
      title: Row(
        children: [
          const Text('🐢'),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: showBackButton,
      actions: [
        // Navigation Menu (always visible)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Home
            if (currentPath != '/')
              IconButton(
                icon: const Icon(Icons.home),
                tooltip: 'Home',
                onPressed: () => context.go('/'),
              ),

            // Search
            if (currentPath != '/search')
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search Books',
                onPressed: () => context.go('/search'),
              ),

            // Reading Calendar
            if (currentPath != '/reading-calendar' && currentPath != '/reading-calendar/monthly')
              IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Reading Calendar',
                onPressed: () => context.go('/reading-calendar'),
              ),

            // User Menu or Login Button
            authState.maybeWhen(
              authenticated: (user) => PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                tooltip: user.fullName ?? user.username,
                onSelected: (value) {
                  switch (value) {
                    case 'mypage':
                      context.go('/mypage');
                      break;
                    case 'support':
                      context.go('/support');
                      break;
                    case 'logout':
                      ref.read(authProvider.notifier).logout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName ?? user.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mypage',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 8),
                        Text('My Page'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'support',
                    child: Row(
                      children: [
                        Icon(Icons.support_agent, size: 20),
                        SizedBox(width: 8),
                        Text('고객센터'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
              orElse: () => IconButton(
                icon: const Icon(Icons.login),
                tooltip: 'Login',
                onPressed: () => context.go('/auth/login'),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
