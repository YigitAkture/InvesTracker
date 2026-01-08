import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inves_tracker/core/services/auth_service.dart';

/// Base API service with authentication handling
class ApiService {
  // For Android Emulator, use 10.0.2.2:5033 to access localhost
  // For iOS Simulator, use localhost or 127.0.0.1
  // For server, use 45.131.3.173:5000 to access the API
  static const String baseUrl = 'http://10.0.2.2:5033/api';
  final AuthService _authService = AuthService();

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request with authentication
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      await _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request with authentication
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      await _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request with authentication
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      await _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request with authentication
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      await _handleResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle response status codes
  Future<void> _handleResponse(http.Response response) async {
    // Token expired - logout user
    if (response.headers['token-expired'] == 'true') {
      await _authService.logout();
      throw UnauthorizedException('Session expired. Please login again.');
    }

    // Handle error responses
    if (response.statusCode >= 400) {
      final error = _parseError(response);
      
      switch (response.statusCode) {
        case 401:
          throw UnauthorizedException(error);
        case 403:
          throw ForbiddenException(error);
        case 404:
          throw NotFoundException(error);
        case 400:
          throw BadRequestException(error);
        default:
          throw ApiException(error);
      }
    }
  }

  /// Parse error message from response
  String _parseError(http.Response response) {
    try {
      final data = json.decode(response.body);
      return data['error'] ?? data['message'] ?? 'Request failed';
    } catch (e) {
      return 'Request failed with status ${response.statusCode}';
    }
  }

  /// Handle various error types
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    
    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      return NetworkException('Network error. Please check your connection.');
    }
    
    return ApiException('An unexpected error occurred: $error');
  }
}

// Custom Exception Classes
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}