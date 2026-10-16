import '../constants/app_strings.dart';

class AuthValidators {
  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return AppStrings.requiredName;
    // Latin names start uppercase; Arabic has no uppercase equivalent.
    if (!RegExp(r'^[A-Zأ-ي]').hasMatch(name)) return AppStrings.capitalName;
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.requiredEmail;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.requiredPassword;
    return null;
  }

  static String? signUpPassword(String? value) {
    if (value == null || value.isEmpty) return AppStrings.requiredPassword;
    if (value.length < 6) return AppStrings.shortPassword;
    return null;
  }

  static String? confirmation(String? value, String password) {
    if (value == null || value.isEmpty) return AppStrings.requiredConfirmation;
    if (value != password) return AppStrings.passwordsMismatch;
    return null;
  }
}
