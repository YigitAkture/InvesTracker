import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://45.131.3.173:5000/api/Auth';
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
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveUserData(data);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? error['error'] ?? 'Registration failed'
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
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveUserData(data);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? error['error'] ?? 'Invalid credentials'
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? error['error'] ?? 'Login failed'
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
      final response = await http.get(
        Uri.parse('$_baseUrl/verify/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}