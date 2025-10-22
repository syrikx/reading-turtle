import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  // Filter states
  String? _selectedGenre; // null, 'fiction', 'nonfiction'
  bool _hasQuiz = false;
  bool _hasWords = false;
  RangeValues _btLevelRange = const RangeValues(0, 10);

  @override
  void initState() {
    super.initState();
    // Load initial count with no filters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCount();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _updateCount();
    });
  }

  void _updateCount() {
    final query = _searchController.text.trim();
    final queryToUse = query.isEmpty ? null : query;

    ref.read(bookSearchProvider.notifier).updateCount(
          query: queryToUse,
          btLevelMin: _btLevelRange.start,
          btLevelMax: _btLevelRange.end,
          genre: _selectedGenre,
          hasQuiz: _hasQuiz ? true : null,
          hasWords: _hasWords ? true : null,
        );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ref.read(bookSearchProvider.notifier).searchBooks(
            query: query,
            btLevelMin: _btLevelRange.start,
            btLevelMax: _btLevelRange.end,
            genre: _selectedGenre,
            hasQuiz: _hasQuiz ? true : null,
            hasWords: _hasWords ? true : null,
          );
    }
  }

  bool get _isAllFiltersOff {
    return _selectedGenre == null && !_hasQuiz && !_hasWords;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedGenre = null;
      _hasQuiz = false;
      _hasWords = false;
    });
    _updateCount();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(bookSearchProvider);

    return Column(
      children: [
        // Compact 3-row filter section
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              // Row 1: Search input + Search button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(bookSearchProvider.notifier).clearSearch();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _performSearch(),
                      onChanged: (value) {
                        setState(() {});
                        _onSearchChanged(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: All, Fiction, Nonfiction, Quiz, Words buttons
              Row(
                children: [
                  Expanded(
                    child: _buildAllButton(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildGenreButton('Fiction', 'fiction'),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildGenreButton('Nonfiction', 'nonfiction'),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildToggleButton('Quiz', _hasQuiz, (val) {
                      setState(() => _hasQuiz = val);
                      _updateCount();
                    }),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildToggleButton('Words', _hasWords, (val) {
                      setState(() => _hasWords = val);
                      _updateCount();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 3: Level slider + Result count
              Row(
                children: [
                  const Text('Level:', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RangeSlider(
                      values: _btLevelRange,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      activeColor: Colors.green,
                      labels: RangeLabels(
                        _btLevelRange.start.toStringAsFixed(1),
                        _btLevelRange.end.toStringAsFixed(1),
                      ),
                      onChanged: (values) {
                        setState(() => _btLevelRange = values);
                      },
                      onChangeEnd: (values) {
                        _updateCount();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    searchState.totalCount != null
                        ? '${searchState.totalCount} books'
                        : '',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: _buildResults(searchState),
        ),
      ],
    );
  }

  Widget _buildAllButton() {
    final isSelected = _isAllFiltersOff;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          _clearAllFilters();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'All',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGenreButton(String label, String genre) {
    final isSelected = _selectedGenre == genre;
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle off if already selected, otherwise select it
          _selectedGenre = isSelected ? null : genre;
        });
        _updateCount();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, Function(bool) onToggle) {
    return GestureDetector(
      onTap: () => onToggle(!isActive),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange : Colors.white,
          border: Border.all(
            color: isActive ? Colors.orange : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BookSearchState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.books.isEmpty && state.searchQuery != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No books found for "${state.searchQuery}"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.books.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for books',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Enter a title, author, or ISBN',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive column count based on screen width
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth >= 1400) {
          // Extra large screens: 6 columns
          crossAxisCount = 6;
          childAspectRatio = 0.7;
        } else if (constraints.maxWidth >= 1200) {
          // Large screens: 5 columns
          crossAxisCount = 5;
          childAspectRatio = 0.7;
        } else if (constraints.maxWidth >= 900) {
          // Medium-large screens: 4 columns
          crossAxisCount = 4;
          childAspectRatio = 0.68;
        } else if (constraints.maxWidth >= 600) {
          // Medium screens: 3 columns
          crossAxisCount = 3;
          childAspectRatio = 0.65;
        } else if (constraints.maxWidth >= 400) {
          // Small screens: 2 columns
          crossAxisCount = 2;
          childAspectRatio = 0.65;
        } else {
          // Extra small screens: 1 column
          crossAxisCount = 1;
          childAspectRatio = 0.7;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.books.length,
          itemBuilder: (context, index) {
            final book = state.books[index];
            return BookCard(book: book);
          },
        );
      },
    );
  }
}
