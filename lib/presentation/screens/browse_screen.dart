import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/menu_cubit.dart';
import '../blocs/menu_state.dart';
import '../widgets/menu_grid.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        if (state.status == MenuStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == MenuStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message ?? AppStrings.menuUnavailable,
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: context.read<MenuCubit>().loadMeals,
                  child: const Text(AppStrings.tryAgain),
                ),
              ],
            ),
          );
        }
        final meals = state.meals
            .where(
              (meal) =>
                  meal.name.toLowerCase().contains(_query.toLowerCase()) ||
                  meal.category.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: AppStrings.searchMeals,
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.browseAll,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: AppTheme.sectionFont,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            MenuGrid(meals),
          ],
        );
      },
    );
  }
}
