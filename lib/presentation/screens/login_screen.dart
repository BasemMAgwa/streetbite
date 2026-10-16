import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/validation/auth_validators.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_screen_layout.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/auth_text_field.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().logIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      title: AppStrings.loginTitle,
      subtitle: AppStrings.loginSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _email,
              hint: AppStrings.email,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _password,
              hint: AppStrings.password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.loginPassword,
            ),
            const SizedBox(height: 16),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  previous.isBusy != current.isBusy,
              builder: (context, state) => AuthSubmitButton(
                label: AppStrings.logIn,
                onPressed: _submit,
                isBusy: state.isBusy,
              ),
            ),
            const SizedBox(height: 12),
            AuthSwitchPrompt(
              prompt: AppStrings.noAccount,
              action: AppStrings.createAccount,
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder<void>(
                  transitionDuration: const Duration(milliseconds: 350),
                  reverseTransitionDuration: const Duration(milliseconds: 350),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SignupScreen(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) => FadeTransition(opacity: animation, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
