import 'package:flutter/material.dart';

class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: const Color(0xFF22C55E), // Theme success color based on rule
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.error_outline_rounded,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.info_outline_rounded,
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
