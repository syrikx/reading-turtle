import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reading_turtle/domain/entities/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_status_provider.dart';
import '../../widgets/book_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load reading books when screen initializes (if authenticated)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        ref.read(readingStatusProvider.notifier).loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.user != null;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome Section
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🐢',
                    style: TextStyle(fontSize: 120),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to ReadingTurtle!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  authState.maybeWhen(
                    authenticated: (user) => Text(
                      'Hello, ${user.fullName ?? user.username}!',
                      style: const TextStyle(fontSize: 18),
                    ),
                    orElse: () => const Text(
                      'Start exploring books!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go('/search'),
                        icon: const Icon(Icons.search),
                        label: const Text('Search Books'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (isAuthenticated) ...[
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/reading-calendar'),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Reading Calendar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Reading Now Section (only for authenticated users)
          if (isAuthenticated) _buildReadingNowSection(),
        ],
      ),
    );
  }

  Widget _buildReadingNowSection() {
    final readingState = ref.watch(readingStatusProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.book, color: Colors.teal, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    '📖 읽는 중인 책',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => context.go('/mypage'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('모두 보기'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // State handling
          readingState.when(
            initial: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            loaded: (readingBooks, allBooks, stats, isUpdating, currentFilter) {
              if (readingBooks.isEmpty) {
                return _buildEmptyState();
              }
              return _buildBooksGrid(readingBooks);
            },
            error: (_) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '읽는 중인 책이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '책을 검색하고 읽기를 시작해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksGrid(List<Book> readingBooks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 1200) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 400) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        // Limit to first 12 books on home page
        final displayBooks = readingBooks.take(12).toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: displayBooks.length,
          itemBuilder: (context, index) {
            return BookCard(
              book: displayBooks[index],
              showStatusButtons: true,
              showDates: false,
            );
          },
        );
      },
    );
  }
}
