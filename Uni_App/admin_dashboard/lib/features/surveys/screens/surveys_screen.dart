import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/surveys_provider.dart';
import 'package:intl/intl.dart';
import '../widgets/survey_form_dialog.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

class SurveysScreen extends ConsumerWidget {
  const SurveysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysState = ref.watch(surveysProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.surveyManagement),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showSurveyDialog(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l10n.addSurvey),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: surveysState.when(
        data: (surveys) {
          if (surveys.isEmpty) {
            return Center(child: Text(l10n.noSurveysAdded));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.titleLabel)),
                  DataColumn(label: Text(l10n.surveyLink)),
                  DataColumn(label: Text(l10n.requiredForGrades)),
                  DataColumn(label: Text(l10n.statusColumn)),
                  DataColumn(label: Text(l10n.dateAdded)),
                  DataColumn(label: Text(l10n.actionsColumn)),
                ],
                rows: surveys.map((survey) {
                  return DataRow(
                    cells: [
                      DataCell(Text(survey.title)),
                      DataCell(
                        Tooltip(
                          message: survey.googleFormUrl,
                          child: SizedBox(
                            width: 150,
                            child: Text(
                              survey.googleFormUrl,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Icon(
                          survey.isRequiredForGrades ? Icons.check_circle : Icons.cancel,
                          color: survey.isRequiredForGrades ? Colors.green : Colors.grey,
                        ),
                      ),
                      DataCell(
                        Switch(
                          value: survey.isActive,
                          onChanged: (val) {
                            ref.read(surveysProvider.notifier).toggleStatus(survey.id);
                          },
                        ),
                      ),
                      DataCell(Text(DateFormat('yyyy-MM-dd').format(survey.createdAt))),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showSurveyDialog(context, ref, survey: survey),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, ref, survey.id),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  void _showSurveyDialog(BuildContext context, WidgetRef ref, {var survey}) {
    showDialog(
      context: context,
      builder: (context) => SurveyFormDialog(survey: survey),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n.confirmDelete),
          content: Text(l10n.confirmDeleteSurvey),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ref.read(surveysProvider.notifier).deleteSurvey(id);
                Navigator.pop(ctx);
              },
              child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
