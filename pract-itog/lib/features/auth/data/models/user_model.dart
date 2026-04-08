import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.isEmailVerified,
  });

  factory UserModel.fromFirebase({
    required String id,
    required String email,
    required String name,
    required bool isEmailVerified,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      isEmailVerified: isEmailVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name};
  }
}
