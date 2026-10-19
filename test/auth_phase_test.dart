import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetbite/app.dart';
import 'package:streetbite/core/constants/app_strings.dart';
import 'package:streetbite/core/theme/app_theme.dart';
import 'package:streetbite/domain/entities/app_user.dart';
import 'package:streetbite/domain/entities/biometric_result.dart';
import 'package:streetbite/domain/entities/device_details.dart';
import 'package:streetbite/data/datasources/cash_payment_method.dart';
import 'package:streetbite/data/datasources/cart_local_data_source.dart';
import 'package:streetbite/data/datasources/vendor_locations.dart';
import 'package:streetbite/domain/entities/auth_failure.dart';
import 'package:streetbite/domain/entities/cart_item.dart';
import 'package:streetbite/domain/entities/favourites_failure.dart';
import 'package:streetbite/domain/entities/meal.dart';
import 'package:streetbite/domain/entities/order.dart';
import 'package:streetbite/domain/repositories/auth_repository.dart';
import 'package:streetbite/domain/repositories/biometric_repository.dart';
import 'package:streetbite/domain/repositories/device_info_repository.dart';
import 'package:streetbite/domain/repositories/favourites_repository.dart';
import 'package:streetbite/domain/repositories/meal_repository.dart';
import 'package:streetbite/domain/repositories/order_repository.dart';
import 'package:streetbite/domain/repositories/profile_repository.dart';
import 'package:streetbite/domain/repositories/security_settings_repository.dart';
import 'package:streetbite/domain/usecases/authenticate_with_biometrics.dart';
import 'package:streetbite/domain/usecases/get_device_details.dart';
import 'package:streetbite/domain/usecases/place_order.dart';
import 'package:streetbite/domain/usecases/sign_in.dart';
import 'package:streetbite/domain/usecases/sign_out.dart';
import 'package:streetbite/domain/usecases/sign_up.dart';
import 'package:streetbite/domain/usecases/update_profile_photo.dart';
import 'package:streetbite/injection.dart';
import 'package:streetbite/presentation/blocs/auth_cubit.dart';
import 'package:streetbite/presentation/blocs/auth_state.dart';
import 'package:streetbite/presentation/blocs/checkout_cubit.dart';
import 'package:streetbite/presentation/blocs/favourites_cubit.dart';
import 'package:streetbite/presentation/blocs/menu_cubit.dart';
import 'package:streetbite/presentation/blocs/orders_cubit.dart';
import 'package:streetbite/presentation/blocs/profile_cubit.dart';
import 'package:streetbite/presentation/blocs/profile_lock_cubit.dart';
import 'package:streetbite/presentation/screens/login_screen.dart';
import 'package:streetbite/presentation/screens/home_screen.dart';
import 'package:streetbite/presentation/screens/meal_details_screen.dart';
import 'package:streetbite/presentation/screens/signup_screen.dart';
import 'package:streetbite/presentation/screens/splash_screen.dart';
import 'package:streetbite/presentation/screens/vendor_map_screen.dart';
import 'package:streetbite/presentation/widgets/hot_offers.dart';
import 'package:streetbite/presentation/widgets/home_menu_shimmer.dart';
import 'package:streetbite/presentation/widgets/meal_card.dart';
import 'package:streetbite/presentation/widgets/meal_image.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class FakeOrderRepository implements OrderRepository {
  @override
  Future<String> placeOrder(Order order) async => 'order-1';

  @override
  Stream<List<Order>> watchOrders(String userId) => Stream.value([]);
}

class FakeBiometricRepository implements BiometricRepository {
  BiometricResult result = BiometricResult.success;

  @override
  Future<BiometricResult> authenticate() async => result;
}

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<void> updatePhoto(String userId, Uint8List bytes) async {}
}

class FakeDeviceInfoRepository implements DeviceInfoRepository {
  @override
  Future<DeviceDetails> load() async =>
      const DeviceDetails(model: 'Pixel 8', osVersion: 'Android 14');
}

class FakeSecuritySettingsRepository implements SecuritySettingsRepository {
  FakeSecuritySettingsRepository([this.enabled = true]);

  bool enabled;

  @override
  Future<bool> loadProfileLock() async => enabled;

  @override
  Future<void> saveProfileLock(bool value) async => enabled = value;
}

void registerProfileLockDependencies({bool enabled = true}) {
  locator.registerLazySingleton<SecuritySettingsRepository>(
    () => FakeSecuritySettingsRepository(enabled),
  );
  locator.registerLazySingleton<ProfileLockCubit>(
    () => ProfileLockCubit(locator()),
  );
}

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
  FakeMealRepository({this.longInstructions = false});

  final bool longInstructions;

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
      instructions: longInstructions
          ? List.filled(30, 'Prepare the meal and serve it fresh.').join(' ')
          : '',
    ),
  );
}

class PendingMealRepository extends FakeMealRepository {
  final result = Completer<List<Meal>>();

  @override
  Future<List<Meal>> refreshMeals() => result.future;
}

class FakeFavouritesRepository implements FavouritesRepository {
  final saved = <Meal>[];
  final changes = StreamController<List<Meal>>.broadcast();
  bool failAdd = false;
  Completer<void>? pendingAdd;

  @override
  Stream<List<Meal>> watchFavourites(String userId) async* {
    yield List.of(saved);
    yield* changes.stream;
  }

  @override
  Future<void> addFavourite(String userId, Meal meal) async {
    await pendingAdd?.future;
    if (failAdd) {
      throw const FavouritesFailure(FavouritesFailureType.network);
    }
    saved.add(meal);
    changes.add(List.of(saved));
  }

  @override
  Future<void> removeFavourite(String userId, String mealId) async {
    saved.removeWhere((meal) => meal.id == mealId);
    changes.add(List.of(saved));
  }
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  testWidgets('saved cart count appears when a signed-in user returns', (
    tester,
  ) async {
    final meal = const Meal(
      id: '0',
      name: 'Meal 0',
      category: 'Dinner',
      imageUrl: '',
      area: 'Turkish',
      instructions: '',
    );
    await CartLocalDataSource(SharedPreferencesAsync())
        .save('uid-1', [CartItem.fromMeal(meal).withQuantity(2)]);
    final auth = FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    locator.registerSingleton<AuthCubit>(makeCubit(auth));
    registerProfileLockDependencies();
    locator.registerFactory<MenuCubit>(() => MenuCubit(FakeMealRepository()));
    locator.registerSingleton<FavouritesRepository>(FakeFavouritesRepository());
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    final badge = find.ancestor(
      of: find.byTooltip(AppStrings.cart),
      matching: find.byType(Badge),
    );
    expect(tester.widget<Badge>(badge).isLabelVisible, true);
    expect(
      find.descendant(of: badge, matching: find.text('2')),
      findsOneWidget,
    );
  });
  test('favourites show a friendly network error and stay unchanged', () async {
    final repository = FakeFavouritesRepository()..failAdd = true;
    final cubit = FavouritesCubit(repository, 'uid-1')..load();
    await cubit.stream.firstWhere((state) => !state.isLoading);

    await cubit.toggle(
      const Meal(
        id: '1',
        name: 'Meal',
        category: 'Dinner',
        imageUrl: '',
        area: '',
        instructions: '',
      ),
    );

    expect(cubit.state.message, AppStrings.networkError);
    expect(cubit.state.isSaving, false);
    expect(repository.saved, isEmpty);
    await cubit.close();
    await repository.changes.close();
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
    registerProfileLockDependencies();
    locator.registerFactory<MenuCubit>(() => MenuCubit(FakeMealRepository()));
    locator.registerSingleton<FavouritesRepository>(FakeFavouritesRepository());
    locator.registerSingleton<BiometricRepository>(FakeBiometricRepository());
    locator.registerLazySingleton(() => AuthenticateWithBiometrics(locator()));
    locator.registerLazySingleton<ProfileRepository>(FakeProfileRepository.new);
    locator.registerLazySingleton(() => UpdateProfilePhoto(locator()));
    locator.registerLazySingleton<DeviceInfoRepository>(
      FakeDeviceInfoRepository.new,
    );
    locator.registerLazySingleton(() => GetDeviceDetails(locator()));
    locator.registerFactoryParam<ProfileCubit, String, void Function(String)>(
      (userId, onPhoto) => ProfileCubit(
        UpdateProfilePhoto(locator()),
        GetDeviceDetails(locator()),
        (_) async => null,
        userId,
        onPhotoUploaded: onPhoto,
      ),
    );
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
    registerProfileLockDependencies();
    locator.registerFactory<MenuCubit>(() => MenuCubit(FakeMealRepository()));
    locator.registerSingleton<FavouritesRepository>(FakeFavouritesRepository());
    locator.registerSingleton<BiometricRepository>(FakeBiometricRepository());
    locator.registerLazySingleton(() => AuthenticateWithBiometrics(locator()));
    locator.registerLazySingleton<ProfileRepository>(FakeProfileRepository.new);
    locator.registerLazySingleton(() => UpdateProfilePhoto(locator()));
    locator.registerLazySingleton<DeviceInfoRepository>(
      FakeDeviceInfoRepository.new,
    );
    locator.registerLazySingleton(() => GetDeviceDetails(locator()));
    locator.registerFactoryParam<ProfileCubit, String, void Function(String)>(
      (userId, onPhoto) => ProfileCubit(
        UpdateProfilePhoto(locator()),
        GetDeviceDetails(locator()),
        (_) async => null,
        userId,
        onPhotoUploaded: onPhoto,
      ),
    );
    locator.registerFactoryParam<OrdersCubit, String, void>(
      (userId, _) => OrdersCubit(FakeOrderRepository(), userId),
    );
    locator.registerFactoryParam<CheckoutCubit, String, void>(
      (userId, _) => CheckoutCubit(
        PlaceOrder(FakeOrderRepository()),
        userId,
        const [CashPaymentMethod()],
      ),
    );
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
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.byTooltip(AppStrings.close));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.vendors).last);
    await tester.pumpAndSettle();
    expect(find.byType(VendorMapScreen), findsOneWidget);
    expect(find.text(AppStrings.nearbyVendors), findsOneWidget);
    final vendorMarkers = tester
        .widget<GoogleMap>(find.byType(GoogleMap))
        .markers;
    expect(VendorLocations.all.map((vendor) => vendor.city).toSet().length, 6);
    expect(vendorMarkers.length, VendorLocations.all.length);
    for (final vendor in VendorLocations.all) {
      final marker = vendorMarkers.singleWhere(
        (marker) => marker.markerId.value == vendor.id,
      );
      expect(marker.infoWindow.title, contains(vendor.name));
      expect(marker.infoWindow.snippet, contains(vendor.cuisine));
      expect(marker.infoWindow.snippet, contains('★'));
      expect(
        marker.infoWindow.snippet,
        contains(vendor.rating.toStringAsFixed(1)),
      );
    }
    await tester.tap(find.text(AppStrings.orders).last);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noOrders), findsOneWidget);
    await tester.tap(find.text(AppStrings.profile).last);
    await tester.pumpAndSettle();
    expect(find.text('sara@example.com'), findsOneWidget);
  });

  testWidgets('home shows shimmer until the live menu arrives', (tester) async {
    final repository = FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    final meals = PendingMealRepository();
    locator.registerSingleton<AuthCubit>(makeCubit(repository));
    registerProfileLockDependencies();
    locator.registerFactory<MenuCubit>(() => MenuCubit(meals));
    locator.registerSingleton<FavouritesRepository>(FakeFavouritesRepository());
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump();

    expect(find.byType(HomeMenuShimmer), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);

    meals.result.complete(await FakeMealRepository().refreshMeals());
    await tester.pumpAndSettle();
    expect(find.byType(HomeMenuShimmer), findsNothing);
    expect(find.text(AppStrings.recommended), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.liveMenu), findsOneWidget);
  });

  testWidgets('meal details save a favourite and keep the top actions', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(327, 707);
    final auth = FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    final favourites = FakeFavouritesRepository()
      ..pendingAdd = Completer<void>();
    locator.registerSingleton<AuthCubit>(makeCubit(auth));
    registerProfileLockDependencies();
    locator.registerFactory<MenuCubit>(
      () => MenuCubit(FakeMealRepository(longInstructions: true)),
    );
    locator.registerSingleton<FavouritesRepository>(favourites);
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meal 0').first);
    await tester.pumpAndSettle();

    expect(find.byType(MealDetailsScreen), findsOneWidget);
    final route = ModalRoute.of(tester.element(find.byType(MealDetailsScreen)));
    expect((route?.settings.arguments as Meal).id, '0');
    expect(find.byTooltip(AppStrings.darkMode), findsOneWidget);
    expect(find.byTooltip(AppStrings.favorites), findsOneWidget);
    expect(find.byTooltip(AppStrings.cart), findsOneWidget);
    expect(find.text(AppStrings.category), findsOneWidget);
    expect(find.text(AppStrings.origin), findsOneWidget);
    expect(find.text(AppStrings.instructions), findsOneWidget);
    final detailsScaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(MealDetailsScreen),
        matching: find.byType(Scaffold),
      ),
    );
    expect(detailsScaffold.extendBodyBehindAppBar, true);
    expect(
      (detailsScaffold.appBar! as AppBar).backgroundColor,
      Colors.transparent,
    );
    final heroImage = find.descendant(
      of: find.byType(MealDetailsScreen),
      matching: find.byType(MealImage),
    );
    expect(tester.getTopLeft(heroImage).dy, 0);
    final topBar = find.descendant(
      of: find.byType(MealDetailsScreen),
      matching: find.byType(AppBar),
    );
    expect(tester.widget<AppBar>(topBar).foregroundColor, Colors.white);
    expect(
      tester
          .element(find.byType(MealDetailsScreen))
          .read<FavouritesCubit>()
          .state
          .isLoading,
      false,
    );

    await tester.tap(find.text(AppStrings.addToFavorites));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(favourites.saved, isEmpty);
    favourites.pendingAdd!.complete();
    await tester.pumpAndSettle();
    expect(favourites.saved.single.id, '0');
    expect(find.text(AppStrings.removeFromFavorites), findsOneWidget);
    final favoritesBadge = find.ancestor(
      of: find.byTooltip(AppStrings.favorites),
      matching: find.byType(Badge),
    );
    expect(tester.widget<Badge>(favoritesBadge).isLabelVisible, true);
    expect(
      find.descendant(of: favoritesBadge, matching: find.text('1')),
      findsOneWidget,
    );

    await tester.drag(
      find.descendant(
        of: find.byType(MealDetailsScreen),
        matching: find.byType(ListView),
      ),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppBar>(topBar).foregroundColor,
      Theme.of(tester.element(topBar)).appBarTheme.foregroundColor,
    );
    expect(
      tester.widget<AppBar>(topBar).backgroundColor,
      Theme.of(tester.element(topBar)).scaffoldBackgroundColor,
    );
    await tester.drag(
      find.descendant(
        of: find.byType(MealDetailsScreen),
        matching: find.byType(ListView),
      ),
      const Offset(0, 400),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<AppBar>(topBar).foregroundColor, Colors.white);

    await tester.tap(find.text(AppStrings.addToCart));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(AppStrings.mealAdded), findsOneWidget);
    final cartBadge = find.ancestor(
      of: find.byTooltip(AppStrings.cart),
      matching: find.byType(Badge),
    );
    expect(tester.widget<Badge>(cartBadge).isLabelVisible, true);
    expect(
      tester.widget<Badge>(cartBadge).backgroundColor,
      AppTheme.badgeGreen,
    );
    expect(find.text(AppStrings.removeFromCart), findsOneWidget);

    await tester.tap(find.text(AppStrings.removeFromCart));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.addToCart), findsOneWidget);
    expect(tester.widget<Badge>(cartBadge).isLabelVisible, false);

    await tester.tap(find.byTooltip(AppStrings.favorites));
    await tester.pumpAndSettle();
    expect(find.text('Meal 0'), findsWidgets);
    expect(tester.takeException(), isNull);

    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.byTooltip(AppStrings.addToCart));
    await tester.pump();
    expect(tester.widget<Badge>(cartBadge).isLabelVisible, true);
    await tester.tap(find.byTooltip(AppStrings.removeFromFavorites));
    await tester.pumpAndSettle();
    expect(favourites.saved, isEmpty);
    expect(find.text(AppStrings.noFavorites), findsOneWidget);
    await tester.tap(find.byTooltip(AppStrings.close));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.addToFavorites), findsOneWidget);
    expect(tester.widget<Badge>(favoritesBadge).isLabelVisible, false);

    await tester.tap(find.byTooltip(AppStrings.back));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MealCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(MealDetailsScreen), findsOneWidget);
  });
}
