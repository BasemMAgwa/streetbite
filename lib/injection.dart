import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/card_payment_method.dart';
import 'data/datasources/cash_payment_method.dart';
import 'data/datasources/firestore_service.dart';
import 'data/datasources/meal_local_data_source.dart';
import 'data/datasources/meal_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/biometric_repository_impl.dart';
import 'data/repositories/device_info_repository_impl.dart';
import 'data/repositories/favourites_repository_impl.dart';
import 'data/repositories/meal_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/security_settings_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/biometric_repository.dart';
import 'domain/repositories/device_info_repository.dart';
import 'domain/repositories/favourites_repository.dart';
import 'domain/repositories/meal_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/repositories/security_settings_repository.dart';
import 'domain/usecases/authenticate_with_biometrics.dart';
import 'domain/usecases/get_device_details.dart';
import 'domain/usecases/place_order.dart';
import 'domain/usecases/sign_in.dart';
import 'domain/usecases/sign_out.dart';
import 'domain/usecases/sign_up.dart';
import 'domain/usecases/update_profile_photo.dart';
import 'presentation/blocs/auth_cubit.dart';
import 'presentation/blocs/checkout_cubit.dart';
import 'presentation/blocs/menu_cubit.dart';
import 'presentation/blocs/orders_cubit.dart';
import 'presentation/blocs/profile_cubit.dart';
import 'presentation/blocs/profile_lock_cubit.dart';

final locator = GetIt.instance;

// Dependency injection gives blocs and use cases repository contracts instead
// of concrete Firebase or device services. GetIt owns shared service lifetimes.
void configureDependencies() {
  locator.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://www.themealdb.com/api/json/v1/1/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
  );
  locator.registerLazySingleton(() => SharedPreferencesAsync());
  locator.registerLazySingleton(() => MealRemoteDataSource(locator()));
  locator.registerLazySingleton(() => MealLocalDataSource(locator()));
  locator.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(locator(), locator()),
  );
  locator.registerFactory(() => MenuCubit(locator()));
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  locator.registerLazySingleton<FavouritesRepository>(
    () => FavouritesRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(locator()),
  );
  locator.registerFactoryParam<OrdersCubit, String, void>(
    (userId, _) => OrdersCubit(locator(), userId),
  );
  locator.registerLazySingleton(() => PlaceOrder(locator()));
  locator.registerFactoryParam<CheckoutCubit, String, void>(
    (userId, _) => CheckoutCubit(locator(), userId, const [
      CashPaymentMethod(),
      CardPaymentMethod(),
    ]),
  );
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(locator(), locator()),
  );
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator()),
  );
  locator.registerLazySingleton(() => SignIn(locator()));
  locator.registerLazySingleton(() => SignUp(locator()));
  locator.registerLazySingleton(() => SignOut(locator()));
  locator.registerFactory(
    () => AuthCubit(locator(), locator(), locator(), locator()),
  );
  locator.registerLazySingleton<FirestoreService>(
    () => FirestoreService(locator()),
  );
  locator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(locator()),
  );
  locator.registerLazySingleton(() => UpdateProfilePhoto(locator()));
  locator.registerLazySingleton<DeviceInfoRepository>(
    () => DeviceInfoRepositoryImpl(DeviceInfoPlugin()),
  );
  locator.registerLazySingleton(() => GetDeviceDetails(locator()));
  locator.registerLazySingleton<BiometricRepository>(
    () => BiometricRepositoryImpl(LocalAuthentication()),
  );
  locator.registerLazySingleton(() => AuthenticateWithBiometrics(locator()));
  locator.registerFactoryParam<ProfileCubit, String, void Function(String)>(
    (userId, onPhotoUploaded) => ProfileCubit(
      locator(),
      locator(),
      (uid) => locator<AuthRemoteDataSource>().storedPhoto(uid),
      userId,
      onPhotoUploaded: onPhotoUploaded,
    ),
  );
  locator.registerLazySingleton<SecuritySettingsRepository>(
    () => SecuritySettingsRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<ProfileLockCubit>(
    () => ProfileLockCubit(locator()),
  );
}
