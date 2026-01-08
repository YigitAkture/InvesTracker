import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inves_tracker/core/services/auth_service.dart';
import 'package:inves_tracker/core/services/http_client.dart';

/// API service with authentication handling
class ApiService {
  final HttpClient _httpClient = HttpClient();
  final AuthService _authService = AuthService();

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request with authentication
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    
    try {
      final response = await _httpClient.get(endpoint, headers: headers);
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
      final response = await _httpClient.post(endpoint, body, headers: headers);
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
      final response = await _httpClient.put(endpoint, body, headers: headers);
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
      final response = await _httpClient.delete(endpoint, headers: headers);
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
    
    if (error is NetworkException) {
      return ApiException(error.message);
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