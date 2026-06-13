import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/semester_model.dart';
import '../data/semester_repository.dart';

final semesterRepositoryProvider = Provider<SemesterRepository>((ref) {
  return SemesterRepository(ref.watch(apiClientProvider));
});

final semestersProvider = FutureProvider<List<SemesterModel>>((ref) async {
  final repository = ref.watch(semesterRepositoryProvider);
  return repository.getSemesters();
});

class SemesterNotifier extends StateNotifier<AsyncValue<void>> {
  final SemesterRepository _repository;
  final Ref _ref;

  SemesterNotifier(this._repository, this._ref) : super(const AsyncData(null));

  Future<bool> createSemester(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repository.createSemester(data);
      state = const AsyncData(null);
      _ref.invalidate(semestersProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateSemester(int id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repository.updateSemester(id, data);
      state = const AsyncData(null);
      _ref.invalidate(semestersProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteSemester(int id) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteSemester(id);
      state = const AsyncData(null);
      _ref.invalidate(semestersProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final semesterNotifierProvider =
    StateNotifierProvider<SemesterNotifier, AsyncValue<void>>((ref) {
  return SemesterNotifier(ref.watch(semesterRepositoryProvider), ref);
});
