import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'log_model.dart';

class LogRepository {
  final ApiClient _apiClient;

  LogRepository(this._apiClient);

  Future<List<LogModel>> getLogs({String? action, DateTime? from, DateTime? to}) async {
    final url = ApiConstants.adminLogsFiltered(action: action, from: from, to: to);
    final response = await _apiClient.get(url);
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => LogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
