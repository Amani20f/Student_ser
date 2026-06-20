import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../../core/constants/role_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/back_action_provider.dart';
import '../data/grade_model.dart';
import '../providers/grades_provider.dart';
import '../../../core/models/filter_definition.dart';
import '../../../core/widgets/filter_bar.dart';
import '../../programs/providers/programs_provider.dart';
import '../../courses/providers/courses_provider.dart';

class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {

  void _updateBackAction(WidgetRef ref) {
    final filters = ref.read(gradeFiltersProvider);

    if (filters.isNotEmpty) {
      ref.read(backActionProvider.notifier).state = () {
        ref.read(gradeFiltersProvider.notifier).state = {};
      };
    } else {
      ref.read(backActionProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final gradesAsync = ref.watch(allGradesProvider);
    // Use staff-accessible providers so grade_control can access them
    final programsAsync = ref.watch(staffProgramsProvider);
    final coursesAsync = ref.watch(staffCoursesProvider);

    final programs = programsAsync.value ?? [];
    final allCourses = coursesAsync.value ?? [];

    final currentFilters = ref.watch(gradeFiltersProvider);
    final selectedProgramIdRaw = currentFilters['program_id'];
    // Normalize to int for proper comparison with CourseModel.programId
    final selectedProgramId = selectedProgramIdRaw is int
        ? selectedProgramIdRaw
        : (selectedProgramIdRaw != null && selectedProgramIdRaw != '__all__'
            ? int.tryParse(selectedProgramIdRaw.toString())
            : null);

    final courses = (selectedProgramId != null)
        ? allCourses.where((c) => c.programId == selectedProgramId).toList()
        : allCourses;

    // Listen for filter changes to update global back action
    ref.listen(gradeFiltersProvider, (_, __) => _updateBackAction(ref));

    final role = ref.watch(authProvider).primaryRole;
    final isAdmin = role == 'admin';
    final canImport = RoleConstants.canAccess(role, '/grades/import');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canImport) ...[
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/grades/import'),
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'استيراد الدرجات من إكسل'
                    : 'Import Grades from Excel',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Filter Bar
        FilterBar(
          filters: [
            FilterDefinition(
              id: 'program_id',
              label: l10n.specializationLabel,
              type: FilterType.dropdown,
              icon: Icons.school_outlined,
              options: programs.map((p) => FilterValue(label: p.name, value: p.id)).toList(),
            ),
            FilterDefinition(
              id: 'course_id',
              label: l10n.courseColumn,
              type: FilterType.dropdown,
              icon: Icons.book_rounded,
              options: courses.map((c) => FilterValue(label: c.courseName, value: c.id)).toList(),
            ),
            FilterDefinition(
              id: 'semester_id',
              label: l10n.semester,
              type: FilterType.dropdown,
              icon: Icons.calendar_today_rounded,
              options: semesterOptions.map((s) => FilterValue(label: s.label, value: s.id)).toList(),
            ),
            FilterDefinition(
              id: 'status',
              label: l10n.statusColumn,
              type: FilterType.dropdown,
              icon: Icons.info_outline,
              options: [
                FilterValue(label: l10n.passed, value: 'passed'),
                FilterValue(label: l10n.failed, value: 'failed'),
              ],
            ),
            FilterDefinition(
              id: 'search',
              label: l10n.searchNameCardPlaceholder,
              type: FilterType.text,
              icon: Icons.person_search_outlined,
            ),
          ],
          currentValues: ref.watch(gradeFiltersProvider),
          onFilterChanged: (id, value) {
            final current = ref.read(gradeFiltersProvider);
            final newFilters = {
              ...current,
              id: value,
            };
            if (id == 'program_id') {
              newFilters['course_id'] = '__all__';
            }
            ref.read(gradeFiltersProvider.notifier).state = newFilters;
          },
          onClearAll: () {
            ref.read(gradeFiltersProvider.notifier).state = {};
          },
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 32),

        // ── Content Area ───────────────────────────────────────────────────
        Expanded(
          child: _buildContent(gradesAsync, l10n, cs, tt, isAdmin),
        ),
      ],
    );
  }

  Widget _buildContent(
    AsyncValue<List<GradeModel>> gradesAsync,
    AppLocalizations l10n,
    ColorScheme cs,
    TextTheme tt,
    bool isAdmin,
  ) {
    final filters = ref.watch(gradeFiltersProvider);
    final hasActiveFilter = filters.values.any((value) =>
        value != null &&
        value.toString().isNotEmpty &&
        value != '__all__' &&
        value != '___all___');
    
    if (!hasActiveFilter) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_rounded,
              color: cs.primary.withAlpha(100),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectFiltersToSearch,
              textAlign: TextAlign.center,
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface.withAlpha(140),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return gradesAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: cs.primary)),
      error: (error, _) {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        final errStr = error.toString().toLowerCase();
        if (errStr.contains('right roles') || errStr.contains('right permissions') || errStr.contains('403') || errStr.contains('unauthorized')) {
          return Center(
            child: Text(
              isAr ? 'ليس لديك صلاحية الوصول إلى هذه الصفحة' : 'You do not have permission to access this page',
              style: tt.titleMedium?.copyWith(color: cs.error, fontWeight: FontWeight.bold),
            ),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: cs.error, size: 48),
              const SizedBox(height: 16),
              Text('${l10n.failedToLoadGrades}: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(allGradesProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        );
      },
      data: (grades) {
        if (grades.isEmpty) {
          return Center(
            child: Text(
              l10n.noGradesFound,
              style: tt.titleMedium?.copyWith(color: cs.onSurface.withAlpha(120)),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant.withAlpha(40)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withAlpha(8),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 32,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(label: Text(l10n.studentColumn)),
                    DataColumn(label: Text(l10n.courseColumn)),
                    DataColumn(label: Text(l10n.semesterColumn)),
                    DataColumn(label: Text(l10n.firstColumn)),
                    DataColumn(label: Text(l10n.secondColumn)),
                    DataColumn(label: Text(l10n.midtermColumn)),
                    DataColumn(label: Text(l10n.finalColumn)),
                    DataColumn(label: Text(l10n.totalColumn)),
                    if (!isAdmin) DataColumn(label: Text(l10n.actionsColumn)),
                  ],
                  rows: grades.asMap().entries.map((entry) {
                    return _buildRow(context, entry.value, isAdmin);
                  }).toList(),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
      },
    );
  }

  DataRow _buildRow(BuildContext context, GradeModel grade, bool isAdmin) {
    final cs = Theme.of(context).colorScheme;

    return DataRow(
      cells: [
        DataCell(Text(grade.studentName ?? '—')),
        DataCell(Text(grade.courseName ?? '—')),
        DataCell(Text(grade.semesterDisplay)),
        DataCell(Text(grade.first?.toString() ?? '—')),
        DataCell(Text(grade.second?.toString() ?? '—')),
        DataCell(Text(grade.midterm?.toString() ?? '—')),
        DataCell(Text(grade.finalScore?.toString() ?? '—')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              grade.total.toString(),
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (!isAdmin)
          DataCell(
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showEditDialog(context, grade),
              tooltip: AppLocalizations.of(context)!.editGrade,
            ),
          ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, GradeModel grade) {
    final l10n = AppLocalizations.of(context)!;
    final firstCtrl = TextEditingController(text: grade.first?.toString());
    final secondCtrl = TextEditingController(text: grade.second?.toString());
    final midCtrl = TextEditingController(text: grade.midterm?.toString());
    final finalCtrl = TextEditingController(text: grade.finalScore?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editGradeTitle(grade.courseName ?? '')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(firstCtrl, l10n.firstColumn),
            _buildDialogField(secondCtrl, l10n.secondColumn),
            _buildDialogField(midCtrl, l10n.midtermColumn),
            _buildDialogField(finalCtrl, l10n.finalColumn),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(gradeRepositoryProvider).updateGrade(
                  grade.id,
                  first: double.tryParse(firstCtrl.text),
                  second: double.tryParse(secondCtrl.text),
                  midterm: double.tryParse(midCtrl.text),
                  finalScore: double.tryParse(finalCtrl.text),
                );
                ref.invalidate(allGradesProvider);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Update failed: $e')),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }


  Widget _buildDialogField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
