import '../constants/message.dart';

class AuthValidators {
  static AppMessage? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return AppMessage.requiredName;
    // Latin names start uppercase; Arabic has no uppercase equivalent.
    if (!RegExp(r'^[A-Zأ-ي]').hasMatch(name)) return AppMessage.capitalName;
    return null;
  }

  static AppMessage? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppMessage.requiredEmail;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return AppMessage.invalidEmail;
    }
    return null;
  }

  static AppMessage? loginPassword(String? value) {
    if (value == null || value.isEmpty) return AppMessage.requiredPassword;
    return null;
  }

  static AppMessage? signUpPassword(String? value) {
    if (value == null || value.isEmpty) return AppMessage.requiredPassword;
    if (value.length < 6) return AppMessage.shortPassword;
    return null;
  }

  static AppMessage? confirmation(String? value, String password) {
    if (value == null || value.isEmpty) return AppMessage.requiredConfirmation;
    if (value != password) return AppMessage.passwordsMismatch;
    return null;
  }
}
