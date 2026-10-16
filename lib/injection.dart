import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/meal_local_data_source.dart';
import 'data/datasources/meal_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/meal_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/meal_repository.dart';
import 'domain/usecases/sign_in.dart';
import 'domain/usecases/sign_out.dart';
import 'domain/usecases/sign_up.dart';
import 'presentation/blocs/auth_cubit.dart';
import 'presentation/blocs/menu_cubit.dart';

final locator = GetIt.instance;

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
}
