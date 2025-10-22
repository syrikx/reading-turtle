import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/support_api_service.dart';
import '../../data/models/support_post_model.dart';
import '../../data/models/support_reply_model.dart';
import 'auth_provider.dart';
import 'support_state.dart';

// Support API Service Provider
final supportApiServiceProvider = Provider<SupportApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SupportApiService(apiClient);
});

// Support List Notifier
class SupportNotifier extends StateNotifier<SupportState> {
  final SupportApiService _apiService;

  SupportNotifier(this._apiService) : super(const SupportState.initial());

  /// Load all support posts
  Future<void> loadPosts() async {
    state = const SupportState.loading();

    try {
      final response = await _apiService.getPosts();
      final postsData = response['data'] as List;

      final posts = postsData
          .map((json) => SupportPostModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      state = SupportState.loaded(posts: posts);
    } catch (e) {
      state = SupportState.error(e.toString());
    }
  }

  /// Create new post
  Future<void> createPost({
    required String title,
    required String content,
    bool isPrivate = false,
  }) async {
    try {
      await _apiService.createPost(title: title, content: content, isPrivate: isPrivate);
      await loadPosts(); // Reload list
    } catch (e) {
      rethrow;
    }
  }

  /// Delete post
  Future<void> deletePost(int postId) async {
    try {
      await _apiService.deletePost(postId);
      await loadPosts(); // Reload list
    } catch (e) {
      rethrow;
    }
  }
}

// Support List Provider
final supportProvider =
    StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  final apiService = ref.watch(supportApiServiceProvider);
  return SupportNotifier(apiService);
});

// Support Detail Notifier
class SupportDetailNotifier extends StateNotifier<SupportDetailState> {
  final SupportApiService _apiService;

  SupportDetailNotifier(this._apiService)
      : super(const SupportDetailState.initial());

  /// Load single post with replies
  Future<void> loadPost(int postId) async {
    state = const SupportDetailState.loading();

    try {
      final response = await _apiService.getPost(postId);
      final data = response['data'] as Map<String, dynamic>;

      final post = SupportPostModel.fromJson(
        data['post'] as Map<String, dynamic>,
      ).toEntity();

      final repliesData = data['replies'] as List;
      final replies = repliesData
          .map((json) => SupportReplyModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();

      state = SupportDetailState.loaded(post: post, replies: replies);
    } catch (e) {
      state = SupportDetailState.error(e.toString());
    }
  }

  /// Update post
  Future<void> updatePost({
    required int postId,
    required String title,
    required String content,
    bool? isPrivate,
  }) async {
    try {
      await _apiService.updatePost(
        postId: postId,
        title: title,
        content: content,
        isPrivate: isPrivate,
      );
      await loadPost(postId); // Reload post
    } catch (e) {
      rethrow;
    }
  }

  /// Add reply
  Future<void> addReply({
    required int postId,
    required String content,
  }) async {
    try {
      await _apiService.addReply(postId: postId, content: content);
      await loadPost(postId); // Reload post with new reply
    } catch (e) {
      rethrow;
    }
  }
}

// Support Detail Provider Family (one provider per postId)
final supportDetailProvider = StateNotifierProvider.family<
    SupportDetailNotifier,
    SupportDetailState,
    int>((ref, postId) {
  final apiService = ref.watch(supportApiServiceProvider);
  return SupportDetailNotifier(apiService);
});
