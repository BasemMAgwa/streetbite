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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().signUp(_name.text, _email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != AuthStatus.authenticated &&
          current.status == AuthStatus.authenticated,
      listener: (context, state) =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      child: AuthScreenLayout(
        title: AppStrings.signUpTitle,
        subtitle: AppStrings.signUpSubtitle,
        imageHeightFraction: 0.45,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _name,
                hint: AppStrings.fullName,
                textCapitalization: TextCapitalization.words,
                validator: AuthValidators.name,
              ),
              const SizedBox(height: 10),
              AuthTextField(
                controller: _email,
                hint: AppStrings.email,
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidators.email,
              ),
              const SizedBox(height: 10),
              AuthTextField(
                controller: _password,
                hint: AppStrings.password,
                obscureText: true,
                validator: AuthValidators.signUpPassword,
              ),
              const SizedBox(height: 10),
              AuthTextField(
                controller: _confirmation,
                hint: AppStrings.confirmPassword,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    AuthValidators.confirmation(value, _password.text),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (previous, current) =>
                    previous.isBusy != current.isBusy,
                builder: (context, state) => AuthSubmitButton(
                  label: AppStrings.signUp,
                  onPressed: _submit,
                  isBusy: state.isBusy,
                ),
              ),
              const SizedBox(height: 12),
              AuthSwitchPrompt(
                prompt: AppStrings.haveAccount,
                action: AppStrings.logIn,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
