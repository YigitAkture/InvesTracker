import 'dart:convert';
import 'package:inves_tracker/core/services/api_service.dart';
import 'package:inves_tracker/core/services/auth_service.dart';

class UserService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  /// Update user profile (first name and last name)
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _apiService.put('Users/me', {
        'firstName': firstName,
        'lastName': lastName,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Update local storage
        await _updateLocalUserData(
          firstName: firstName,
          lastName: lastName,
        );

        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['error'] ?? error['message'] ?? 'Profile update failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Change password for logged-in user (Scenario 1)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _apiService.post('Auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Password changed successfully'
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? error['error'] ?? 'Failed to change password'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Delete user account with password verification
  Future<Map<String, dynamic>> deleteAccount({
    required String password,
  }) async {
    try {
      // First, verify the password by attempting to login
      final loginResult = await _verifyPassword(password);
      
      if (!loginResult['success']) {
        return {
          'success': false,
          'message': 'Şifre hatalı. Lütfen tekrar deneyin.',
        };
      }

      // If password is correct, delete the account
      final response = await _apiService.delete('Users/me');

      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['error'] ?? error['message'] ?? 'Account deletion failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Verify password by attempting login
  Future<Map<String, dynamic>> _verifyPassword(String password) async {
    try {
      final userData = await _authService.getCurrentUserData();
      final email = userData['email'];

      if (email == null) {
        return {'success': false, 'message': 'User email not found'};
      }

      // Attempt to login with the provided password
      final loginResult = await _authService.login(
        email: email,
        password: password,
      );

      return loginResult;
    } catch (e) {
      return {'success': false, 'message': 'Password verification failed: $e'};
    }
  }

  /// Update local user data in SharedPreferences
  Future<void> _updateLocalUserData({
    required String firstName,
    required String lastName,
  }) async {
    final userData = await _authService.getCurrentUserData();
    
    // Re-save with updated values
    final updatedData = {
      'userId': userData['userId'] ?? '',
      'email': userData['email'] ?? '',
      'firstName': firstName,
      'lastName': lastName,
      'token': await _authService.getToken() ?? '',
    };

    // Save updated data to SharedPreferences
    await _authService.saveUserData(updatedData);
  }
}