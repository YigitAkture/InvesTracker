import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inves_tracker/core/models/debt.dart';

class DebtService {
  static const String _baseUrl = 'http://10.0.2.2:5033/api/Debts';

  Future<List<Debt>> getUserDebts(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

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

  Future<Debt> createDebt(String userId, {
    required String debtType,
    required String debtCode,
    required double amount,
    String? note,
    DateTime? dueDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'debtType': debtType,
          'debtCode': debtCode,
          'amount': amount,
          'note': note,
          'dueDate': dueDate?.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return Debt.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create debt');
      }
    } catch (e) {
      throw Exception('Error creating debt: $e');
    }
  }

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

      final response = await http.put(
        Uri.parse('$_baseUrl/$debtId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Debt.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update debt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating debt: $e');
    }
  }

  Future<void> deleteDebt(String debtId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$debtId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete debt: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting debt: $e');
    }
  }
}