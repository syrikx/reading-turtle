import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/support_post.dart';
import '../../domain/entities/support_reply.dart';

part 'support_state.freezed.dart';

@freezed
class SupportState with _$SupportState {
  const factory SupportState.initial() = _Initial;
  const factory SupportState.loading() = _Loading;
  const factory SupportState.loaded({
    required List<SupportPost> posts,
  }) = _Loaded;
  const factory SupportState.error(String message) = _Error;
}

@freezed
class SupportDetailState with _$SupportDetailState {
  const factory SupportDetailState.initial() = _DetailInitial;
  const factory SupportDetailState.loading() = _DetailLoading;
  const factory SupportDetailState.loaded({
    required SupportPost post,
    required List<SupportReply> replies,
  }) = _DetailLoaded;
  const factory SupportDetailState.error(String message) = _DetailError;
}
