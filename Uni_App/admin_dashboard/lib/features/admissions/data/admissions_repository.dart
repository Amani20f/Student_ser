import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'application_model.dart';

class AdmissionsRepository {
  final ApiClient _client;

  AdmissionsRepository(this._client);

  Future<List<ApplicationModel>> getApplications({Map<String, dynamic>? filters}) async {
    final queryParams = <String, String>{};
    filters?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        queryParams[key] = value.toString();
      }
    });

    final data = await _client.get(
      ApiConstants.adminApplications,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ApplicationModel> getApplicationDetails(int id) async {
    final data = await _client.get('${ApiConstants.adminApplications}/$id');
    // Note: The response has nested desired_program object, but the model parses it correctly.
    // If we need the nested details for UI, we might need to map them slightly differently.
    // The model currently parses the root fields. Let's pass the data to the model.
    final item = data['data'] as Map<String, dynamic>;
    if (item['desired_program'] is Map) {
      final dp = item['desired_program'] as Map<String, dynamic>;
      item['desired_program'] = dp['name'];
      item['department'] = dp['department'];
      item['college'] = dp['college'];
    }
    return ApplicationModel.fromJson(item);
  }

  Future<Map<String, dynamic>> approveApplication(int id) async {
    final response = await _client.post(ApiConstants.adminApplicationApprove(id));
    return response as Map<String, dynamic>;
  }

  Future<void> rejectApplication(int id, String reason) async {
    await _client.post(ApiConstants.adminApplicationReject(id), body: {
      'rejection_reason': reason,
    });
  }
}
