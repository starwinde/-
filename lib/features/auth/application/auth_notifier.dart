import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:routinemon/features/auth/application/user_id_migrator.dart';
import 'package:routinemon/features/auth/data/auth_repository.dart';
import 'package:routinemon/features/auth/domain/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

part 'auth_notifier.g.dart';

/// Provides the [AuthRepository] singleton backed by the default Supabase
/// client.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}

/// Manages authentication state across the app.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthUser?> build() async {
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  /// Signs in with Google OAuth using the provided tokens.
  ///
  /// 로그인 성공 시 게스트 모드에서 `'local'` userId 로 쌓인 데이터를
  /// 새 user id 로 이관 (rev 27 게스트 모드 회로 완성).
  Future<void> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle(
            idToken: idToken,
            accessToken: accessToken,
          );
      await ref
          .read(userIdMigratorProvider)
          .migrateFromGuest(newUserId: user.id);
      return user;
    });
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
