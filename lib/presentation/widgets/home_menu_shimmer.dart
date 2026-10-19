import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class HomeMenuShimmer extends StatefulWidget {
  const HomeMenuShimmer({super.key, required this.horizontalPadding});

  final double horizontalPadding;

  @override
  State<HomeMenuShimmer> createState() => _HomeMenuShimmerState();
}

class _HomeMenuShimmerState extends State<HomeMenuShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF263A33) : const Color(0xFFE8ECEA);
    final highlight = isDark
        ? const Color(0xFF466255)
        : const Color(0xFFF7FAF8);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bannerHeight = (screenWidth * 0.52).clamp(170.0, 240.0);
    final cardHeight = screenWidth < 360 ? 228.0 : 244.0;

    return Semantics(
      label: AppLocalizations.of(context).loadingMeals,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final position = -2.0 + _controller.value * 4.0;
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(position - 1, 0),
                end: Alignment(position + 1, 0),
                colors: [base, highlight, base],
              ).createShader(bounds),
              child: child,
            );
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                ),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _ShimmerBlock(width: 140, height: 24),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _ShimmerBlock(height: bannerHeight),
              ),
              const SizedBox(height: 12),
              const Center(child: _ShimmerBlock(width: 56, height: 6)),
              const SizedBox(height: 22),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                ),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _ShimmerBlock(width: 115, height: 24),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 156,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.horizontalPadding,
                  ),
                  itemCount: 3,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, _) =>
                      const _ShimmerBlock(width: 134, height: 156),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                ),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _ShimmerBlock(width: 110, height: 24),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(child: _ShimmerBlock(height: cardHeight)),
                    const SizedBox(width: 12),
                    Expanded(child: _ShimmerBlock(height: cardHeight)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
