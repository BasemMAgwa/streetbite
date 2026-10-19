import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:streetbite/core/constants/message.dart';
import 'package:streetbite/l10n/app_localizations.dart';

import 'package:streetbite/core/theme/app_theme.dart';
import 'package:streetbite/data/datasources/meal_local_data_source.dart';
import 'package:streetbite/data/datasources/meal_remote_data_source.dart';
import 'package:streetbite/data/models/meal_model.dart';
import 'package:streetbite/domain/entities/meal.dart';
import 'package:streetbite/domain/entities/meal_failure.dart';
import 'package:streetbite/domain/repositories/meal_repository.dart';
import 'package:streetbite/presentation/blocs/menu_cubit.dart';
import 'package:streetbite/presentation/blocs/menu_state.dart';
import 'package:streetbite/presentation/blocs/theme_bloc.dart';
import 'package:streetbite/presentation/blocs/theme_event.dart';
import 'package:streetbite/presentation/widgets/featured_meals.dart';

const meal = MealModel(
  id: '52772',
  name: 'Teriyaki Chicken',
  category: 'Chicken',
  imageUrl: 'https://example.com/meal.jpg',
  area: 'Japanese',
  instructions: 'Cook chicken.',
);

class OfflineMealRepository implements MealRepository {
  OfflineMealRepository({this.cached = const [meal]});

  final List<Meal> cached;

  @override
  Future<List<Meal>> getCachedMeals() async => cached;

  @override
  Future<List<Meal>> refreshMeals() async =>
      throw const MealFailure(MealFailureType.network);
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('saved meals are restored by a new local data source', () async {
    final preferences = SharedPreferencesAsync();
    await MealLocalDataSource(preferences).saveMeals([meal]);

    final restored = await MealLocalDataSource(preferences).loadMeals();
    expect(restored.single.id, meal.id);
    expect(restored.single.category, meal.category);
    expect(restored.single.instructions, meal.instructions);
  });

  test('remote data source parses the live menu response', () async {
    final dio = Dio(
      BaseOptions(baseUrl: 'https://www.themealdb.com/api/json/v1/1/'),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, 'search.php');
          expect(options.queryParameters['s'], '');
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {
                'meals': [meal.toJson()],
              },
            ),
          );
        },
      ),
    );

    final meals = await MealRemoteDataSource(dio).loadMeals();
    expect(meals.single.name, meal.name);
    expect(meals.single.category, meal.category);
  });

  test('known meals without an API area show a sourced origin', () {
    final jajek = MealModel.fromJson({
      'idMeal': '53436',
      'strMeal': 'Jajek',
      'strArea': '',
    });
    expect(jajek.area, 'Armenian');
    expect(jajek.rating, inInclusiveRange(4.0, 4.9));

    final unknown = MealModel.fromJson({
      'idMeal': 'unknown',
      'strMeal': 'Unknown meal',
      'strArea': '',
    });
    expect(unknown.area, isEmpty);
  });

  test('offline refresh keeps cached meals visible', () async {
    final cubit = MenuCubit(OfflineMealRepository());
    await cubit.loadMeals();

    expect(cubit.state.status, MenuStatus.ready);
    expect(cubit.state.meals.single.id, meal.id);
    expect(cubit.state.isCached, true);
    expect(cubit.state.message, AppMessage.networkError);
    await cubit.close();
  });

  test('offline refresh without cache shows a friendly error', () async {
    final cubit = MenuCubit(OfflineMealRepository(cached: []));
    await cubit.loadMeals();

    expect(cubit.state.status, MenuStatus.error);
    expect(cubit.state.message, AppMessage.networkError);
    await cubit.close();
  });

  test('theme selection persists across bloc creation', () async {
    final preferences = SharedPreferencesAsync();
    final theme = ThemeBloc(preferences);
    final dark = theme.stream.firstWhere((mode) => mode == ThemeMode.dark);
    theme.add(const ToggleTheme());
    await dark;
    expect(await preferences.getBool('streetbite_dark_theme'), true);
    await theme.close();

    final restored = ThemeBloc(preferences);
    final loaded = restored.stream.firstWhere((mode) => mode == ThemeMode.dark);
    restored.add(const LoadTheme());
    expect(await loaded, ThemeMode.dark);
    await restored.close();
  });

  testWidgets('featured banners keep an even gap', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    final meals = List.generate(
      4,
      (index) => Meal(
        id: '$index',
        name: 'Meal $index',
        category: 'Dinner',
        imageUrl: '',
        area: '',
        instructions: '',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: Scaffold(body: FeaturedMeals(meals)),
      ),
    );
    await tester.drag(find.byType(PageView), const Offset(-180, 0));
    await tester.pump(const Duration(milliseconds: 50));
    final cards = find.descendant(
      of: find.byType(FeaturedMeals),
      matching: find.byType(ClipRRect),
    );
    expect(cards, findsAtLeastNWidgets(2));
    final first = tester.getRect(cards.at(0));
    final second = tester.getRect(cards.at(1));
    expect(second.left - first.right, closeTo(16, 0.1));
    expect(first.width, greaterThan(360 * 0.94));
  });
}
