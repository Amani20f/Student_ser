import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_exception.dart';

/// Centralized HTTP client that attaches Bearer token to every request.
/// Throws [UnauthorizedException] on 401 — does NOT navigate.
class ApiClient {
  final SharedPreferences _prefs;

  ApiClient(this._prefs);

  String? get _token => _prefs.getString('auth_token');

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    var uri = Uri.parse('${ApiConstants.baseUrl}$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final response = await http.get(_uri(path, queryParams), headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final response = await http.patch(
      _uri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(_uri(path), headers: _headers);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (response.statusCode >= 400) {
      final body = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {'error': 'Unknown error'};
      throw ApiException(
        response.statusCode,
        body['error'] ?? body['message'] ?? 'Request failed',
      );
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}
