import 'package:flutter/material.dart';
import 'package:inves_tracker/core/services/api_service.dart';
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/views/auth/login_screen.dart';

/// Global error handler for API errors
class ErrorHandler {
  static final AuthService _authService = AuthService();

  /// Handle errors and show appropriate messages
  static Future<void> handleError(
    BuildContext context,
    dynamic error, {
    bool showSnackbar = true,
  }) async {
    String message = 'An unexpected error occurred';
    bool shouldLogout = false;

    if (error is UnauthorizedException) {
      message = error.message;
      shouldLogout = true;
    } else if (error is ForbiddenException) {
      message = error.message;
    } else if (error is NotFoundException) {
      message = error.message;
    } else if (error is BadRequestException) {
      message = error.message;
    } else if (error is NetworkException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString().replaceAll('Exception: ', '');
    }

    // Show error message — check mounted before any await
    if (showSnackbar && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          showCloseIcon: true,
        ),
      );
    }

    // Handle session expiration
    if (shouldLogout) {
      await _authService.logout(); // async gap — do NOT use context after this

      // Re-check mounted after the await before touching context
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  /// Show a generic error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show session expired dialog
  static Future<void> showSessionExpiredDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
          'Your session has expired. Please login again to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Close dialog first using dialogContext (still valid here)
              Navigator.pop(dialogContext);

              await _authService.logout(); // async gap

              // Use dialogContext.mounted — it outlives the dialog pop
              // because the navigator stack still holds a reference.
              // Prefer a top-level navigator lookup which is safer here.
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}