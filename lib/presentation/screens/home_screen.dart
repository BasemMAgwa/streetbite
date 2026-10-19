import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/message.dart';
import '../../l10n/app_localizations.dart';
import '../l10n/message_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/repositories/favourites_repository.dart';
import '../../injection.dart';
import '../../domain/entities/biometric_result.dart';
import '../../domain/usecases/authenticate_with_biometrics.dart';
import '../blocs/favourites_cubit.dart';
import '../blocs/favourites_state.dart';
import '../blocs/menu_cubit.dart';
import '../blocs/menu_state.dart';
import '../blocs/orders_cubit.dart';
import '../blocs/profile_cubit.dart';
import '../blocs/profile_lock_cubit.dart';
import '../blocs/auth_cubit.dart';
import '../widgets/app_header_actions.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/featured_meals.dart';
import '../widgets/hot_offers.dart';
import '../widgets/home_menu_shimmer.dart';
import '../widgets/menu_grid.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'vendor_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => locator<MenuCubit>()..loadMeals()),
      BlocProvider(create: (_) => locator<ProfileLockCubit>()..load()),
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
      listener: (context, state) => showAppSnackBar(
        context,
        state.message!.text(AppLocalizations.of(context)),
      ),
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
  bool _unlockingProfile = false;

  Future<void> _openProfile() async {
    if (_unlockingProfile) return;
    if (!context.read<ProfileLockCubit>().state) {
      setState(() => _tab = 3);
      return;
    }
    setState(() => _unlockingProfile = true);
    final reason = AppLocalizations.of(context).biometricReason;
    final result = await locator<AuthenticateWithBiometrics>()(reason);
    if (!mounted) return;
    setState(() => _unlockingProfile = false);
    final l10n = AppLocalizations.of(context);
    switch (result) {
      case BiometricResult.success:
        setState(() => _tab = 3);
      case BiometricResult.cancelled:
        showAppSnackBar(context, AppMessage.biometricCancelled.text(l10n));
      case BiometricResult.unavailable:
        showAppSnackBar(context, AppMessage.biometricUnavailable.text(l10n));
      case BiometricResult.failed:
        showAppSnackBar(context, AppMessage.biometricFailed.text(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<ProfileLockCubit, bool>(
      listener: (context, enabled) {
        if (enabled && _tab == 3) setState(() => _tab = 0);
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [ThemeToggleButton(), LanguageToggleButton()],
          ),
          actions: const [BiometricLockButton(), AppHeaderActions()],
        ),
        body: switch (_tab) {
          0 => const _HomeFeed(),
          1 => const VendorMapScreen(),
          2 => BlocProvider(
            create: (_) => locator<OrdersCubit>(
              param1: context.read<AuthCubit>().state.user!.id,
            )..load(),
            child: const OrdersScreen(),
          ),
          _ => BlocProvider(
            create: (_) => locator<ProfileCubit>(
              param1: context.read<AuthCubit>().state.user!.id,
              param2: context.read<AuthCubit>().updatePhoto,
            )..load(),
            child: const ProfileScreen(),
          ),
        },
        bottomNavigationBar: ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: BottomNavigationBar(
              currentIndex: _tab,
              onTap: (index) {
                if (index == 3 && _tab != 3) {
                  _openProfile();
                } else {
                  setState(() => _tab = index);
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.green,
              unselectedItemColor: AppTheme.muted,
              backgroundColor: Theme.of(context).colorScheme.surface,
              items: [
                BottomNavigationBarItem(
                  icon: _TabIcon('assets/images/home_icon.svg', AppTheme.muted),
                  activeIcon: _TabIcon(
                    'assets/images/home_icon.svg',
                    AppTheme.green,
                  ),
                  label: l10n.home,
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
                  label: l10n.vendors,
                ),
                BottomNavigationBarItem(
                  icon: _TabIcon(
                    'assets/images/orders_icon.svg',
                    AppTheme.muted,
                  ),
                  activeIcon: _TabIcon(
                    'assets/images/orders_icon.svg',
                    AppTheme.green,
                  ),
                  label: l10n.orders,
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
                  label: l10n.profile,
                ),
              ],
            ),
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
    final l10n = AppLocalizations.of(context);
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
                  state.message?.text(l10n) ?? l10n.menuUnavailable,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: context.read<MenuCubit>().loadMeals,
                  child: Text(l10n.tryAgain),
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
                    l10n.showingSavedMeals,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              _SectionTitle(l10n.recommended, horizontalPadding),
              FeaturedMeals(meals),
              const SizedBox(height: 20),
              _SectionTitle(l10n.hotOffers, horizontalPadding),
              HotOffers(meals, horizontalPadding: horizontalPadding),
              const SizedBox(height: 20),
              _SectionTitle(l10n.liveMenu, horizontalPadding),
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
