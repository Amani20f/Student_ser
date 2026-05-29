import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'grade_model.dart';

class GradeRepository {
  final ApiClient _apiClient;

  GradeRepository(this._apiClient);

  Future<List<GradeModel>> getAllGrades({Map<String, dynamic>? filters}) async {
    final queryParams = <String, String>{};
    filters?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        queryParams[key] = value.toString();
      }
    });

    final response = await _apiClient.get(
      ApiConstants.staffGrades, // Need to verify this constant exists
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => GradeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }


  Future<void> updateGrade(
    int id, {
    double? first,
    double? second,
    double? midterm,
    double? finalScore,
  }) async {
    final body = <String, dynamic>{};
    if (first != null) body['first'] = first;
    if (second != null) body['second'] = second;
    if (midterm != null) body['midterm'] = midterm;
    if (finalScore != null) body['final'] = finalScore;

    await _apiClient.put(ApiConstants.staffGradeUpdate(id), body: body);
  }
}
