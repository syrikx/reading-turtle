import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/api_config.dart';
import '../../domain/entities/book.dart';
import '../providers/reading_status_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_preferences_provider.dart';
import 'pulsing_button_wrapper.dart';
import '../../features/reading_calendar/widgets/add_reading_session_dialog.dart';

class BookCard extends ConsumerStatefulWidget {
  final Book book;
  final bool showDates;
  final bool animateButtons;

  const BookCard({
    super.key,
    required this.book,
    this.showDates = false,
    this.animateButtons = false,
  });

  @override
  ConsumerState<BookCard> createState() => _BookCardState();
}

class _BookCardState extends ConsumerState<BookCard> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    // Construct full image URL
    String? imageUrl;
    if (widget.book.imageUrl != null) {
      final hostname = Uri.base.host;

      if (hostname == 'localhost' || hostname == '127.0.0.1') {
        // Development: use backend URL directly
        imageUrl = 'http://localhost:8010${widget.book.imageUrl}';
      } else {
        // Production: use nginx proxy (/bookimg/ -> localhost:8010)
        imageUrl = 'https://reading-turtle.com/bookimg${widget.book.imageUrl!.replaceAll('/bookimg', '')}';
      }
    }

    final hasQuiz = widget.book.quiz != null && widget.book.quiz! > 0;
    final hasWords = widget.book.hasWords == true;

    return Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Book Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 100,
                maxHeight: 300,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.book,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.book,
                        size: 48,
                        color: Colors.grey,
                      ),
              ),
            ),
          ),

          // Book Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Author
                  Text(
                    widget.book.author,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Levels and Quiz Badge
                  Row(
                    children: [
                      // Show level based on user preference
                      _buildLevelBadge(),
                      if (hasQuiz) ...[
                        PulsingButtonWrapper(
                          animate: widget.animateButtons,
                          child: GestureDetector(
                            onTap: () => context.go('/quiz/${widget.book.isbn}'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.quiz,
                                    size: 12,
                                    color: Colors.green[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Quiz',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (hasWords) ...[
                        PulsingButtonWrapper(
                          animate: widget.animateButtons,
                          child: GestureDetector(
                            onTap: () => context.go('/word-study/${widget.book.isbn}'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.menu_book,
                                    size: 12,
                                    color: Colors.orange[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Words',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      // 독서 기록 버튼 (로그인 시에만 표시)
                      if (isLoggedIn) ...[
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddReadingSessionDialog(
                                  book: widget.book,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_calendar,
                                    size: 12,
                                    color: Colors.teal[900],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '독서 기록',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.teal[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    final preferences = ref.watch(userPreferencesProvider);
    final displayType = preferences.levelDisplayType;

    if (displayType == LevelDisplayType.btLevel) {
      // Show BT Level as "Lv."
      if (widget.book.btLevel != null) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Lv. ${widget.book.btLevel}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        );
      }
    } else {
      // Show Lexile
      if (widget.book.lexile != null) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.book.lexile!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.purple[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }
}
