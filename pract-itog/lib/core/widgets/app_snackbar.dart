import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppSnackBar {
  AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      color: AppColors.success,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline,
      color: AppColors.error,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline,
      color: AppColors.primary,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.warning_amber_outlined,
      color: AppColors.warning,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
