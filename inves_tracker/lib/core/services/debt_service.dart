import 'dart:convert';
import 'package:inves_tracker/core/models/debt.dart';
import 'package:inves_tracker/core/services/api_service.dart';

class DebtService {
  final ApiService _apiService = ApiService();

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

  /// Create a new debt
  Future<Debt> createDebt(String userId, {
    required String debtType,
    required String debtCode,
    required double amount,
    String? note,
    DateTime? dueDate,
  }) async {
    try {
      final body = {
        'debtType': debtType,
        'debtCode': debtCode,
        'amount': amount,
        if (note != null) 'note': note,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      };

      final response = await _apiService.post('Debts', body);

      if (response.statusCode == 201) {
        return Debt.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Failed to create debt');
      }
    } catch (e) {
      throw Exception('Error creating debt: $e');
    }
  }

  /// Update an existing debt
  Future<Debt> updateDebt(String debtId, {
    double? amount,
    String? note,
    DateTime? dueDate,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (amount != null) body['amount'] = amount;
      if (note != null) body['note'] = note;
      if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();

      final response = await _apiService.put('Debts/$debtId', body);

      if (response.statusCode == 200) {
        return Debt.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update debt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating debt: $e');
    }
  }

  /// Delete a debt
  Future<void> deleteDebt(String debtId) async {
    try {
      final response = await _apiService.delete('Debts/$debtId');
      
      if (response.statusCode != 204) {
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
}