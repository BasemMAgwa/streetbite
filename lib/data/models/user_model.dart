import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.photoBase64,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    photoBase64: json['photoBase64'] as String?,
  );

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
    };
    if (photoBase64 != null) json['photoBase64'] = photoBase64;
    return json;
  }
}

// Builder assembles values from the form and Firebase in one place.
class UserModelBuilder {
  String? _id;
  String? _fullName;
  String? _email;
  String? _photoBase64;

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

  UserModelBuilder photoBase64(String? value) {
    _photoBase64 = value;
    return this;
  }

  UserModel build() => UserModel(
    id: _id!,
    fullName: _fullName!,
    email: _email!,
    photoBase64: _photoBase64,
  );
}
