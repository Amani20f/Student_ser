import '../../../core/network/api_client.dart';
import '../models/study_plan_model.dart';

class StudyPlanRepository {
  final ApiClient _apiClient;

  StudyPlanRepository(this._apiClient);

  Future<StudyPlanModel?> getCurrentStudyPlan() async {
    try {
      final response = await _apiClient.get('/student/study-plan');
      final data = response['data'];
      if (data != null) {
        return StudyPlanModel.fromJson(data);
      }
      return null;
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('403')) {
        return null; // No plan found
      }
      rethrow;
    }
  }
}
