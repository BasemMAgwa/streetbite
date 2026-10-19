import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/core/constants/message.dart';
import 'package:streetbite/core/validation/auth_validators.dart';
import 'package:streetbite/l10n/app_localizations.dart';
import 'package:streetbite/presentation/blocs/locale_bloc.dart';
import 'package:streetbite/presentation/blocs/locale_event.dart';
import 'package:streetbite/presentation/l10n/message_localizations.dart';
import 'package:streetbite/presentation/widgets/app_header_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('Arabic strings load and spot-check', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(ar.home, 'الرئيسية');
    expect(ar.cart, 'السلة');
    expect(ar.itemCount(1), 'عنصر واحد');
    expect(ar.itemCount(3), '3 عناصر');
  });

  test('validators map to translated text', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    final en = lookupAppLocalizations(const Locale('en'));
    final message = AuthValidators.email('');
    expect(message, AppMessage.requiredEmail);
    expect(message!.text(en), 'Enter your email address');
    expect(message.text(ar), ar.requiredEmail);
  });

  test('unsupported system locale falls back to English', () {
    final bloc = LocaleBloc(
      SharedPreferencesAsync(),
      systemLocale: const Locale('fr'),
    );
    addTearDown(bloc.close);
    expect(bloc.state, const Locale('en'));
  });

  test('chosen locale persists and reloads', () async {
    final prefs = SharedPreferencesAsync();
    final bloc = LocaleBloc(prefs, systemLocale: const Locale('en'))
      ..add(const ChangeLocale(Locale('ar')));
    await Future<void>.delayed(Duration.zero);
    await bloc.close();
    final reloaded = LocaleBloc(prefs, systemLocale: const Locale('en'))
      ..add(const LoadLocale());
    addTearDown(reloaded.close);
    await Future<void>.delayed(Duration.zero);
    expect(reloaded.state, const Locale('ar'));
  });

  testWidgets('globe toggle switches to Arabic and RTL', (tester) async {
    final bloc = LocaleBloc(
      SharedPreferencesAsync(),
      systemLocale: const Locale('en'),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: BlocBuilder<LocaleBloc, Locale>(
          builder: (context, locale) => MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    const LanguageToggleButton(),
                    Text(AppLocalizations.of(context).home),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.byType(LanguageToggleButton));
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('الرئيسية'))),
      TextDirection.rtl,
    );
  });
}
