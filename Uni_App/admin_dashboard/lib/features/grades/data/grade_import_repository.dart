import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

final gradeImportRepositoryProvider = Provider<GradeImportRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GradeImportRepository(apiClient);
});

class GradeImportRepository {
  final ApiClient _apiClient;

  GradeImportRepository(this._apiClient);

  /// Download template URL helper
  String get templateDownloadUrl {
    // Because we just need a link to open in the browser or download
    return '${ApiConstants.baseUrl}${ApiConstants.staffGradesImportTemplate}';
  }

  /// Upload the file to get preview data and headers
  Future<Map<String, dynamic>> previewFile(
    List<int> fileBytes,
    String filename,
  ) async {
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
    );

    final response = await _apiClient.multipartRequest(
      'POST',
      ApiConstants.staffGradesImportPreview,
      files: [multipartFile],
    );

    return response as Map<String, dynamic>;
  }

  /// Validate the mapping before saving
  Future<Map<String, dynamic>> validateImport(
    String tempPath,
    Map<String, String> mapping,
    int semesterId,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.staffGradesImportValidate,
      body: {
        'temp_path': tempPath,
        'mapping': mapping,
        'semester_id': semesterId,
      },
    );

    return response as Map<String, dynamic>;
  }

  /// Commit the import
  Future<Map<String, dynamic>> storeImport(
    String tempPath,
    Map<String, String> mapping,
    int semesterId,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.staffGradesImportStore,
      body: {
        'temp_path': tempPath,
        'mapping': mapping,
        'semester_id': semesterId,
      },
    );

    return response as Map<String, dynamic>;
  }
}
