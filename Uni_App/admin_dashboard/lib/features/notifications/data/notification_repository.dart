import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get(ApiConstants.staffNotifications);
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(int id) async {
    await _apiClient.put(ApiConstants.staffMarkNotificationRead(id), body: {});
  }

  Future<void> sendNotification({
    required String title,
    required String message,
    required String targetRole,
  }) async {
    await _apiClient.post(
      ApiConstants.staffNotifications,
      body: {
        'title': title,
        'message': message,
        'target_role': targetRole,
      },
    );
  }
}
