import 'dart:ui';

sealed class LocaleEvent {
  const LocaleEvent();
}

class LoadLocale extends LocaleEvent {
  const LoadLocale();
}

class ChangeLocale extends LocaleEvent {
  const ChangeLocale(this.locale);

  final Locale locale;
}
