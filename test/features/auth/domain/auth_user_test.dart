import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/features/auth/domain/auth_user.dart';

void main() {
  group('AuthUser', () {
    test('creates with required fields only', () {
      const user = AuthUser(id: '123', email: 'test@test.com');
      expect(user.id, '123');
      expect(user.email, 'test@test.com');
      expect(user.nickname, isNull);
    });

    test('creates with all fields', () {
      const user = AuthUser(
        id: 'abc',
        email: 'user@example.com',
        nickname: '닉네임',
      );
      expect(user.id, 'abc');
      expect(user.email, 'user@example.com');
      expect(user.nickname, '닉네임');
    });

    test('equality works for identical values', () {
      const a = AuthUser(id: '1', email: 'a@b.com');
      const b = AuthUser(id: '1', email: 'a@b.com');
      expect(a, equals(b));
    });

    test('equality fails for different values', () {
      const a = AuthUser(id: '1', email: 'a@b.com');
      const b = AuthUser(id: '2', email: 'a@b.com');
      expect(a, isNot(equals(b)));
    });

    test('copyWith works', () {
      const user = AuthUser(id: '1', email: 'old@test.com');
      final updated = user.copyWith(nickname: '새닉네임');
      expect(updated.nickname, '새닉네임');
      expect(updated.id, '1');
      expect(updated.email, 'old@test.com');
    });
  });
}
