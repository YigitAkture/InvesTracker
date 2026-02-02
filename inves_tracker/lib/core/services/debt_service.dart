import 'dart:convert';
import 'package:inves_tracker/core/helpers/wallet_localization_helper.dart';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/services/api_service.dart';
import 'package:inves_tracker/core/services/debt_notification_service.dart';
import 'package:inves_tracker/core/services/preferences_service.dart';
import 'package:inves_tracker/core/utils/localization_manager.dart';

/// Enhanced Debt Service with notification support
class DebtService {
  final ApiService _apiService = ApiService();
  final DebtNotificationService _notificationService =
      DebtNotificationService();
  final PreferencesService _preferencesService = PreferencesService();
  final LocalizationManager _localizationManager = LocalizationManager();

  /// Get all debts for the authenticated user
  Future<List<Debt>> getUserDebts(String userId) async {
    try {
      final response = await _apiService.get('Debts');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Debt.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load debts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching debts: $e');
    }
  }

  /// Create a new debt with automatic notification scheduling
  Future<Debt> createDebt(
    String userId, {
    required String debtType,
    required String debtCode,
    required double amount,
    required double currentTryValue,
    String? note,
    DateTime? dueDate,
  }) async {
    try {
      final body = {
        'debtType': debtType,
        'debtCode': debtCode,
        'amount': amount,
        'currentTryValue': currentTryValue,
        if (note != null) 'note': note,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      };

      final response = await _apiService.post('Debts', body);

      if (response.statusCode == 201) {
        final debt = Debt.fromJson(json.decode(response.body));

        // Schedule notifications if due date exists AND notifications are enabled
        if (debt.dueDate != null) {
          final notificationsEnabled = await _preferencesService
              .getDebtNotificationsEnabled();
          if (notificationsEnabled) {
            await _scheduleNotificationsForDebt(debt);
          }
        }

        return debt;
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['error'] ?? error['message'] ?? 'Failed to create debt',
        );
      }
    } catch (e) {
      throw Exception('Error creating debt: $e');
    }
  }

  /// Update an existing debt with notification rescheduling
  Future<Debt> updateDebt(
    String debtId, {
    double? amount,
    double? currentTryValue,
    String? note,
    DateTime? dueDate,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (amount != null) body['amount'] = amount;
      if (currentTryValue != null) body['currentTryValue'] = currentTryValue;
      if (note != null) body['note'] = note;
      if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();

      final response = await _apiService.put('Debts/$debtId', body);

      if (response.statusCode == 200) {
        final debt = Debt.fromJson(json.decode(response.body));

        // Reschedule notifications
        await _notificationService.cancelDebtNotifications(debt.id);

        // Only reschedule if notifications are enabled
        if (debt.dueDate != null) {
          final notificationsEnabled = await _preferencesService
              .getDebtNotificationsEnabled();
          if (notificationsEnabled) {
            await _scheduleNotificationsForDebt(debt);
          }
        }

        return debt;
      } else {
        throw Exception('Failed to update debt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating debt: $e');
    }
  }

  /// Delete a debt and cancel its notifications
  Future<void> deleteDebt(String debtId) async {
    try {
      final response = await _apiService.delete('Debts/$debtId');

      if (response.statusCode == 204) {
        // Cancel notifications for deleted debt
        await _notificationService.cancelDebtNotifications(debtId);
      } else {
        throw Exception('Failed to delete debt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting debt: $e');
    }
  }

  /// Get a specific debt by ID
  Future<Debt?> getDebtById(String debtId) async {
    try {
      final response = await _apiService.get('Debts/$debtId');

      if (response.statusCode == 200) {
        return Debt.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load debt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching debt: $e');
    }
  }

  /// Reschedule all notifications for all user debts
  /// Useful after app restart or timezone changes
  /// Respects the debt notifications enabled preference
  Future<void> rescheduleAllNotifications(String userId) async {
    try {
      // Check if debt notifications are enabled
      final notificationsEnabled = await _preferencesService
          .getDebtNotificationsEnabled();

      if (!notificationsEnabled) {
        // If disabled, cancel all existing debt notifications
        final debts = await getUserDebts(userId);
        for (final debt in debts) {
          await _notificationService.cancelDebtNotifications(debt.id);
        }
        return;
      }

      // If enabled, reschedule notifications for all debts
      final debts = await getUserDebts(userId);

      for (final debt in debts) {
        if (debt.dueDate != null) {
          await _scheduleNotificationsForDebt(debt);
        }
      }
    } catch (e) {
      throw Exception('Error rescheduling notifications: $e');
    }
  }

  /// Helper method to schedule notifications for a debt
  /// Uses LocalizationManager to get localized strings without BuildContext
  Future<void> _scheduleNotificationsForDebt(Debt debt) async {
    // Get current localizations from LocalizationManager
    final l10n = _localizationManager.current;

    // Create a description for the notification
    String description = '${debt.debtCode} - ${debt.amount}';
    if (debt.note != null && debt.note!.isNotEmpty) {
      description = debt.note!;
    }

    // Get localized currency name
    String currency = debt.debtType != 'Gold'
        ? debt.debtCode
        : WalletLocalizationHelper.getGoldName(debt.debtCode, l10n);

    await _notificationService.scheduleDebtNotifications(
      debtId: debt.id,
      createdAt: debt.createdAt,
      dueDate: debt.dueDate!,
      debtDescription: description,
      amount: debt.amount,
      currency: currency,
    );
  }
}