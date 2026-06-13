import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/survey.dart';

final surveysProvider = StateNotifierProvider<SurveysNotifier, AsyncValue<List<Survey>>>((ref) {
  return SurveysNotifier(ref.watch(apiClientProvider));
});

class SurveysNotifier extends StateNotifier<AsyncValue<List<Survey>>> {
  final ApiClient _apiClient;

  SurveysNotifier(this._apiClient) : super(const AsyncValue.loading()) {
    loadSurveys();
  }

  Future<void> loadSurveys() async {
    try {
      state = const AsyncValue.loading();
      final response = await _apiClient.get('/staff/surveys');
      final surveys = (response as List).map((json) => Survey.fromJson(json)).toList();
      state = AsyncValue.data(surveys);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createSurvey(Map<String, dynamic> data) async {
    await _apiClient.post('/staff/surveys', body: data);
    await loadSurveys();
  }

  Future<void> updateSurvey(int id, Map<String, dynamic> data) async {
    await _apiClient.put('/staff/surveys/$id', body: data);
    await loadSurveys();
  }

  Future<void> deleteSurvey(int id) async {
    await _apiClient.delete('/staff/surveys/$id');
    await loadSurveys();
  }

  Future<void> toggleStatus(int id) async {
    await _apiClient.patch('/staff/surveys/$id/toggle', body: {});
    await loadSurveys();
  }
}
