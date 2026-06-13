import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/back_action_provider.dart';
import '../data/grade_model.dart';
import '../providers/grades_provider.dart';
import '../../../core/models/filter_definition.dart';
import '../../../core/widgets/filter_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final gradesAsync = ref.watch(allGradesProvider);

    // Listen for filter changes to update global back action
    ref.listen(gradeFiltersProvider, (_, __) => _updateBackAction(ref));

    final isAdmin = ref.watch(authProvider).primaryRole == 'admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Bar
        FilterBar(
          filters: [
            FilterDefinition(
              id: 'semester_id',
              label: l10n.semester,
              type: FilterType.dropdown,
              icon: Icons.calendar_today_rounded,
              options: semesterOptions.map((s) => FilterValue(label: s.label, value: s.id)).toList(),
            ),
            FilterDefinition(
              id: 'course_id', 
              label: l10n.courseIdPlaceholder,
              type: FilterType.text,
              icon: Icons.code_rounded,
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
            ref.read(gradeFiltersProvider.notifier).state = {
              ...current,
              id: value,
            };
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
    final hasActiveFilter = filters.values.any((value) => value != null && value.toString().isNotEmpty);
    
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
      error: (error, _) => Center(
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
      ),
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
