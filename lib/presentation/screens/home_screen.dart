import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/repositories/favourites_repository.dart';
import '../../injection.dart';
import '../blocs/favourites_cubit.dart';
import '../blocs/favourites_state.dart';
import '../blocs/menu_cubit.dart';
import '../blocs/menu_state.dart';
import '../blocs/auth_cubit.dart';
import '../widgets/app_header_actions.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/featured_meals.dart';
import '../widgets/hot_offers.dart';
import '../widgets/home_menu_shimmer.dart';
import '../widgets/menu_grid.dart';
import 'placeholder_screen.dart';
import 'profile_screen.dart';
import 'vendor_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => locator<MenuCubit>()..loadMeals()),
      BlocProvider(
        lazy: false,
        create: (_) => FavouritesCubit(
          locator<FavouritesRepository>(),
          context.read<AuthCubit>().state.user!.id,
        )..load(),
      ),
    ],
    child: BlocListener<FavouritesCubit, FavouritesState>(
      listenWhen: (_, current) => current.message != null,
      listener: (context, state) => showAppSnackBar(context, state.message!),
      child: const _HomeView(),
    ),
  );
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: const ThemeToggleButton(),
        actions: const [AppHeaderActions()],
      ),
      body: switch (_tab) {
        0 => const _HomeFeed(),
        1 => const VendorMapScreen(),
        2 => const PlaceholderScreen(
          title: AppStrings.orders,
          message: AppStrings.noOrders,
          icon: Icons.receipt_long_outlined,
          showAppBar: false,
        ),
        _ => const ProfileScreen(),
      },
      bottomNavigationBar: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: BottomNavigationBar(
            currentIndex: _tab,
            onTap: (index) => setState(() => _tab = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.green,
            unselectedItemColor: AppTheme.muted,
            backgroundColor: Theme.of(context).colorScheme.surface,
            items: const [
              BottomNavigationBarItem(
                icon: _TabIcon('assets/images/home_icon.svg', AppTheme.muted),
                activeIcon: _TabIcon(
                  'assets/images/home_icon.svg',
                  AppTheme.green,
                ),
                label: AppStrings.home,
              ),
              BottomNavigationBarItem(
                icon: _TabIcon(
                  'assets/images/browse_icon.svg',
                  AppTheme.muted,
                ),
                activeIcon: _TabIcon(
                  'assets/images/browse_icon.svg',
                  AppTheme.green,
                ),
                label: AppStrings.vendors,
              ),
              BottomNavigationBarItem(
                icon: _TabIcon('assets/images/orders_icon.svg', AppTheme.muted),
                activeIcon: _TabIcon(
                  'assets/images/orders_icon.svg',
                  AppTheme.green,
                ),
                label: AppStrings.orders,
              ),
              BottomNavigationBarItem(
                icon: _TabIcon(
                  'assets/images/profile_icon.svg',
                  AppTheme.muted,
                ),
                activeIcon: _TabIcon(
                  'assets/images/profile_icon.svg',
                  AppTheme.green,
                ),
                label: AppStrings.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed();

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width < 360
        ? 16.0
        : 20.0;
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        if (state.status == MenuStatus.loading) {
          return HomeMenuShimmer(horizontalPadding: horizontalPadding);
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
                const SizedBox(height: 12),
                TextButton(
                  onPressed: context.read<MenuCubit>().loadMeals,
                  child: const Text(AppStrings.tryAgain),
                ),
              ],
            ),
          );
        }
        final meals = state.meals;
        return RefreshIndicator(
          onRefresh: context.read<MenuCubit>().loadMeals,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              if (state.message != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    AppStrings.showingSavedMeals,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              _SectionTitle(AppStrings.recommended, horizontalPadding),
              FeaturedMeals(meals),
              const SizedBox(height: 20),
              _SectionTitle(AppStrings.hotOffers, horizontalPadding),
              HotOffers(meals, horizontalPadding: horizontalPadding),
              const SizedBox(height: 20),
              _SectionTitle(AppStrings.liveMenu, horizontalPadding),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: MenuGrid(meals.take(6).toList()),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.horizontalPadding);

  final String title;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontFamily: AppTheme.sectionFont,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
}

class _TabIcon extends StatelessWidget {
  const _TabIcon(this.asset, this.color);

  final String asset;
  final Color color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: 24,
    height: 24,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}
