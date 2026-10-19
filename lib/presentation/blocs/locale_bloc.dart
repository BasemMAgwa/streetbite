import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_event.dart';

class LocaleBloc extends Bloc<LocaleEvent, Locale> {
  LocaleBloc(this._preferences, {Locale? systemLocale})
    : super(_supported(systemLocale ?? _platformLocale())) {
    on<LoadLocale>((event, emit) async {
      try {
        final code = await _preferences.getString(_key);
        if (code != null && supportedCodes.contains(code)) {
          emit(Locale(code));
        }
      } catch (_) {
        // The system-derived locale stays in effect.
      }
    });
    on<ChangeLocale>((event, emit) async {
      final next = _supported(event.locale);
      emit(next);
      try {
        await _preferences.setString(_key, next.languageCode);
      } catch (_) {
        // The selected language still applies for this session.
      }
    });
  }

  static const _key = 'streetbite_locale';
  static const supportedCodes = {'en', 'ar'};
  final SharedPreferencesAsync _preferences;

  static Locale _platformLocale() =>
      WidgetsBinding.instance.platformDispatcher.locale;

  static Locale _supported(Locale locale) =>
      supportedCodes.contains(locale.languageCode)
      ? Locale(locale.languageCode)
      : const Locale('en');
}
