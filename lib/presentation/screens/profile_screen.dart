import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../injection.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';
import '../blocs/favourites_cubit.dart';
import '../blocs/favourites_state.dart';
import '../blocs/orders_cubit.dart';
import '../blocs/orders_state.dart';
import '../blocs/profile_cubit.dart';
import '../blocs/profile_state.dart';
import '../blocs/locale_bloc.dart';
import '../blocs/locale_event.dart';
import '../blocs/theme_bloc.dart';
import '../blocs/theme_event.dart';
import '../l10n/message_localizations.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/favourite_meal_tile.dart';
import '../widgets/order_tile.dart';

enum ProfileSection { favorites, orders }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileSection _section = ProfileSection.favorites;

  Widget _segmentIcon(String asset, bool selected) => SvgPicture.asset(
    asset,
    width: 18,
    height: 18,
    colorFilter: ColorFilter.mode(
      selected ? AppTheme.green : AppTheme.muted,
      BlendMode.srcIn,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user!;
    return BlocProvider(
      create: (_) => locator<OrdersCubit>(param1: user.id)..load(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (_, current) => current.message != null,
        listener: (context, state) => showAppSnackBar(
          context,
          state.message!.text(AppLocalizations.of(context)),
        ),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        _Avatar(photoBytes: state.photoBytes),
                        PositionedDirectional(
                          end: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppTheme.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              tooltip: AppLocalizations.of(context).changePhoto,
                              onPressed: state.isUploading
                                  ? null
                                  : context.read<ProfileCubit>().pickPhoto,
                              icon: const Icon(Icons.camera_alt, size: 18),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(user.email, textAlign: TextAlign.center),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        tooltip: AppLocalizations.of(context).settings,
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => _SettingsSheet.open(context),
                      ),
                    ),
                    if (state.deviceModel != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor(Theme.of(context)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.fromBorderSide(
                            AppTheme.cardBorder(Theme.of(context)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).deviceCardTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_iphone, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${AppLocalizations.of(context).deviceModelLabel}: '
                                    '${state.deviceModel ?? AppLocalizations.of(context).unknownDetail}',
                                  ),
                                ),
                              ],
                            ),
                            if (state.deviceOs!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.memory, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${AppLocalizations.of(context).deviceOsLabel}: '
                                      '${state.deviceOs}',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SegmentedButton<ProfileSection>(
                      expandedInsets: EdgeInsets.zero,
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ProfileSection.favorites,
                          icon: _segmentIcon(
                            'assets/images/heart_icon.svg',
                            _section == ProfileSection.favorites,
                          ),
                          label: Text(AppLocalizations.of(context).favorites),
                        ),
                        ButtonSegment(
                          value: ProfileSection.orders,
                          icon: _segmentIcon(
                            'assets/images/orders_icon.svg',
                            _section == ProfileSection.orders,
                          ),
                          label: Text(AppLocalizations.of(context).orders),
                        ),
                      ],
                      selected: {_section},
                      onSelectionChanged: (selection) =>
                          setState(() => _section = selection.first),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _section == ProfileSection.favorites
                    ? const _FavoritesList()
                    : const _OrdersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FavouritesCubit, FavouritesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.meals.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context).noFavorites),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
      );
}

class _OrdersList extends StatelessWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context) => BlocBuilder<OrdersCubit, OrdersState>(
    builder: (context, state) {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.message != null && state.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.message!.text(AppLocalizations.of(context)),
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () => context.read<OrdersCubit>().load(),
                child: Text(AppLocalizations.of(context).tryAgain),
              ),
            ],
          ),
        );
      }
      if (state.orders.isEmpty) {
        return Center(child: Text(AppLocalizations.of(context).noOrders));
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        itemCount: state.orders.length,
        itemBuilder: (context, index) => OrderTile(state.orders[index]),
      );
    },
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  static void open(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => const _SettingsSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = context.watch<LocaleBloc>().state.languageCode;
    final mode = context.watch<ThemeBloc>().state;
    final isDark = mode == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            expandedInsets: EdgeInsets.zero,
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ButtonSegment(value: 'ar', label: Text(l10n.languageArabic)),
            ],
            selected: {code},
            onSelectionChanged: (selection) => context.read<LocaleBloc>().add(
              ChangeLocale(Locale(selection.first)),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            expandedInsets: EdgeInsets.zero,
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text(l10n.lightMode),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text(l10n.darkMode),
              ),
            ],
            selected: {isDark},
            onSelectionChanged: (selection) {
              if (selection.first != isDark) {
                context.read<ThemeBloc>().add(const ToggleTheme());
              }
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) => previous.isBusy != current.isBusy,
            builder: (context, state) => FilledButton(
              onPressed: state.isBusy
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      context.read<AuthCubit>().logOut();
                    },
              child: Text(l10n.signOut),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.photoBytes});

  final Uint8List? photoBytes;

  @override
  Widget build(BuildContext context) {
    final bytes = photoBytes;
    return CircleAvatar(
      radius: 44,
      backgroundImage: bytes == null ? null : MemoryImage(bytes),
      child: bytes == null ? const Icon(Icons.person, size: 44) : null,
    );
  }
}
