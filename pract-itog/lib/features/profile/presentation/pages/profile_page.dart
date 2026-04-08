import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _loadProfile();
  }

  void _loadProfile() {
    final s = context.read<AuthBloc>().state;
    if (s is AuthAuthenticated) {
      context.read<ProfileCubit>().loadProfile(s.user.id);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) return const SizedBox.shrink();
          final user = authState.user;
          return FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildAvatar(user.name),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildEmailStatus(user.isEmailVerified),
                  const SizedBox(height: 32),
                  _buildOrdersSection(),
                  const SizedBox(height: 24),
                  _buildMenuItems(context),
                  const SizedBox(height: 32),
                  SecondaryButton(
                    text: 'Выйти из аккаунта',
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initials = name.isNotEmpty
        ? name
            .trim()
            .split(' ')
            .map((p) => p.isNotEmpty ? p[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStatus(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: verified
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified : Icons.info_outline,
            size: 16,
            color: verified ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 6),
          Text(
            verified ? 'Email подтверждён' : 'Email не подтверждён',
            style: TextStyle(
              color: verified ? AppColors.success : AppColors.warning,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final count = state is ProfileLoaded ? state.orders.length : 0;
        return InkWell(
          onTap: () => context.push('/profile/orders'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Мои заказы',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state is ProfileLoading
                            ? 'Загрузка...'
                            : '$count заказов',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textHint),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.favorite_outline,
          title: 'Избранное',
          onTap: () => context.push('/wishlist'),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.lock_reset,
          title: 'Сменить пароль',
          onTap: () {
            final s = context.read<AuthBloc>().state;
            if (s is AuthAuthenticated) {
              context.read<AuthBloc>().add(
                    AuthResetPasswordRequested(s.user.email),
                  );
              AppSnackBar.showSuccess(
                context,
                'Письмо для смены пароля отправлено на ${s.user.email}',
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
