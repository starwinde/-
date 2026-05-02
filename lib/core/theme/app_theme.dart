import 'package:flutter/material.dart';

/// 루틴몬 light/dark 테마 정의 (PRD §2.20: 파스텔 그린 메인 + 다크모드 지원).
class AppTheme {
  const AppTheme._();

  static const _seed = Color(0xFFA8D8B9);

  /// Light theme with pastel-green seed.
  static ThemeData light() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      );

  /// Dark theme with pastel-green seed.
  static ThemeData dark() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
