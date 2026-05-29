import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Authenticate user via API
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Revoke tokens on backend
  Future<void> logout() async {
    await _apiClient.post(ApiConstants.logout);
  }

  /// Change student's password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _apiClient.put(
      ApiConstants.changePassword,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
    );
  }

  /// Request password reset link
  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiConstants.forgotPassword,
      body: {'email': email},
    );
  }
}
