class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoBase64,
  });

  final String id;
  final String fullName;
  final String email;
  final String? photoBase64;
}
