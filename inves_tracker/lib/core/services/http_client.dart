import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Base HTTP client with version checking
class HttpClient {
  // For Android Emulator, use 10.0.2.2:5033 to access localhost
  // For iOS Simulator, use localhost or 127.0.0.1
  // For server, use 45.131.3.173:5000 to access the API
  static const String baseUrl = 'http://45.131.3.173:5000/api';

  // Cache the app version to avoid repeated lookups
  static String? _appVersion;

  /// Get app version once and cache it
  Future<String> _getAppVersion() async {
    if (_appVersion != null) return _appVersion!;

    final packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    return _appVersion!;
  }

  /// Get default headers including version
  Future<Map<String, String>> _getHeaders([
    Map<String, String>? additionalHeaders,
  ]) async {
    final version = await _getAppVersion();

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': version,
    };

    return {...defaultHeaders, ...?additionalHeaders};
  }

  /// Generic GET request with version header
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final allHeaders = await _getHeaders(headers);

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/$endpoint'), headers: allHeaders)
          .timeout(const Duration(seconds: 30));

      _checkVersionResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic POST request with version header
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final allHeaders = await _getHeaders(headers);

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: allHeaders,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      _checkVersionResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PUT request with version header
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final allHeaders = await _getHeaders(headers);

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$endpoint'),
            headers: allHeaders,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      _checkVersionResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic DELETE request with version header
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final allHeaders = await _getHeaders(headers);

    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$endpoint'), headers: allHeaders)
          .timeout(const Duration(seconds: 30));

      _checkVersionResponse(response);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Check if response indicates version upgrade required
  void _checkVersionResponse(http.Response response) {
    if (response.statusCode == 426) {
      // 426 Upgrade Required
      final Map<String, dynamic> data = json.decode(response.body);
      throw AppUpdateRequiredException(
        responseBody: response.body,
        forceUpdate: data['forceUpdate'] ?? true,
        updateUrl: data['updateUrl'] ?? '',
        minimumVersion: data['minimumVersion'] ?? '',
      );
    }
  }

  /// Handle various error types
  Exception _handleError(dynamic error) {
    if (error is AppUpdateRequiredException) {
      return error;
    }

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

class AppUpdateRequiredException implements Exception {
  final String responseBody;
  final bool forceUpdate;
  final String updateUrl;
  final String minimumVersion;
  final String message;

  AppUpdateRequiredException({
    required this.responseBody,
    required this.forceUpdate,
    required this.updateUrl,
    required this.minimumVersion,
  }) : message = json.decode(responseBody)['message'] ?? 'Update required';

  @override
  String toString() => 'AppUpdateRequiredException: $message';
}
