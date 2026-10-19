import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:streetbite/app.dart';
import 'package:streetbite/core/constants/message.dart';

import 'helpers/l10n.dart';

import 'package:streetbite/data/models/user_model.dart';
import 'package:streetbite/data/datasources/cash_payment_method.dart';
import 'package:streetbite/domain/entities/app_user.dart';
import 'package:streetbite/domain/entities/biometric_result.dart';
import 'package:streetbite/domain/entities/device_details.dart';
import 'package:streetbite/domain/entities/meal.dart';
import 'package:streetbite/domain/entities/order.dart';
import 'package:streetbite/domain/repositories/biometric_repository.dart';
import 'package:streetbite/domain/repositories/device_info_repository.dart';
import 'package:streetbite/domain/repositories/favourites_repository.dart';
import 'package:streetbite/domain/repositories/order_repository.dart';
import 'package:streetbite/domain/repositories/profile_repository.dart';
import 'package:streetbite/domain/repositories/security_settings_repository.dart';
import 'package:streetbite/domain/usecases/authenticate_with_biometrics.dart';
import 'package:streetbite/domain/usecases/get_device_details.dart';
import 'package:streetbite/domain/usecases/place_order.dart';
import 'package:streetbite/domain/usecases/update_profile_photo.dart';
import 'package:streetbite/injection.dart';
import 'package:streetbite/presentation/blocs/auth_cubit.dart';
import 'package:streetbite/presentation/blocs/checkout_cubit.dart';
import 'package:streetbite/presentation/blocs/menu_cubit.dart';
import 'package:streetbite/presentation/blocs/orders_cubit.dart';
import 'package:streetbite/presentation/blocs/profile_cubit.dart';
import 'package:streetbite/presentation/blocs/profile_lock_cubit.dart';
import 'package:streetbite/presentation/blocs/profile_state.dart';
import 'package:streetbite/presentation/screens/home_screen.dart';
import 'package:streetbite/presentation/screens/profile_screen.dart';

import 'auth_phase_test.dart'
    as earlier
    show
        FakeAuthRepository,
        FakeMealRepository,
        FakeSecuritySettingsRepository,
        makeCubit;

AuthCubit makeAuthCubit(earlier.FakeAuthRepository repository) =>
    earlier.makeCubit(repository);

class FakeProfileRepository implements ProfileRepository {
  Uint8List? savedBytes;
  Object? error;

  @override
  Future<void> updatePhoto(String userId, Uint8List bytes) async {
    final failure = error;
    if (failure != null) throw failure;
    savedBytes = bytes;
  }
}

class FakeDeviceInfoRepository implements DeviceInfoRepository {
  @override
  Future<DeviceDetails> load() async =>
      const DeviceDetails(model: 'Pixel 8', osVersion: 'Android 14');
}

class FakeBiometricRepository implements BiometricRepository {
  BiometricResult result = BiometricResult.success;
  int authenticateCalls = 0;

  @override
  Future<BiometricResult> authenticate(String localizedReason) async {
    authenticateCalls++;
    return result;
  }
}

class DelayedSecuritySettingsRepository implements SecuritySettingsRepository {
  final loadResult = Completer<bool>();
  bool? savedValue;

  @override
  Future<bool> loadProfileLock() => loadResult.future;

  @override
  Future<void> saveProfileLock(bool enabled) async {
    savedValue = enabled;
  }
}

// Minimal fakes used only so HomeScreen and its dependencies resolve.
class FakeOrderRepository implements OrderRepository {
  @override
  Future<String> placeOrder(Order order) async => 'order-1';

  @override
  Stream<List<Order>> watchOrders(String userId) => Stream.value([]);
}

class FakeFavouritesRepository implements FavouritesRepository {
  @override
  Stream<List<Meal>> watchFavourites(String userId) => Stream.value([]);

  @override
  Future<void> addFavourite(String userId, Meal meal) async {}

  @override
  Future<void> removeFavourite(String userId, String mealId) async {}
}

ProfileCubit makeCubit(
  FakeProfileRepository repository, {
  Future<String?> Function(String)? storedPhoto,
  void Function(String)? onPhotoUploaded,
  Future<Uint8List?> Function()? photoPicker,
  Future<Uint8List?> Function()? fileSelectorPicker,
}) => ProfileCubit(
  UpdateProfilePhoto(repository),
  GetDeviceDetails(FakeDeviceInfoRepository()),
  storedPhoto ?? (_) async => null,
  'uid-1',
  onPhotoUploaded: onPhotoUploaded,
  photoPicker: photoPicker,
  fileSelectorPicker: fileSelectorPicker,
);

void registerHomeDependencies({
  BiometricRepository? biometricRepository,
  bool profileLockEnabled = true,
}) {
  final biometrics = biometricRepository ?? FakeBiometricRepository();
  locator.registerSingleton<BiometricRepository>(biometrics);
  locator.registerLazySingleton(() => AuthenticateWithBiometrics(locator()));
  locator.registerLazySingleton<ProfileRepository>(FakeProfileRepository.new);
  locator.registerLazySingleton(() => UpdateProfilePhoto(locator()));
  locator.registerLazySingleton<DeviceInfoRepository>(
    FakeDeviceInfoRepository.new,
  );
  locator.registerLazySingleton(() => GetDeviceDetails(locator()));
  locator.registerFactoryParam<ProfileCubit, String, void Function(String)>(
    (userId, onPhotoUploaded) =>
        makeCubit(FakeProfileRepository(), onPhotoUploaded: onPhotoUploaded),
  );
  locator.registerLazySingleton<SecuritySettingsRepository>(
    () => earlier.FakeSecuritySettingsRepository(profileLockEnabled),
  );
  locator.registerLazySingleton<ProfileLockCubit>(
    () => ProfileLockCubit(locator()),
  );
  locator.registerFactory<MenuCubit>(
    () => MenuCubit(earlier.FakeMealRepository()),
  );
  locator.registerSingleton<FavouritesRepository>(FakeFavouritesRepository());
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
}

Future<ProfileState> firstNonUploading(ProfileCubit cubit) =>
    cubit.stream.firstWhere((state) => !state.isUploading);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  test('user model round trips with and without a photo', () {
    const withPhoto = UserModel(
      id: 'uid-1',
      fullName: 'Sara',
      email: 'sara@example.com',
      photoBase64: 'abc123',
    );
    expect(withPhoto.toJson(), containsPair('photoBase64', 'abc123'));
    final restored = UserModel.fromJson(withPhoto.toJson());
    expect(restored.photoBase64, 'abc123');

    const withoutPhoto = UserModel(
      id: 'uid-1',
      fullName: 'Sara',
      email: 'sara@example.com',
    );
    expect(withoutPhoto.toJson().containsKey('photoBase64'), isFalse);
    expect(UserModel.fromJson(withoutPhoto.toJson()).photoBase64, isNull);
  });

  test('load reads device details and a stored photo', () async {
    final cubit = makeCubit(
      FakeProfileRepository(),
      storedPhoto: (_) async => 'aGk=',
    );

    await cubit.load();

    expect(cubit.state.deviceModel, 'Pixel 8');
    expect(cubit.state.deviceOs, 'Android 14');
    expect(Uint8List.fromList('hi'.codeUnits), cubit.state.photoBytes);
    await cubit.close();
  });

  test(
    'picking a photo shows it at once, saves it, and syncs the user',
    () async {
      final repository = FakeProfileRepository();
      final uploaded = <String>[];
      final cubit = makeCubit(
        repository,
        onPhotoUploaded: uploaded.add,
        photoPicker: () async => Uint8List.fromList([1, 2, 3]),
      );
      final updates = <ProfileState>[];
      cubit.stream.listen(updates.add);

      await cubit.pickPhoto();

      expect(Uint8List.fromList([1, 2, 3]), cubit.state.photoBytes);
      expect(Uint8List.fromList([1, 2, 3]), repository.savedBytes);
      expect(uploaded.single, 'AQID');
      expect(cubit.state.isUploading, false);
      expect(cubit.state.message, AppMessage.photoUploaded);
      await cubit.close();
    },
  );

  test('Android picker falls back to the document picker', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final repository = FakeProfileRepository();
    final bytes = Uint8List.fromList([4, 5, 6]);
    final cubit = makeCubit(
      repository,
      photoPicker: () async => throw PlatformException(code: 'picker_error'),
      fileSelectorPicker: () async => bytes,
    );

    await cubit.pickPhoto();

    expect(repository.savedBytes, bytes);
    expect(cubit.state.photoBytes, bytes);
    expect(cubit.state.message, AppMessage.photoUploaded);
    await cubit.close();
  });

  test('a failed photo save reverts the bytes and shows a message', () async {
    final repository = FakeProfileRepository()..error = Exception('offline');
    final cubit = makeCubit(
      repository,
      photoPicker: () async => Uint8List.fromList([9]),
    );

    await cubit.pickPhoto();

    expect(cubit.state.photoBytes, isNull);
    expect(cubit.state.isUploading, false);
    expect(cubit.state.message, AppMessage.photoUploadError);
    expect(repository.savedBytes, isNull);
    await cubit.close();
  });

  testWidgets('profile tab opens on biometric success', (tester) async {
    final auth = earlier.FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    locator.registerSingleton<AuthCubit>(makeAuthCubit(auth));
    registerHomeDependencies();
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    await tester.tap(find.text(enL10n.profile).last);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('sara@example.com'), findsOneWidget);
  });

  testWidgets('profile tab stays closed on biometric failure', (tester) async {
    final auth = earlier.FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    locator.registerSingleton<AuthCubit>(makeAuthCubit(auth));
    registerHomeDependencies(
      biometricRepository: FakeBiometricRepository()
        ..result = BiometricResult.failed,
    );
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    await tester.tap(find.text(enL10n.profile).last);
    await tester.pump();
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(enL10n.biometricFailed), findsOneWidget);
  });

  test('toggling the lock flips the state and persists it', () async {
    final repository = earlier.FakeSecuritySettingsRepository(true);
    final cubit = ProfileLockCubit(repository);

    await cubit.toggle();

    expect(cubit.state, false);
    await cubit.close();

    final restored = ProfileLockCubit(repository)..load();
    await restored.stream.first;
    expect(restored.state, false);
    await restored.close();
  });

  test('a pending preference load does not undo a lock change', () async {
    final repository = DelayedSecuritySettingsRepository();
    final cubit = ProfileLockCubit(repository);
    final loading = cubit.load();

    await cubit.toggle();
    repository.loadResult.complete(true);
    await loading;

    expect(cubit.state, false);
    expect(repository.savedValue, false);
    await cubit.close();
  });

  testWidgets('enabling the lock closes an open profile and gates reentry', (
    tester,
  ) async {
    final auth = earlier.FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    locator.registerSingleton<AuthCubit>(makeAuthCubit(auth));
    final biometrics = FakeBiometricRepository();
    registerHomeDependencies(
      biometricRepository: biometrics,
      profileLockEnabled: false,
    );
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    await tester.tap(find.text(enL10n.profile).last);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(biometrics.authenticateCalls, 0);

    await tester.tap(find.byTooltip(enL10n.profileLockOffTooltip));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsNothing);

    await tester.tap(find.text(enL10n.profile).last);
    await tester.pumpAndSettle();
    expect(biometrics.authenticateCalls, 1);
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('lock off opens the profile without biometrics', (tester) async {
    final auth = earlier.FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    locator.registerSingleton<AuthCubit>(makeAuthCubit(auth));
    registerHomeDependencies(
      biometricRepository: FakeBiometricRepository()
        ..result = BiometricResult.failed,
      profileLockEnabled: false,
    );
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    await tester.tap(find.text(enL10n.profile).last);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('sara@example.com'), findsOneWidget);
  });

  testWidgets('profile toggles between favorites and orders lists', (
    tester,
  ) async {
    final auth = earlier.FakeAuthRepository()
      ..signedInUser = const AppUser(
        id: 'uid-1',
        fullName: 'Sara Ali',
        email: 'sara@example.com',
      );
    locator.registerSingleton<AuthCubit>(makeAuthCubit(auth));
    registerHomeDependencies(profileLockEnabled: false);
    addTearDown(() async => locator.reset());

    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    await tester.tap(find.text(enL10n.profile).last);
    await tester.pumpAndSettle();
    expect(find.text(enL10n.noFavorites), findsOneWidget);

    final ordersSegment = find.descendant(
      of: find.byType(SegmentedButton<ProfileSection>),
      matching: find.text(enL10n.orders),
    );
    await tester.tap(ordersSegment);
    await tester.pumpAndSettle();
    expect(find.text(enL10n.noOrders), findsOneWidget);
    expect(find.text(enL10n.noFavorites), findsNothing);

    final favoritesSegment = find.descendant(
      of: find.byType(SegmentedButton<ProfileSection>),
      matching: find.text(enL10n.favorites),
    );
    await tester.tap(favoritesSegment);
    await tester.pumpAndSettle();
    expect(find.text(enL10n.noFavorites), findsOneWidget);
  });
}
