import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with SingleTickerProviderStateMixin {
  Timer? _checkTimer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _startPolling();
  }

  void _startPolling() {
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckEmailVerification());
      }
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthEmailVerified) {
            _checkTimer?.cancel();
            AppSnackBar.showSuccess(context, 'Email успешно подтверждён!');
            context.go('/home');
          } else if (state is AuthEmailVerificationSent) {
            AppSnackBar.showInfo(context, 'Письмо отправлено повторно');
          } else if (state is AuthError) {
            AppSnackBar.showError(context, state.message);
          } else if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildEmailIcon(),
                  const SizedBox(height: 40),
                  Text(
                    'Подтвердите email',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Мы отправили письмо с подтверждением на ваш email. '
                    'Перейдите по ссылке в письме, чтобы активировать аккаунт.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Ожидаем подтверждения...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => PrimaryButton(
                      text: 'Отправить повторно',
                      icon: Icons.refresh,
                      isLoading: state is AuthLoading,
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(const AuthSendEmailVerificationRequested()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                    },
                    child: const Text('Выйти'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
        const Icon(Icons.mark_email_unread_outlined, size: 60, color: AppColors.primary),
      ],
    );
  }
}
