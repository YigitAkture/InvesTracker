import 'dart:convert';
import 'package:inves_tracker/core/models/asset.dart';
import 'package:inves_tracker/core/services/api_service.dart';

class AssetService {
  final ApiService _apiService = ApiService();

  /// Get all assets for the authenticated user
  Future<List<Asset>> getUserAssets(String userId) async {
    try {
      final response = await _apiService.get('Assets');
      
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

  /// Create a new asset
  Future<Asset> createAsset(String userId, {
    required String assetType,
    required String assetCode,
    required double amount,
    double? initialTryValue,
  }) async {
    try {
      final response = await _apiService.post('Assets', {
        'assetType': assetType,
        'assetCode': assetCode,
        'amount': amount,
        'currentTryValue': initialTryValue,
      });

      if (response.statusCode == 201) {
        return Asset.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Failed to create asset');
      }
    } catch (e) {
      throw Exception('Error creating asset: $e');
    }
  }

  /// Update an existing asset
  Future<Asset> updateAsset(String assetId, double amount, double? currentTryValue) async {
    try {
      final response = await _apiService.put('Assets/$assetId', {
        'amount': amount,
        'currentTryValue': currentTryValue,
      });

      if (response.statusCode == 200) {
        return Asset.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating asset: $e');
    }
  }

  /// Delete an asset
  Future<void> deleteAsset(String assetId) async {
    try {
      final response = await _apiService.delete('Assets/$assetId');
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting asset: $e');
    }
  }

  /// Get a specific asset by ID
  Future<Asset?> getAssetById(String assetId) async {
    try {
      final response = await _apiService.get('Assets/$assetId');
      
      if (response.statusCode == 200) {
        return Asset.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching asset: $e');
    }
  }
}