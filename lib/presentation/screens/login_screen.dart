import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/validation/auth_validators.dart';
import '../../l10n/app_localizations.dart';
import '../l10n/message_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return AuthScreenLayout(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _email,
              hint: l10n.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => AuthValidators.email(value)?.text(l10n),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _password,
              hint: l10n.password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  AuthValidators.loginPassword(value)?.text(l10n),
            ),
            const SizedBox(height: 16),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  previous.isBusy != current.isBusy,
              builder: (context, state) => AuthSubmitButton(
                label: l10n.logIn,
                onPressed: _submit,
                isBusy: state.isBusy,
              ),
            ),
            const SizedBox(height: 12),
            AuthSwitchPrompt(
              prompt: l10n.noAccount,
              action: l10n.createAccount,
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
