import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/course_model.dart';

final coursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiConstants.adminCourses);
  final List data = response['data'] ?? [];
  return data.map((e) => CourseModel.fromJson(e)).toList();
});

class CoursesNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiClient apiClient;
  final Ref ref;

  CoursesNotifier(this.apiClient, this.ref) : super(const AsyncData(null));

  Future<void> createCourse(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await apiClient.post(ApiConstants.adminCourses, body: data);
      ref.invalidate(coursesProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCourse(int id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await apiClient.put(ApiConstants.adminCourseById(id), body: data);
      ref.invalidate(coursesProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> archiveCourse(int id) async {
    state = const AsyncLoading();
    try {
      await apiClient.delete(ApiConstants.adminCourseById(id));
      ref.invalidate(coursesProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restoreCourse(int id) async {
    state = const AsyncLoading();
    try {
      await apiClient.post(ApiConstants.adminCourseRestore(id));
      ref.invalidate(coursesProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final coursesNotifierProvider = StateNotifierProvider<CoursesNotifier, AsyncValue<void>>((ref) {
  return CoursesNotifier(ref.watch(apiClientProvider), ref);
});
