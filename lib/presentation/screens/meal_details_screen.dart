import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../core/formatting/price_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/meal.dart';
import '../blocs/favourites_cubit.dart';
import '../blocs/favourites_state.dart';
import '../widgets/app_header_actions.dart';
import '../widgets/cart_toggle_button.dart';
import '../widgets/meal_image.dart';

class MealDetailsScreen extends StatefulWidget {
  const MealDetailsScreen({super.key});

  static void open(BuildContext context, Meal meal) {
    final favourites = context.read<FavouritesCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/meal-details', arguments: meal),
        builder: (_) => BlocProvider.value(
          value: favourites,
          child: const MealDetailsScreen(),
        ),
      ),
    );
  }

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _pastImage = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateTopBar);
  }

  void _updateTopBar() {
    final imageBelowTopBar = (MediaQuery.sizeOf(context).width * 0.7).clamp(
      220.0,
      320.0,
    );
    final pastImage = _scrollController.offset >= imageBelowTopBar;
    if (pastImage != _pastImage) setState(() => _pastImage = pastImage);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meal = ModalRoute.of(context)?.settings.arguments;
    if (meal is! Meal) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: AppLocalizations.of(context).back,
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_right
                  : Icons.chevron_left,
              size: 32,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(child: Text(AppLocalizations.of(context).menuUnavailable)),
      );
    }
    final imageHeight =
        (MediaQuery.sizeOf(context).width * 0.7).clamp(220.0, 320.0) +
        MediaQuery.paddingOf(context).top +
        kToolbarHeight;
    final theme = Theme.of(context);
    final topBarColor = _pastImage
        ? theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface
        : Colors.white;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppLocalizations.of(context).back,
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_right
                : Icons.chevron_left,
            size: 32,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: _pastImage
            ? theme.scaffoldBackgroundColor
            : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: topBarColor,
        systemOverlayStyle: _pastImage && theme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        actions: [AppHeaderActions(showTheme: true, iconColor: topBarColor)],
      ),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MealImage(meal),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.22, 0.60],
                      colors: [
                        Color(0xBF000000),
                        Color(0x80000000),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: AppTheme.sectionFont,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      PriceFormatter.format(meal.priceCents),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.green,
                        fontFamily: AppTheme.bodyFont,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 14),
                    SvgPicture.asset(
                      'assets/images/star.svg',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      meal.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: AppTheme.bodyFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DetailField(
                  AppLocalizations.of(context).category,
                  meal.category,
                ),
                const SizedBox(height: 16),
                _DetailField(AppLocalizations.of(context).origin, meal.area),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context).instructions,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: AppTheme.bodyFont,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  meal.instructions.trim().isEmpty
                      ? AppLocalizations.of(context).unknownDetail
                      : meal.instructions.trim(),
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: double.infinity, child: CartToggleButton(meal)),
              const SizedBox(height: 8),
              BlocBuilder<FavouritesCubit, FavouritesState>(
                builder: (context, favorites) {
                  final isSaved = favorites.contains(meal.id);
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: favorites.isLoading || favorites.isSaving
                          ? null
                          : () => context.read<FavouritesCubit>().toggle(meal),
                      icon: favorites.isSaving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                            ),
                      label: Text(
                        isSaved
                            ? AppLocalizations.of(context).removeFromFavorites
                            : AppLocalizations.of(context).addToFavorites,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 4),
      Text(
        value.trim().isEmpty
            ? AppLocalizations.of(context).unknownDetail
            : value,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ],
  );
}
