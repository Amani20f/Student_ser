import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'request_model.dart';

class RequestRepository {
  final ApiClient _apiClient;

  RequestRepository(this._apiClient);

  Future<List<RequestModel>> getRequests({Map<String, dynamic>? filters}) async {
    final queryParams = <String, String>{};
    filters?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        if (key == 'created_at_from') {
          queryParams['from_date'] = value.toString();
        } else if (key == 'created_at_to') {
          queryParams['to_date'] = value.toString();
        } else {
          queryParams[key] = value.toString();
        }
      }
    });

    final response = await _apiClient.get(
      ApiConstants.staffRequests,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => RequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateStatus(int id, String status, String? adminNotes) async {
    final Map<String, dynamic> body = {'status': status};
    if (status == 'rejected' && adminNotes != null && adminNotes.isNotEmpty) {
      body['admin_notes'] = adminNotes;
    }

    await _apiClient.put(
      ApiConstants.staffServiceRequestStatus(id),
      body: body,
    );
  }
}
