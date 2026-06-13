import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/study_schedule_model.dart';
import '../data/study_schedule_repository.dart';

final studyScheduleRepositoryProvider = Provider<StudyScheduleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StudyScheduleRepository(apiClient);
});

/// Filters provider for Study Schedules: Map of String to dynamic values
/// Keys: 'program_id', 'semester_id', 'level'
final studyScheduleFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'program_id': -1,
  'semester_id': -1,
  'level': -1,
});

/// Provider to fetch study schedules based on active filters
final allStudySchedulesProvider = FutureProvider<List<StudyScheduleModel>>((ref) async {
  final repository = ref.watch(studyScheduleRepositoryProvider);
  final filters = ref.watch(studyScheduleFiltersProvider);

  return repository.getSchedules(
    programId: filters['program_id'] as int?,
    semesterId: filters['semester_id'] as int?,
    level: filters['level'] as int?,
  );
});

/// Provider to fetch dynamic semesters from API
final dynamicSemestersProvider = FutureProvider<List<SemesterModel>>((ref) async {
  final repository = ref.watch(studyScheduleRepositoryProvider);
  return repository.getSemesters();
});
