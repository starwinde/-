import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Authenticated user domain model (pure Dart, no framework imports).
@freezed
sealed class AuthUser with _$AuthUser {
  /// Creates an [AuthUser] with the given [id], [email], and
  /// optional [nickname].
  const factory AuthUser({
    required String id,
    required String email,
    String? nickname,
  }) = _AuthUser;
}
