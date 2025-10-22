import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String userId,
    required String username,
    required String email,
    String? fullName,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle userId as both int and String
    final userId = json['userId'];
    final userIdStr = userId is int ? userId.toString() : userId as String;

    return UserModel(
      userId: userIdStr,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
    );
  }

  // Convert to domain entity
  User toEntity() {
    return User(
      id: userId,
      username: username,
      email: email,
      fullName: fullName,
    );
  }

  // Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.id,
      username: user.username,
      email: user.email,
      fullName: user.fullName,
    );
  }
}
