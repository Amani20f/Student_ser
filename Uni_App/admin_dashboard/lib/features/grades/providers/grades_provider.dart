import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/grade_model.dart';
import '../data/grade_repository.dart';

final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GradeRepository(apiClient);
});

final gradeFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final allGradesProvider = FutureProvider<List<GradeModel>>((ref) async {
  final filters = ref.watch(gradeFiltersProvider);
  final repository = ref.watch(gradeRepositoryProvider);

  final hasActiveFilter = filters.values
      .any((value) => value != null && value.toString().isNotEmpty);
  if (!hasActiveFilter) {
    return <GradeModel>[];
  }

  return repository.getAllGrades(filters: filters);
});

/// Hardcoded semester options.
class SemesterOption {
  final int id;
  final String label;

  const SemesterOption(this.id, this.label);
}

const List<SemesterOption> semesterOptions = [
  SemesterOption(1, 'الفصل الدراسي الأول 2024/2025'),
  SemesterOption(2, 'الفصل الدراسي الثاني 2024/2025'),
  SemesterOption(3, 'الفصل الدراسي الأول 2025/2026'),
];
