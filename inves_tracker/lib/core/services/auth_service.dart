import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inves_tracker/core/services/http_client.dart';

class AuthService {
  final HttpClient _httpClient = HttpClient();

  static const String _userIdKey = 'userId';
  static const String _tokenKey = 'token';
  static const String _emailKey = 'email';
  static const String _firstNameKey = 'firstName';
  static const String _lastNameKey = 'lastName';

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _httpClient.post('Auth/register', {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      });

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveUserData(data);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message':
              error['message'] ?? error['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      final response = await _httpClient.post('Auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveUserData(data);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message':
              error['message'] ?? error['error'] ?? 'Invalid credentials',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? error['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Request forgot password (Step 1)
  /// Sends a 6-digit verification code to the user's email
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _httpClient.post('Auth/forgot-password', {
        'email': email,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Verification code sent to your email',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to send verification code',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  /// Reset password with verification code (Step 2)
  /// Verifies the code and sets a new password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _httpClient.post('Auth/reset-password', {
        'email': email,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Password reset successfully',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getString(_userIdKey);
    return token != null && userId != null;
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get current user data
  Future<Map<String, String?>> getCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'email': prefs.getString(_emailKey),
      'firstName': prefs.getString(_firstNameKey),
      'lastName': prefs.getString(_lastNameKey),
    };
  }

  // Save user data to SharedPreferences
  Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, data['userId']);
    await prefs.setString(_tokenKey, data['token'] ?? '');
    await prefs.setString(_emailKey, data['email'] ?? '');
    await prefs.setString(_firstNameKey, data['firstName'] ?? '');
    await prefs.setString(_lastNameKey, data['lastName'] ?? '');
  }

  // Verify token is still valid
  Future<bool> verifyToken() async {
    final token = await getToken();
    final userId = await getCurrentUserId();

    if (token == null || userId == null) return false;

    try {
      final response = await _httpClient.get(
        'Auth/verify/$userId',
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
