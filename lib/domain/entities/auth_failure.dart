enum AuthFailureType {
  invalidEmail,
  emailInUse,
  weakPassword,
  invalidCredentials,
  tooManyRequests,
  network,
  serviceUnavailable,
  accountSave,
  generic,
}

class AuthFailure implements Exception {
  const AuthFailure(this.type);

  final AuthFailureType type;
}
