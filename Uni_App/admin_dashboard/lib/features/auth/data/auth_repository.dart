import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  AuthRepository(this._apiClient, this._prefs);

  /// Authenticate and store token + user data.
  Future<UserModel> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    final data = response['data'];
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await _prefs.setString('auth_token', token);
    await _prefs.setString('auth_user', jsonEncode(user.toJson()));

    return user;
  }

  /// Logout and clear stored credentials.
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (_) {
      // Even if the API call fails, clear local state
    }
    await _prefs.remove('auth_token');
    await _prefs.remove('auth_user');
  }

  /// Retrieve stored token.
  String? getStoredToken() => _prefs.getString('auth_token');

  /// Retrieve stored user.
  UserModel? getStoredUser() {
    final userJson = _prefs.getString('auth_user');
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  /// Check if the user is logged in.
  bool get isLoggedIn => getStoredToken() != null;
}
