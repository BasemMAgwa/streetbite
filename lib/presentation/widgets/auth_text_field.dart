import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final TextInputAction textInputAction;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText && _hidden,
      textInputAction: widget.textInputAction,
      autocorrect: !widget.obscureText,
      enableSuggestions: !widget.obscureText,
      style: const TextStyle(color: Color(0xFF123629), fontSize: 15),
      decoration: InputDecoration(
        fillColor: AppTheme.paleMint,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Color(0xFF8A9D98)),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _hidden ? l10n.showPassword : l10n.hidePassword,
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF67867C),
                ),
              )
            : null,
      ),
    );
  }
}
