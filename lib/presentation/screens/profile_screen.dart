import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_strings.dart';
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
        listener: (context, state) => showAppSnackBar(context, state.message!),
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
                        Positioned(
                          right: 0,
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
                              tooltip: AppStrings.changePhoto,
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
                    const SizedBox(height: 16),
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
                              AppStrings.deviceCardTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_iphone, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${AppStrings.deviceModelLabel}: '
                                    '${state.deviceModel}',
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
                                      '${AppStrings.deviceOsLabel}: '
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
                      segments: [
                        ButtonSegment(
                          value: ProfileSection.favorites,
                          icon: _segmentIcon(
                            'assets/images/bookmark_icon.svg',
                            _section == ProfileSection.favorites,
                          ),
                          label: const Text(AppStrings.favorites),
                        ),
                        ButtonSegment(
                          value: ProfileSection.orders,
                          icon: _segmentIcon(
                            'assets/images/orders_icon.svg',
                            _section == ProfileSection.orders,
                          ),
                          label: const Text(AppStrings.orders),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (previous, current) =>
                      previous.isBusy != current.isBusy,
                  builder: (context, state) => FilledButton(
                    onPressed: state.isBusy
                        ? null
                        : context.read<AuthCubit>().logOut,
                    child: const Text(AppStrings.signOut),
                  ),
                ),
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
            return const Center(child: Text(AppStrings.noFavorites));
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
                child: Text(state.message!, textAlign: TextAlign.center),
              ),
              TextButton(
                onPressed: () => context.read<OrdersCubit>().load(),
                child: const Text(AppStrings.tryAgain),
              ),
            ],
          ),
        );
      }
      if (state.orders.isEmpty) {
        return const Center(child: Text(AppStrings.noOrders));
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        itemCount: state.orders.length,
        itemBuilder: (context, index) => OrderTile(state.orders[index]),
      );
    },
  );
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
