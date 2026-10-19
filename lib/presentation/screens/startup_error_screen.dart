import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 56, color: AppTheme.green),
              const SizedBox(height: 16),
              Text(l10n.serviceUnavailable, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
            ],
          ),
        ),
      ),
    );
  }
}
