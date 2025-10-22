import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/api_client.dart';
import '../../data/api/book_api_service.dart';
import '../../data/models/book_model.dart';
import '../../domain/entities/book.dart';
import 'auth_provider.dart';

// Book API Service Provider
final bookApiServiceProvider = Provider<BookApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookApiService(apiClient);
});

// Book Search State
class BookSearchState {
  final List<Book> books;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final int? totalCount;
  final bool isCountLoading;

  BookSearchState({
    this.books = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.totalCount,
    this.isCountLoading = false,
  });

  BookSearchState copyWith({
    List<Book>? books,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? totalCount,
    bool? isCountLoading,
  }) {
    return BookSearchState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      totalCount: totalCount ?? this.totalCount,
      isCountLoading: isCountLoading ?? this.isCountLoading,
    );
  }
}

// Book Search Notifier
class BookSearchNotifier extends StateNotifier<BookSearchState> {
  final BookApiService _bookApiService;

  BookSearchNotifier(this._bookApiService) : super(BookSearchState());

  Future<void> searchBooks({
    required String query,
    String searchType = 'all',
    double? btLevelMin,
    double? btLevelMax,
    int? lexileMin,
    int? lexileMax,
    String? genre,
    bool? hasQuiz,
    bool? hasWords,
  }) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        books: [],
        error: null,
        searchQuery: '',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _bookApiService.searchBooks(
        query: query,
        searchType: searchType,
        btLevelMin: btLevelMin,
        btLevelMax: btLevelMax,
        lexileMin: lexileMin,
        lexileMax: lexileMax,
        genre: genre,
        hasQuiz: hasQuiz,
        hasWords: hasWords,
      );

      final booksData = response['data'] as List;
      final books = booksData
          .map((json) => BookModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      state = state.copyWith(
        books: books,
        isLoading: false,
        searchQuery: query,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateCount({
    String? query,
    String searchType = 'all',
    double? btLevelMin,
    double? btLevelMax,
    int? lexileMin,
    int? lexileMax,
    String? genre,
    bool? hasQuiz,
    bool? hasWords,
  }) async {
    state = state.copyWith(isCountLoading: true);

    try {
      final count = await _bookApiService.searchBooksCount(
        query: query,
        searchType: searchType,
        btLevelMin: btLevelMin,
        btLevelMax: btLevelMax,
        lexileMin: lexileMin,
        lexileMax: lexileMax,
        genre: genre,
        hasQuiz: hasQuiz,
        hasWords: hasWords,
      );

      state = state.copyWith(
        totalCount: count,
        isCountLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCountLoading: false,
        totalCount: null,
      );
    }
  }

  void clearSearch() {
    state = BookSearchState();
  }
}

// Book Search Provider
final bookSearchProvider =
    StateNotifierProvider<BookSearchNotifier, BookSearchState>((ref) {
  final bookApiService = ref.watch(bookApiServiceProvider);
  return BookSearchNotifier(bookApiService);
});
