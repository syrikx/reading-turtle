import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_reply.freezed.dart';

@freezed
class SupportReply with _$SupportReply {
  const factory SupportReply({
    required int replyId,
    required int postId,
    required int userId,
    required String content,
    required bool isAdmin,
    String? username,
    String? fullName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SupportReply;

  factory SupportReply.fromJson(Map<String, dynamic> json) {
    return SupportReply(
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
}
