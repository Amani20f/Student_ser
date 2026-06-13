import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../models/announcement.dart';
import 'announcements_state.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final ApiClient _apiClient;

  AnnouncementsCubit(this._apiClient) : super(AnnouncementsInitial());

  Future<void> fetchAnnouncements() async {
    emit(AnnouncementsLoading());
    try {
      final response = await _apiClient.get('/student/announcements');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final announcements = data.map((json) => Announcement.fromJson(json)).toList();
        emit(AnnouncementsLoaded(announcements));
      } else {
        emit(const AnnouncementsError('فشل في تحميل الإعلانات'));
      }
    } catch (e) {
      emit(const AnnouncementsError('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }
}
