import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  const AuthResetPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthSendEmailVerificationRequested extends AuthEvent {
  const AuthSendEmailVerificationRequested();
}

class AuthCheckEmailVerification extends AuthEvent {
  const AuthCheckEmailVerification();
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}
