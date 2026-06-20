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

  // Only show grades if at least one meaningful filter is selected
  final hasActiveFilter = filters.values.any((value) =>
      value != null &&
      value.toString().isNotEmpty &&
      value != '__all__' &&
      value != '___all___');

  if (!hasActiveFilter) {
    return <GradeModel>[];
  }

  // Clean filters: remove __all__ values and convert IDs to strings for query params
  final cleanFilters = <String, dynamic>{};
  filters.forEach((key, value) {
    if (value == null || value == '__all__' || value == '___all___' || value.toString().isEmpty) {
      return; // skip
    }
    // Numeric ID fields
    if (key == 'semester_id' || key == 'course_id' || key == 'program_id') {
      final num = int.tryParse(value.toString());
      if (num != null) cleanFilters[key] = num;
    } else {
      cleanFilters[key] = value;
    }
  });

  if (cleanFilters.isEmpty) return <GradeModel>[];

  return repository.getAllGrades(filters: cleanFilters);
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
