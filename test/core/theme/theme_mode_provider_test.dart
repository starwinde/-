import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routinemon/core/theme/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('default ThemeMode is system when nothing saved', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final mode = await container.read(themeModeProvider.future);
    expect(mode, ThemeMode.system);
  });

  test('loads previously saved "dark" value', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final mode = await container.read(themeModeProvider.future);
    expect(mode, ThemeMode.dark);
  });

  test('setMode persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(themeModeProvider.future);
    await container
        .read(themeModeProvider.notifier)
        .setMode(ThemeMode.light);
    final updated = await container.read(themeModeProvider.future);
    expect(updated, ThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'light');
  });
}
