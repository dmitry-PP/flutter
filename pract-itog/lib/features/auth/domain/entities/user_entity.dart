import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.isEmailVerified,
  });

  @override
  List<Object?> get props => [id, email, name, isEmailVerified];
}
