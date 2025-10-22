import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class SupportApiService {
  final ApiClient _apiClient;

  SupportApiService(this._apiClient);

  /// Get all support posts
  Future<Map<String, dynamic>> getPosts() async {
    try {
      final response = await _apiClient.get('/api/support/posts');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get posts');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      throw Exception('Failed to get posts: ${e.message}');
    }
  }

  /// Get single support post with replies
  Future<Map<String, dynamic>> getPost(int postId) async {
    try {
      final response = await _apiClient.get('/api/support/posts/$postId');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to get post');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Failed to get post: ${e.message}');
    }
  }

  /// Create new support post
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    bool isPrivate = false,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/support/posts',
        data: {
          'title': title,
          'content': content,
          'isPrivate': isPrivate,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to create post');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Please provide title and content');
      }
      throw Exception('Failed to create post: ${e.message}');
    }
  }

  /// Update support post
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String title,
    required String content,
    bool? isPrivate,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'title': title,
        'content': content,
      };
      if (isPrivate != null) {
        requestData['isPrivate'] = isPrivate;
      }

      final response = await _apiClient.put(
        '/api/support/posts/$postId',
        data: requestData,
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to update post');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You do not have permission to update this post');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Failed to update post: ${e.message}');
    }
  }

  /// Delete support post
  Future<Map<String, dynamic>> deletePost(int postId) async {
    try {
      final response = await _apiClient.delete('/api/support/posts/$postId');

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to delete post');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      if (e.response?.statusCode == 403) {
        throw Exception('You do not have permission to delete this post');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Failed to delete post: ${e.message}');
    }
  }

  /// Add reply to support post
  Future<Map<String, dynamic>> addReply({
    required int postId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/support/posts/$postId/replies',
        data: {
          'content': content,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to add reply');
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login.');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      }
      throw Exception('Failed to add reply: ${e.message}');
    }
  }
}
