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
    required String recipientType,
    String? targetRole,
    int? userId,
    List<int>? userIds,
  }) async {
    final Map<String, dynamic> body = {
      'title': title,
      'message': message,
      'recipient_type': recipientType,
    };

    if (recipientType == 'role' && targetRole != null) {
      body['target_role'] = targetRole;
    } else if (recipientType == 'specific' && userId != null) {
      body['user_id'] = userId;
    } else if (recipientType == 'multiple' && userIds != null) {
      body['user_ids'] = userIds;
    }

    await _apiClient.post(
      ApiConstants.staffNotifications,
      body: body,
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _apiClient.get(ApiConstants.staffUsers);
    final data = response['data'] as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
