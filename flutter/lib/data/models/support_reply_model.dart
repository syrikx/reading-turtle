import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/support_reply.dart';

part 'support_reply_model.freezed.dart';

@freezed
class SupportReplyModel with _$SupportReplyModel {
  const SupportReplyModel._();

  const factory SupportReplyModel({
    required int replyId,
    required int postId,
    required int userId,
    required String content,
    required bool isAdmin,
    String? username,
    String? fullName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SupportReplyModel;

  factory SupportReplyModel.fromJson(Map<String, dynamic> json) {
    return SupportReplyModel(
      replyId: json['reply_id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      content: json['content'] as String,
      isAdmin: json['is_admin'] as bool,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to domain entity
  SupportReply toEntity() {
    return SupportReply(
      replyId: replyId,
      postId: postId,
      userId: userId,
      content: content,
      isAdmin: isAdmin,
      username: username,
      fullName: fullName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create from domain entity
  factory SupportReplyModel.fromEntity(SupportReply reply) {
    return SupportReplyModel(
      replyId: reply.replyId,
      postId: reply.postId,
      userId: reply.userId,
      content: reply.content,
      isAdmin: reply.isAdmin,
      username: reply.username,
      fullName: reply.fullName,
      createdAt: reply.createdAt,
      updatedAt: reply.updatedAt,
    );
  }
}
