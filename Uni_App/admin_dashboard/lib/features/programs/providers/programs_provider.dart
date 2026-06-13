import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/program_model.dart';

final programsProvider = FutureProvider.autoDispose<List<ProgramModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiConstants.adminPrograms);
  final List data = response['data'] ?? [];
  return data.map((e) => ProgramModel.fromJson(e)).toList();
});

final publicProgramsProvider = FutureProvider.autoDispose<List<ProgramModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/programs');
  final List data = response['data'] ?? [];
  return data.map((e) => ProgramModel.fromJson(e)).toList();
});

class ProgramsNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiClient apiClient;
  final Ref ref;

  ProgramsNotifier(this.apiClient, this.ref) : super(const AsyncData(null));

  Future<void> createProgram(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await apiClient.post(ApiConstants.adminPrograms, body: data);
      ref.invalidate(programsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProgram(int id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await apiClient.put(ApiConstants.adminProgramById(id), body: data);
      ref.invalidate(programsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> archiveProgram(int id) async {
    state = const AsyncLoading();
    try {
      await apiClient.delete(ApiConstants.adminProgramById(id));
      ref.invalidate(programsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restoreProgram(int id) async {
    state = const AsyncLoading();
    try {
      await apiClient.post(ApiConstants.adminProgramRestore(id));
      ref.invalidate(programsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final programsNotifierProvider = StateNotifierProvider<ProgramsNotifier, AsyncValue<void>>((ref) {
  return ProgramsNotifier(ref.watch(apiClientProvider), ref);
});
