import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_event.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc(this._preferences) : super(ThemeMode.light) {
    on<LoadTheme>((event, emit) async {
      try {
        final isDark = await _preferences.getBool(_key) ?? false;
        emit(isDark ? ThemeMode.dark : ThemeMode.light);
      } catch (_) {
        emit(ThemeMode.light);
      }
    });
    on<ToggleTheme>((event, emit) async {
      final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      emit(next);
      try {
        await _preferences.setBool(_key, next == ThemeMode.dark);
      } catch (_) {
        // The selected theme still applies for this session.
      }
    });
  }

  static const _key = 'streetbite_dark_theme';
  final SharedPreferencesAsync _preferences;
}
