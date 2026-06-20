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
      final List<dynamic> data = await _apiClient.get('/student/announcements');
      final announcements = data.map((json) => Announcement.fromJson(json)).toList();
      emit(AnnouncementsLoaded(announcements));
    } catch (e) {
      emit(const AnnouncementsError('حدث خطأ أثناء الاتصال بالخادم'));
    }
  }
}
