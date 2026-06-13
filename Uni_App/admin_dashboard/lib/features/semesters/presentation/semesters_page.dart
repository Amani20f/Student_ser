import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/semesters_provider.dart';
import '../data/semester_model.dart';
import 'semester_dialog.dart';
import '../../../l10n/app_localizations.dart';

class SemestersPage extends ConsumerWidget {
  const SemestersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semestersAsync = ref.watch(semestersProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.semestersManagement),
            floating: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () => _showSemesterDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addSemester),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: semestersAsync.when(
              data: (semesters) {
                if (semesters.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.noSemestersAdded),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: cs.outlineVariant.withAlpha(100)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(cs.surfaceContainerHighest.withAlpha(100)),
                        dataRowMaxHeight: 64,
                        columns: [
                          DataColumn(label: Text(l10n.semesterAndYear)),
                          DataColumn(label: Text(l10n.status)),
                          DataColumn(label: Text(l10n.startDate)),
                          DataColumn(label: Text(l10n.endDate)),
                          DataColumn(label: Text(l10n.examsStart)),
                          DataColumn(label: Text(l10n.actions)),
                        ],
                        rows: semesters.map((semester) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.date_range, color: cs.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      semester.displayLabel,
                                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: semester.isActive ? Colors.green.withAlpha(30) : Colors.grey.withAlpha(30),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: semester.isActive ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        semester.isActive ? Icons.check_circle : Icons.do_disturb_alt,
                                        color: semester.isActive ? Colors.green : Colors.grey,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        semester.isActive ? l10n.active : l10n.inactive,
                                        style: TextStyle(
                                          color: semester.isActive ? Colors.green : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(semester.startDate.split('T').first)),
                              DataCell(Text(semester.endDate.split('T').first)),
                              DataCell(Text(semester.examsStartDate.split('T').first)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      color: cs.primary,
                                      tooltip: l10n.edit,
                                      onPressed: () => _showSemesterDialog(context, ref, semester),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: cs.error,
                                      tooltip: l10n.delete,
                                      onPressed: () => _confirmDelete(context, ref, semester),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(l10n.error(err.toString()), style: TextStyle(color: cs.error)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSemesterDialog(BuildContext context, WidgetRef ref, [SemesterModel? semester]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SemesterDialog(semester: semester),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SemesterModel semester) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteSemester(semester.displayLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final errorColor = Theme.of(context).colorScheme.error;
              final notifier = ref.read(semesterNotifierProvider.notifier);
              
              final success = await notifier.deleteSemester(semester.id);
              
              if (success) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(l10n.deleteSuccess)),
                );
              } else {
                final errorState = ref.read(semesterNotifierProvider);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(errorState.error?.toString() ?? l10n.deleteFailed),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
