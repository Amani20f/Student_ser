import '../../../core/network/api_client.dart';
import 'unified_request_model.dart';

class UnifiedRequestRepository {
  final ApiClient _apiClient;

  UnifiedRequestRepository(this._apiClient);

  Future<List<UnifiedRequestModel>> getUnifiedRequests({
    String? search,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null && status.isNotEmpty && status != '___all___') {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      '/admin/unified-requests',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => UnifiedRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
