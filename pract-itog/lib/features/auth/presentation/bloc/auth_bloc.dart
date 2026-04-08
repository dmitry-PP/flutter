import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.sendEmailVerificationUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthSendEmailVerificationRequested>(_onSendVerification);
    on<AuthCheckEmailVerification>(_onCheckVerification);
  }

  void _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) {
    final user = authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await resetPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordResetSent(event.email)),
    );
  }

  Future<void> _onSendVerification(
    AuthSendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await sendEmailVerificationUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthEmailVerificationSent()),
    );
  }

  Future<void> _onCheckVerification(
    AuthCheckEmailVerification event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.isEmailVerified();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (verified) {
        if (verified) {
          final user = authRepository.getCurrentUser();
          if (user != null) emit(AuthEmailVerified(user));
        }
      },
    );
  }
}
