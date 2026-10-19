import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/cart_state.dart';
import '../blocs/favourites_cubit.dart';
import '../blocs/favourites_state.dart';
import '../blocs/profile_lock_cubit.dart';
import '../blocs/theme_bloc.dart';
import '../blocs/theme_event.dart';
import '../screens/cart_screen.dart';
import '../screens/favourites_screen.dart';
import 'app_snack_bar.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state == ThemeMode.dark;
    return IconButton(
      onPressed: () => context.read<ThemeBloc>().add(const ToggleTheme()),
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: iconColor ?? Theme.of(context).colorScheme.onSurface,
      ),
      tooltip: isDark ? AppStrings.lightMode : AppStrings.darkMode,
    );
  }
}

class BiometricLockButton extends StatelessWidget {
  const BiometricLockButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<ProfileLockCubit>().state;
    return IconButton(
      onPressed: () {
        context.read<ProfileLockCubit>().toggle();
        showAppSnackBar(
          context,
          enabled
              ? AppStrings.profileLockDisabled
              : AppStrings.profileLockEnabled,
        );
      },
      tooltip: enabled
          ? AppStrings.profileLockOnTooltip
          : AppStrings.profileLockOffTooltip,
      icon: Icon(
        enabled ? Icons.lock : Icons.lock_open,
        color: iconColor ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class AppHeaderActions extends StatelessWidget {
  const AppHeaderActions({
    super.key,
    this.showTheme = false,
    this.onFavoritesPage = false,
    this.iconColor,
  });

  final bool showTheme;
  final bool onFavoritesPage;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (showTheme) ThemeToggleButton(iconColor: iconColor),
      BlocBuilder<FavouritesCubit, FavouritesState>(
        builder: (context, state) => Badge(
          backgroundColor: AppTheme.badgeGreen,
          textColor: Colors.white,
          isLabelVisible: state.count > 0,
          offset: const Offset(-7, 4),
          label: Text('${state.count}'),
          child: IconButton(
            tooltip: AppStrings.favorites,
            color: iconColor,
            onPressed: () {
              if (onFavoritesPage) return;
              FavouritesScreen.open(context);
            },
            icon: Icon(
              onFavoritesPage ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ),
      ),
      BlocConsumer<CartBloc, CartState>(
        listenWhen: (previous, current) => current.count > previous.count,
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          showAppSnackBar(context, AppStrings.mealAdded);
        },
        builder: (context, state) => Badge(
          backgroundColor: AppTheme.badgeGreen,
          textColor: Colors.white,
          isLabelVisible: state.count > 0,
          offset: const Offset(-7, 4),
          label: Text('${state.count}'),
          child: IconButton(
            tooltip: AppStrings.cart,
            onPressed: () => CartScreen.open(context),
            icon: SvgPicture.asset(
              'assets/images/cart_icon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                iconColor ?? Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
    ],
  );
}
