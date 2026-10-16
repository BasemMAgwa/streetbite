import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant, color: AppTheme.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                AppStrings.welcome,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              if (user != null && user.fullName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(user.fullName),
              ],
              const SizedBox(height: 24),
              BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (previous, current) =>
                    previous.isBusy != current.isBusy,
                builder: (context, state) => FilledButton(
                  onPressed: state.isBusy
                      ? null
                      : () => context.read<AuthCubit>().logOut(),
                  child: const Text(AppStrings.signOut),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
