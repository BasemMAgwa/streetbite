import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/app.dart';
import 'package:streetbite/core/constants/app_strings.dart';
import 'package:streetbite/domain/entities/app_user.dart';
import 'package:streetbite/domain/entities/auth_failure.dart';
import 'package:streetbite/domain/repositories/auth_repository.dart';
import 'package:streetbite/domain/usecases/sign_in.dart';
import 'package:streetbite/domain/usecases/sign_out.dart';
import 'package:streetbite/domain/usecases/sign_up.dart';
import 'package:streetbite/injection.dart';
import 'package:streetbite/presentation/blocs/auth_cubit.dart';
import 'package:streetbite/presentation/blocs/auth_state.dart';
import 'package:streetbite/presentation/screens/login_screen.dart';
import 'package:streetbite/presentation/screens/home_screen.dart';
import 'package:streetbite/presentation/screens/signup_screen.dart';
import 'package:streetbite/presentation/screens/splash_screen.dart';

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

void main() {
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
    expect(find.text('Sara Ali'), findsOneWidget);
  });
}
