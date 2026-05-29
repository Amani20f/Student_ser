import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'appeal_model.dart';

class AppealRepository {
  final ApiClient _apiClient;

  AppealRepository(this._apiClient);

  Future<List<AppealModel>> getAppeals({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      ApiConstants.staffAppeals,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => AppealModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppealModel>> getUnderReviewAppeals() async {
    final response = await _apiClient.get(ApiConstants.staffAppealsUnderReview);
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => AppealModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppealModel> getAppealDetails(int id) async {
    final response = await _apiClient.get(ApiConstants.staffAppealDetails(id));
    return AppealModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> reviewAppeal({
    required int appealId,
    required String decision,
    String? committeeReport,
    List<Map<String, dynamic>>? items,
  }) async {
    final body = {
      'decision': decision,
      if (committeeReport != null) 'committee_report': committeeReport,
      if (items != null) 'items': items,
    };

    await _apiClient.put(
      ApiConstants.staffAppealReview(appealId),
      body: body,
    );
  }
}
