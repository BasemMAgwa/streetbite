import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/brand.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.green,
      body: Semantics(
        button: onTap != null,
        label: onTap == null ? null : l10n.tapToContinue,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 950),
              builder: (context, opacity, child) =>
                  Opacity(opacity: opacity, child: child),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 68,
                      height: 68,
                      semanticsLabel: appName,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
