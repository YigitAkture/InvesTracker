import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base HTTP client without authentication dependencies
class HttpClient {
  // For Android Emulator, use 10.0.2.2:5033 to access localhost
  // For iOS Simulator, use localhost or 127.0.0.1
  // For server, use 45.131.3.173:5000 to access the API
  static const String baseUrl = 'http://10.0.2.2:5033/api';

  /// Generic GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      ).timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {...defaultHeaders, ...?headers},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {...defaultHeaders, ...?headers},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      ).timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle various error types
  Exception _handleError(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return NetworkException('Network error. Please check your connection.');
    }

    return HttpException('An unexpected error occurred: $error');
  }
}

// Custom Exception Classes
class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends HttpException {
  NetworkException(super.message);
}