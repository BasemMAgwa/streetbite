import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.showAppBar = true,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: showAppBar
        ? AppBar(
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 32),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          )
        : null,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
