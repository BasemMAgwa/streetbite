import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/favourites_cubit.dart';
import '../blocs/favourites_state.dart';
import '../widgets/favourite_meal_tile.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  static void open(BuildContext context) {
    final favourites = context.read<FavouritesCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: BlocProvider.value(
          value: favourites,
          child: const FavouritesScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      titleSpacing: 0,
      title: const Text(
        AppStrings.favorites,
        style: TextStyle(
          fontFamily: AppTheme.sectionFont,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: AppStrings.close,
        icon: const Icon(Icons.chevron_left, size: 32),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: BlocBuilder<FavouritesCubit, FavouritesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.meals.isEmpty) {
          return const Center(child: Text(AppStrings.noFavorites));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.meals.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final meal = state.meals[index];
            return FavouriteMealTile(
              meal,
              onRemove: state.isSaving
                  ? null
                  : () => context.read<FavouritesCubit>().toggle(meal),
            );
          },
        );
      },
    ),
  );
}
