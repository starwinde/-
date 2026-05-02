@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:routinemon/core/config/env.dart';

/// Integration test: Supabase login -> JWT -> Workers /health Bearer -> 200.
///
/// Requires a running Supabase instance and Workers dev server.
/// Run with: flutter test test/features/auth/auth_integration_test.dart
void main() {
  group('Auth integration (requires real servers)', () {
    test(
      'JWT from Supabase passes Workers auth middleware',
      skip: 'Requires running Supabase + Workers + real credentials',
      () async {
        // 1. Sign in to Supabase with email/password (test account).
        // This is a placeholder — in a real test you'd call
        // Supabase.instance.client.auth.signInWithPassword().
        const testJwt = 'REPLACE_WITH_REAL_JWT';

        // 2. Call Workers /health with the JWT.
        final response = await http.get(
          Uri.parse('${Env.n8nUrl}/health'),
          headers: {'Authorization': 'Bearer $testJwt'},
        );

        expect(response.statusCode, 200);
      },
    );
  });
}
