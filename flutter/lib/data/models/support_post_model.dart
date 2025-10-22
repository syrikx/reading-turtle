import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/support_post.dart';

part 'support_post_model.freezed.dart';

@freezed
class SupportPostModel with _$SupportPostModel {
  const SupportPostModel._();

  const factory SupportPostModel({
    required int postId,
    required int userId,
    required String title,
    required String content,
    required String status,
    @Default(false) bool isPrivate,
    String? username,
    String? fullName,
    int? replyCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SupportPostModel;

  factory SupportPostModel.fromJson(Map<String, dynamic> json) {
    // Handle numeric fields that might come as different types
    int? parseReplyCount(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      // Handle bigint from PostgreSQL COUNT()
      if (value is num) return value.toInt();
      return null;
    }

    return SupportPostModel(
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      status: json['status'] as String,
      isPrivate: json['is_private'] as bool? ?? false,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      replyCount: parseReplyCount(json['reply_count']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to domain entity
  SupportPost toEntity() {
    return SupportPost(
      postId: postId,
      userId: userId,
      title: title,
      content: content,
      status: status,
      isPrivate: isPrivate,
      username: username,
      fullName: fullName,
      replyCount: replyCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create from domain entity
  factory SupportPostModel.fromEntity(SupportPost post) {
    return SupportPostModel(
      postId: post.postId,
      userId: post.userId,
      title: post.title,
      content: post.content,
      status: post.status,
      isPrivate: post.isPrivate,
      username: post.username,
      fullName: post.fullName,
      replyCount: post.replyCount,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
    );
  }
}
