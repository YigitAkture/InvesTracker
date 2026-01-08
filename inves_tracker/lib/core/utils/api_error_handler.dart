import 'package:flutter/material.dart';
import 'package:inves_tracker/core/services/http_client.dart';
import 'package:inves_tracker/shared/app_update_dialog.dart';

/// Global API error handler with update dialog support
class ApiErrorHandler {
  static bool _updateDialogShown = false;

  /// Handle API errors globally
  static Future<void> handleError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) async {
    if (error is AppUpdateRequiredException) {
      await _handleUpdateRequired(context, error);
      return;
    }

    if (error is NetworkException) {
      _showSnackBar(context, error.message);
      return;
    }

    if (error is HttpException) {
      _showSnackBar(context, error.message);
      return;
    }

    // Generic error
    _showSnackBar(context, 'An unexpected error occurred');
  }

  /// Handle update required error
  static Future<void> _handleUpdateRequired(
    BuildContext context,
    AppUpdateRequiredException error,
  ) async {
    // Prevent showing multiple dialogs
    if (_updateDialogShown) return;
    _updateDialogShown = true;

    await AppUpdateDialog.show(
      context,
      updateUrl: error.updateUrl,
      minimumVersion: error.minimumVersion,
      forceUpdate: error.forceUpdate,
    );

    _updateDialogShown = false;
  }

  /// Show error as snackbar
  static void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

  /// Wrap async API calls with error handling
  static Future<T?> safeApiCall<T>(
    BuildContext context,
    Future<T> Function() apiCall, {
    VoidCallback? onRetry,
    bool showErrorDialog = true,
  }) async {
    try {
      return await apiCall();
    } catch (e) {
      if (showErrorDialog && context.mounted) {
        await handleError(context, e, onRetry: onRetry);
      }
      return null;
    }
  }
}

/// Extension to make error handling easier
extension ApiErrorHandlerExtension on BuildContext {
  /// Handle API error with context
  Future<void> handleApiError(dynamic error) async {
    await ApiErrorHandler.handleError(this, error);
  }

  /// Wrap API call with error handling
  Future<T?> safeApiCall<T>(
    Future<T> Function() apiCall, {
    VoidCallback? onRetry,
  }) async {
    return ApiErrorHandler.safeApiCall(
      this,
      apiCall,
      onRetry: onRetry,
    );
  }
}