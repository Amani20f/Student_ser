import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/study_plan_model.dart';
import '../data/study_plan_repository.dart';

final studyPlanRepositoryProvider = Provider<StudyPlanRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StudyPlanRepository(apiClient);
});

final studyPlanFiltersProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {'program_id': -1};
});

final allStudyPlansProvider = FutureProvider<List<StudyPlanModel>>((ref) async {
  final repository = ref.watch(studyPlanRepositoryProvider);
  final filters = ref.watch(studyPlanFiltersProvider);
  return repository.getStudyPlans(
    programId: filters['program_id'] == -1 ? null : filters['program_id'],
  );
});
