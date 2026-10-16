import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)),
        const SizedBox(height: 16),
        Text(
          user?.fullName ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(user?.email ?? '', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) => previous.isBusy != current.isBusy,
          builder: (context, state) => FilledButton(
            onPressed: state.isBusy ? null : context.read<AuthCubit>().logOut,
            child: const Text(AppStrings.signOut),
          ),
        ),
      ],
    );
  }
}
