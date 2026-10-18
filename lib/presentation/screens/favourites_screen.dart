import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../blocs/favourites_cubit.dart';
import '../blocs/favourites_state.dart';
import '../widgets/app_header_actions.dart';
import '../widgets/menu_grid.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(AppStrings.favorites),
      actions: const [AppHeaderActions(showTheme: true, onFavoritesPage: true)],
    ),
    body: BlocBuilder<FavouritesCubit, FavouritesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.meals.isEmpty) {
          return const Center(child: Text(AppStrings.noFavorites));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [MenuGrid(state.meals)],
        );
      },
    ),
  );
}
