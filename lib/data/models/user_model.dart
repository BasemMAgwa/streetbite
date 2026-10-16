import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
  };
}

// Builder assembles values from the form and Firebase in one place.
class UserModelBuilder {
  String? _id;
  String? _fullName;
  String? _email;

  UserModelBuilder id(String value) {
    _id = value;
    return this;
  }

  UserModelBuilder fullName(String value) {
    _fullName = value;
    return this;
  }

  UserModelBuilder email(String value) {
    _email = value;
    return this;
  }

  UserModel build() =>
      UserModel(id: _id!, fullName: _fullName!, email: _email!);
}
