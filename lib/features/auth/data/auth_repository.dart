import 'package:routinemon/features/auth/domain/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

/// Wraps Supabase Auth operations into domain-friendly methods.
class AuthRepository {
  /// Creates an [AuthRepository] backed by the given [SupabaseClient].
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Returns the currently signed-in user, or `null` if not authenticated.
  AuthUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      nickname: user.userMetadata?['nickname'] as String?,
    );
  }

  /// Signs in with Google using the provided [idToken] and [accessToken].
  Future<AuthUser> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) async {
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    final user = response.user;
    if (user == null) {
      throw StateError('Google sign-in succeeded but user is null');
    }
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      nickname: user.userMetadata?['nickname'] as String?,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Returns the current JWT access token, or `null` if not authenticated.
  String? get accessToken => _client.auth.currentSession?.accessToken;
}
