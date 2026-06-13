import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'study_schedule_model.dart';

class StudyScheduleRepository {
  final ApiClient _apiClient;

  StudyScheduleRepository(this._apiClient);

  /// Fetch all study schedules with optional filters.
  Future<List<StudyScheduleModel>> getSchedules({
    int? programId,
    int? semesterId,
    int? level,
  }) async {
    final queryParams = <String, String>{};
    if (programId != null && programId != -1) {
      queryParams['program_id'] = programId.toString();
    }
    if (semesterId != null && semesterId != -1) {
      queryParams['semester_id'] = semesterId.toString();
    }
    if (level != null && level != -1) {
      queryParams['level'] = level.toString();
    }

    final response = await _apiClient.get(
      ApiConstants.staffStudySchedules,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => StudyScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch semesters from the newly activated endpoint.
  Future<List<SemesterModel>> getSemesters() async {
    final response = await _apiClient.get(ApiConstants.semesters);
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => SemesterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a new study schedule.
  Future<void> createSchedule({
    required int programId,
    required int semesterId,
    required int level,
    required List<int> fileBytes,
    required String filename,
    String? notes,
  }) async {
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      fileBytes,
      filename: filename,
    );

    final fields = {
      'program_id': programId.toString(),
      'semester_id': semesterId.toString(),
      'level': level.toString(),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    await _apiClient.multipartRequest(
      'POST',
      ApiConstants.staffStudySchedules,
      fields: fields,
      files: [multipartFile],
    );
  }

  /// Update an existing study schedule.
  /// If [fileBytes] is provided, performs a multipart POST request with '_method': 'PUT' to support PHP's file upload constraints on PUT routes.
  /// Otherwise, updates notes using a standard JSON PUT request.
  Future<void> updateSchedule(
    int id, {
    List<int>? fileBytes,
    String? filename,
    String? notes,
  }) async {
    if (fileBytes != null && filename != null) {
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        fileBytes,
        filename: filename,
      );

      final fields = {
        '_method': 'PUT',
        if (notes != null) 'notes': notes,
      };

      await _apiClient.multipartRequest(
        'POST',
        ApiConstants.staffStudyScheduleById(id),
        fields: fields,
        files: [multipartFile],
      );
    } else {
      await _apiClient.put(
        ApiConstants.staffStudyScheduleById(id),
        body: {
          'notes': notes ?? '',
        },
      );
    }
  }

  /// Delete a study schedule.
  Future<void> deleteSchedule(int id) async {
    await _apiClient.delete(ApiConstants.staffStudyScheduleById(id));
  }
}
