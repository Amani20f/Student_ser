import '../../../core/network/api_client.dart';
import 'semester_model.dart';

class SemesterRepository {
  final ApiClient _apiClient;

  SemesterRepository(this._apiClient);

  Future<List<SemesterModel>> getSemesters() async {
    final data = await _apiClient.get('/admin/semesters');
    
    if (data != null && data['success'] == true) {
      final List<dynamic> list = data['data'];
      return list.map((json) => SemesterModel.fromJson(json)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load semesters');
  }

  Future<SemesterModel> createSemester(Map<String, dynamic> data) async {
    final responseData = await _apiClient.post(
      '/admin/semesters',
      body: data,
    );
    
    if (responseData != null && responseData['success'] == true) {
      return SemesterModel.fromJson(responseData['data']);
    }
    throw Exception(responseData['message'] ?? 'Failed to create semester');
  }

  Future<SemesterModel> updateSemester(int id, Map<String, dynamic> data) async {
    final responseData = await _apiClient.put(
      '/admin/semesters/$id',
      body: data,
    );
    
    if (responseData != null && responseData['success'] == true) {
      return SemesterModel.fromJson(responseData['data']);
    }
    throw Exception(responseData['message'] ?? 'Failed to update semester');
  }

  Future<void> deleteSemester(int id) async {
    final responseData = await _apiClient.delete('/admin/semesters/$id');
    
    if (responseData != null && responseData['success'] != true) {
      throw Exception(responseData['message'] ?? 'Failed to delete semester');
    }
  }
}
