import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routinemon/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

// --- Mocks ---

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockUser extends Mock implements User {}

class _MockSession extends Mock implements Session {}

void main() {
  late _MockSupabaseClient mockClient;
  late _MockGoTrueClient mockAuth;
  late AuthRepository repository;

  setUp(() {
    mockClient = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repository = AuthRepository(mockClient);
  });

  group('getCurrentUser', () {
    test('returns null when no user is signed in', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = repository.getCurrentUser();

      expect(result, isNull);
    });

    test('returns AuthUser when user is signed in', () {
      final mockUser = _MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.userMetadata).thenReturn({'nickname': '테스터'});
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final result = repository.getCurrentUser();

      expect(result, isNotNull);
      expect(result!.id, 'user-123');
      expect(result.email, 'test@example.com');
      expect(result.nickname, '테스터');
    });

    test('returns empty email when user.email is null', () {
      final mockUser = _MockUser();
      when(() => mockUser.id).thenReturn('user-456');
      when(() => mockUser.email).thenReturn(null);
      when(() => mockUser.userMetadata).thenReturn(null);
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final result = repository.getCurrentUser();

      expect(result!.email, '');
      expect(result.nickname, isNull);
    });
  });

  group('signOut', () {
    test('calls supabase signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });
  });

  group('accessToken', () {
    test('returns null when no session exists', () {
      when(() => mockAuth.currentSession).thenReturn(null);

      expect(repository.accessToken, isNull);
    });

    test('returns token when session exists', () {
      final mockSession = _MockSession();
      when(() => mockSession.accessToken).thenReturn('jwt-token-abc');
      when(() => mockAuth.currentSession).thenReturn(mockSession);

      expect(repository.accessToken, 'jwt-token-abc');
    });
  });
}
