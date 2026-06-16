import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import 'study_plan_model.dart';

class StudyPlanRepository {
  final ApiClient _apiClient;

  StudyPlanRepository(this._apiClient);

  Future<List<StudyPlanModel>> getStudyPlans({int? programId}) async {
    final queryParams = <String, String>{};
    if (programId != null && programId != -1) {
      queryParams['program_id'] = programId.toString();
    }

    final response = await _apiClient.get(
      '/staff/study-plans',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response['data'] as List<dynamic>;
    return data.map((e) => StudyPlanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createStudyPlan({
    required int programId,
    required List<int> fileBytes,
    required String filename,
  }) async {
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
    );

    final fields = {
      'program_id': programId.toString(),
      'title': 'Study Plan',
    };

    await _apiClient.multipartRequest(
      'POST',
      '/staff/study-plans',
      fields: fields,
      files: [multipartFile],
    );
  }

  Future<void> updateStudyPlan(
    int id, {
    required List<int> fileBytes,
    required String filename,
  }) async {
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
    );

    final fields = {
      '_method': 'PUT',
      'title': 'Study Plan',
    };

    await _apiClient.multipartRequest(
      'POST',
      '/staff/study-plans/$id',
      fields: fields,
      files: [multipartFile],
    );
  }

  Future<void> deleteStudyPlan(int id) async {
    await _apiClient.delete('/staff/study-plans/$id');
  }
}
