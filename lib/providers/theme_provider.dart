import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final ThemeMode mode;
  final bool isDark;

  const ThemeState({
    this.mode = ThemeMode.system,
    this.isDark = false,
  });

  ThemeState copyWith({ThemeMode? mode, bool? isDark}) {
    return ThemeState(
      mode: mode ?? this.mode,
      isDark: isDark ?? this.isDark,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _themeKey = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  ThemeNotifier() : super(const ThemeState()) {
    _restoreTheme();
  }

  void _restoreTheme() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    state = state.copyWith(isDark: brightness == Brightness.dark);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _storage.write(key: _themeKey, value: mode.name);
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    state = state.copyWith(mode: mode, isDark: isDark);
  }

  void toggleTheme() {
    final newIsDark = !state.isDark;
    final newMode = newIsDark ? ThemeMode.dark : ThemeMode.light;
    setTheme(newMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
