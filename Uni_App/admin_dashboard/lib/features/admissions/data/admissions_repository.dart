import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'application_model.dart';

class AdmissionsRepository {
  final ApiClient _client;

  AdmissionsRepository(this._client);

  Future<List<ApplicationModel>> getApplications({Map<String, dynamic>? filters}) async {
    print('### [Log] AdmissionsRepository.getApplications called with filters: $filters');
    final queryParams = <String, String>{};
    filters?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        queryParams[key] = value.toString();
      }
    });

    try {
      final data = await _client.get(
        ApiConstants.adminApplications,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      print('### [Log] AdmissionsRepository received data keys: ${data.keys}');
      final list = data['data'] as List<dynamic>;
      print('### [Log] AdmissionsRepository raw list length: ${list.length}');
      final parsedList = list
          .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      print('### [Log] AdmissionsRepository parsed list length: ${parsedList.length}');
      return parsedList;
    } catch (e) {
      print('### [Log] AdmissionsRepository error: $e');
      rethrow;
    }
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

  Future<Map<String, dynamic>> approveApplication(int id, int approvedProgramId) async {
    final response = await _client.post(
      ApiConstants.adminApplicationApprove(id),
      body: {
        'approved_program_id': approvedProgramId,
      },
    );
    return response as Map<String, dynamic>;
  }

  Future<void> rejectApplication(int id, String reason) async {
    await _client.post(ApiConstants.adminApplicationReject(id), body: {
      'rejection_reason': reason,
    });
  }

  Future<void> verifyPayment(int id) async {
    await _client.put('/staff/applications/$id/verify-payment');
  }
}
