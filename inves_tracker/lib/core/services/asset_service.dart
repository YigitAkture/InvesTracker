import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inves_tracker/core/models/asset.dart';

class AssetService {
  static const String _baseUrl = 'http://10.0.2.2:5033/api/Assets';

  Future<List<Asset>> getUserAssets(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Asset.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assets: $e');
    }
  }

  Future<Asset> createAsset(String userId, {
    required String assetType,
    required String assetCode,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'assetType': assetType,
          'assetCode': assetCode,
          'amount': amount,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return Asset.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create asset');
      }
    } catch (e) {
      throw Exception('Error creating asset: $e');
    }
  }

  Future<Asset> updateAsset(String assetId, double amount) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$assetId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amount}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Asset.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating asset: $e');
    }
  }

  Future<void> deleteAsset(String assetId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$assetId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting asset: $e');
    }
  }
}