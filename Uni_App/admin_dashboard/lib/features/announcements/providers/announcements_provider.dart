import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/announcement.dart';

final announcementsProvider = StateNotifierProvider<AnnouncementsNotifier, AsyncValue<List<Announcement>>>((ref) {
  return AnnouncementsNotifier(ref.watch(apiClientProvider));
});

class AnnouncementsNotifier extends StateNotifier<AsyncValue<List<Announcement>>> {
  final ApiClient apiClient;

  AnnouncementsNotifier(this.apiClient) : super(const AsyncValue.loading()) {
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    state = const AsyncValue.loading();
    try {
      final response = await apiClient.get('/staff/announcements');
      if (response != null) {
        final List<dynamic> data = response;
        final announcements = data.map((json) => Announcement.fromJson(json)).toList();
        state = AsyncValue.data(announcements);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createAnnouncement(Map<String, dynamic> data, {http.MultipartFile? imageFile}) async {
    try {
      if (imageFile != null) {
        final Map<String, String> stringData = data.map((key, value) {
          if (value is bool) return MapEntry(key, value ? '1' : '0');
          return MapEntry(key, value.toString());
        });
        await apiClient.multipartRequest('POST', '/staff/announcements', fields: stringData, files: [imageFile]);
      } else {
        await apiClient.post('/staff/announcements', body: data);
      }
      await fetchAnnouncements();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAnnouncement(int id, Map<String, dynamic> data, {http.MultipartFile? imageFile}) async {
    try {
      if (imageFile != null) {
        final Map<String, String> stringData = data.map((key, value) {
          if (value is bool) return MapEntry(key, value ? '1' : '0');
          return MapEntry(key, value.toString());
        });
        stringData['_method'] = 'PUT'; // Laravel workaround
        await apiClient.multipartRequest('POST', '/staff/announcements/$id', fields: stringData, files: [imageFile]);
      } else {
        await apiClient.put('/staff/announcements/$id', body: data);
      }
      await fetchAnnouncements();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAnnouncement(int id) async {
    try {
      await apiClient.delete('/staff/announcements/$id');
      if (state.hasValue) {
        final current = state.value!;
        state = AsyncValue.data(current.where((a) => a.id != id).toList());
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleActive(int id) async {
    try {
      await apiClient.patch('/staff/announcements/$id/toggle');
      await fetchAnnouncements();
      return true;
    } catch (e) {
      return false;
    }
  }
}
