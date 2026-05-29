import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'managed_user_model.dart';

class UserManagementRepository {
  final ApiClient _client;

  UserManagementRepository(this._client);

  Future<List<ManagedUserModel>> getUsers({Map<String, dynamic>? filters}) async {
    final queryParams = <String, String>{};
    filters?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        queryParams[key] = value.toString();
      }
    });

    final data = await _client.get(
      ApiConstants.adminUsers,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => ManagedUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ManagedUserModel> createUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final data = await _client.post(ApiConstants.adminUsers, body: {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    });
    return ManagedUserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    await _client.delete(ApiConstants.adminUserById(id));
  }

  Future<void> updatePassword(int id, String password) async {
    await _client.put(ApiConstants.adminUserPassword(id), body: {
      'password': password,
    });
  }
}
