/// 환경별 URL 설정 (--dart-define으로 주입).
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://localhost:8100',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc2MjI0MTQ5LCJleHAiOjE5MzM5MDQxNDl9.SaUCrXdJHRSi4hb2a31TA0EPSPFc4rnY54faRhLH3xw',
  );

  /// n8n webhook base URL (아키텍처 변경: Workers → n8n).
  static const n8nUrl = String.fromEnvironment(
    'N8N_URL',
    defaultValue: 'https://localhost:5678',
  );
}
