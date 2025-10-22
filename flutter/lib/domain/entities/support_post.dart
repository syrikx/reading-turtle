import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_post.freezed.dart';

@freezed
class SupportPost with _$SupportPost {
  const factory SupportPost({
    required int postId,
    required int userId,
    required String title,
    required String content,
    required String status, // open, answered, closed
    @Default(false) bool isPrivate,
    String? username,
    String? fullName,
    int? replyCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SupportPost;

  factory SupportPost.fromJson(Map<String, dynamic> json) {
    return SupportPost(
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      status: json['status'] as String,
      isPrivate: json['is_private'] as bool? ?? false,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      replyCount: json['reply_count'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
