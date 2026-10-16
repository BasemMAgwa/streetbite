import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/app.dart';
import 'package:streetbite/core/constants/app_strings.dart';
import 'package:streetbite/core/theme/app_theme.dart';
import 'package:streetbite/domain/entities/app_user.dart';
import 'package:streetbite/domain/entities/auth_failure.dart';
import 'package:streetbite/domain/entities/meal.dart';
import 'package:streetbite/domain/repositories/auth_repository.dart';
import 'package:streetbite/domain/repositories/meal_repository.dart';
import 'package:streetbite/domain/usecases/sign_in.dart';
import 'package:streetbite/domain/usecases/sign_out.dart';
import 'package:streetbite/domain/usecases/sign_up.dart';
import 'package:streetbite/injection.dart';
import 'package:streetbite/presentation/blocs/auth_cubit.dart';
import 'package:streetbite/presentation/blocs/auth_state.dart';
import 'package:streetbite/presentation/blocs/menu_cubit.dart';
import 'package:streetbite/presentation/screens/login_screen.dart';
import 'package:streetbite/presentation/screens/home_screen.dart';
import 'package:streetbite/presentation/screens/signup_screen.dart';
import 'package:streetbite/presentation/screens/splash_screen.dart';
import 'package:streetbite/presentation/widgets/hot_offers.dart';
import 'package:streetbite/presentation/widgets/meal_card.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class FakeAuthRepository implements AuthRepository {
  AppUser? signedInUser;
  bool failLogin = false;

  @override
  AppUser? get currentUser => signedInUser;

  @override
  Future<AppUser> signIn(String email, String password) async {
    if (failLogin) {
      throw const AuthFailure(AuthFailureType.invalidCredentials);
    }
    return signedInUser = AppUser(id: 'uid-1', fullName: 'Sara', email: email);
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async =>
      signedInUser = AppUser(id: 'uid-1', fullName: name, email: email);

  @override
  Future<void> signOut() async => signedInUser = null;
}

AuthCubit makeCubit(FakeAuthRepository repository) => AuthCubit(
  repository,
  SignIn(repository),
  SignUp(repository),
  SignOut(repository),
);

class FakeMealRepository implements MealRepository {
  @override
  Future<List<Meal>> getCachedMeals() async => [];

  @override
  Future<List<Meal>> refreshMeals() async => List.generate(
    9,
    (index) => Meal(
      id: '$index',
      name: 'Meal $index',
      category: 'Dinner',
      imageUrl: '',
      area: '',
      instructions: '',
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  test(
    'authentication errors stay on the form with a friendly message',
    () async {
      final repository = FakeAuthRepository()..failLogin = true;
      final cubit = makeCubit(repository);

      await cubit.logIn('sara@example.com', 'password');

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.message, AppStrings.invalidCredentials);
      expect(cubit.state.isBusy, false);
      await cubit.close();
    },
  );

  test('a restored user starts in the authenticated state', () async {
    final repository = FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara',
        email: 'sara@example.com',
      );
    final cubit = makeCubit(repository);

    await cubit.initialize();

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user?.fullName, 'Sara');
    await cubit.close();
  });

  testWidgets('sign-up link opens the form and shows inline errors', (
    tester,
  ) async {
    final cubit = makeCubit(FakeAuthRepository());
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.ensureVisible(find.text(AppStrings.createAccount));
    await tester.tap(find.text(AppStrings.createAccount));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 175));
    final signUpRoute = ModalRoute.of(
      tester.element(find.byType(SignupScreen)),
    );
    expect(signUpRoute, isA<PageRouteBuilder<void>>());
    expect(signUpRoute!.animation!.value, greaterThan(0));
    expect(signUpRoute.animation!.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.signUpTitle), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Basem');
    await tester.pump();
    expect(find.text(AppStrings.requiredEmail), findsNothing);
    expect(find.text(AppStrings.requiredPassword), findsNothing);
    expect(find.text(AppStrings.requiredConfirmation), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(1), 'invalid');
    await tester.pump();
    expect(find.text(AppStrings.invalidEmail), findsOneWidget);
    expect(find.text(AppStrings.requiredPassword), findsNothing);
    await tester.enterText(find.byType(TextFormField).at(1), '');

    await tester.ensureVisible(find.text(AppStrings.signUp));
    await tester.tap(find.text(AppStrings.signUp));
    await tester.pump();
    expect(find.text(AppStrings.requiredName), findsNothing);
    expect(find.text(AppStrings.requiredEmail), findsOneWidget);
    expect(find.text(AppStrings.requiredPassword), findsOneWidget);
    expect(find.text(AppStrings.requiredConfirmation), findsOneWidget);

    await tester.ensureVisible(find.text(AppStrings.logIn));
    await tester.tap(find.text(AppStrings.logIn));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 175));
    expect(signUpRoute.animation!.value, greaterThan(0));
    expect(signUpRoute.animation!.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await cubit.close();
  });

  testWidgets('auth screens fit two compact phone sizes without overflow', (
    tester,
  ) async {
    final cubit = makeCubit(FakeAuthRepository());
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final size in [const Size(327, 707), const Size(360, 640)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Image)).height, size.height / 2);
      expect(tester.takeException(), isNull);
    }

    await tester.ensureVisible(find.text(AppStrings.createAccount));
    await tester.tap(find.text(AppStrings.createAccount));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(Image)).height, 640 * 0.45);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  testWidgets('tapping the splash fades into login', (tester) async {
    final cubit = makeCubit(FakeAuthRepository());
    locator.registerSingleton<AuthCubit>(cubit);
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.tap(find.byType(SplashScreen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 225));

    final loginFade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byType(LoginScreen),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(loginFade.opacity.value, greaterThan(0));
    expect(loginFade.opacity.value, lessThan(1));

    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 1300));
  });

  testWidgets('completed sign-up reaches the authenticated home screen', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final cubit = makeCubit(repository);
    locator.registerSingleton<AuthCubit>(cubit);
    locator.registerFactory<MenuCubit>(() => MenuCubit(FakeMealRepository()));
    addTearDown(() async {
      await locator.reset();
    });

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(AppStrings.createAccount));
    await tester.tap(find.text(AppStrings.createAccount));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sara Ali');
    await tester.enterText(fields.at(1), 'sara@example.com');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret1');
    await tester.ensureVisible(find.text(AppStrings.signUp));
    await tester.tap(find.text(AppStrings.signUp));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Sara Ali'), findsNothing);
    await tester.tap(find.text(AppStrings.profile));
    await tester.pumpAndSettle();
    expect(find.text('Sara Ali'), findsOneWidget);
  });

  testWidgets('home tabs, theme toggle and cart work with live menu state', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(327, 707);
    final repository = FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    locator.registerSingleton<AuthCubit>(makeCubit(repository));
    locator.registerFactory<MenuCubit>(() => MenuCubit(FakeMealRepository()));
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.recommended), findsOneWidget);
    expect(find.text(AppStrings.hotOffers), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expect(find.byTooltip(AppStrings.favorites), findsOneWidget);
    expect(find.byTooltip(AppStrings.cart), findsOneWidget);
    expect(find.text('Sara Ali'), findsNothing);
    expect(find.text(AppStrings.hotFlag), findsWidgets);
    expect(
      tester.widget<Text>(find.text(AppStrings.recommended)).style?.fontFamily,
      AppTheme.sectionFont,
    );
    expect(
      Theme.of(tester.element(find.byType(HomeScreen)))
          .textTheme
          .bodyMedium
          ?.fontFamily,
      AppTheme.bodyFont,
    );
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(360, 640);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(327, 707);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(AppStrings.darkMode));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    final darkTheme = Theme.of(tester.element(find.byType(HomeScreen)));
    expect(
      tester.widget<Text>(find.text(AppStrings.recommended)).style?.color,
      darkTheme.colorScheme.onSurface,
    );
    final offersList = find.descendant(
      of: find.byType(HotOffers),
      matching: find.byType(ListView),
    );
    expect(tester.getSize(offersList).width, 327);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final mealCard = find.descendant(
      of: find.byType(MealCard).first,
      matching: find.byType(Card),
    );
    expect(tester.widget<Card>(mealCard).color, AppTheme.darkCard);
    await tester.tap(find.text(AppStrings.addToCart).first);
    await tester.pump();
    expect(find.text(AppStrings.mealAdded), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.cart));
    await tester.pumpAndSettle();
    expect(find.text('Meal 0'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.browse).last);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.searchMeals), findsOneWidget);
    await tester.tap(find.text(AppStrings.orders).last);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noOrders), findsOneWidget);
    await tester.tap(find.text(AppStrings.profile).last);
    await tester.pumpAndSettle();
    expect(find.text('sara@example.com'), findsOneWidget);
  });
}
