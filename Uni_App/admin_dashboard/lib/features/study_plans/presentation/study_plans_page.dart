import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/study_plans_provider.dart';
import '../data/study_plan_model.dart';
import '../../programs/providers/programs_provider.dart';

class StudyPlansPage extends ConsumerWidget {
  const StudyPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final plansAsync = ref.watch(allStudyPlansProvider);
    final filters = ref.watch(studyPlanFiltersProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilterBar(context, ref, filters),
          const Divider(height: 1),
          Expanded(
            child: plansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return Center(
                    child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'لا توجد خطط دراسية' : 'No Study Plans'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(plan.programName ?? 'Unknown Program'),
                        subtitle: Text('${Localizations.localeOf(context).languageCode == 'ar' ? 'تاريخ الرفع:' : 'Uploaded at:'} ${plan.uploadedAt != null ? plan.uploadedAt.toString().split(' ')[0] : '-'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (plan.fileUrl != null && plan.fileUrl!.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                                onPressed: () async {
                                  final uri = Uri.parse(plan.fileUrl!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                tooltip: l10n.viewDetails,
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showPlanDialog(context, ref, plan),
                              tooltip: l10n.edit,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, ref, plan),
                              tooltip: l10n.delete,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('${l10n.error}: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, Map<String, dynamic> filters) {
    final l10n = AppLocalizations.of(context)!;
    final programsAsync = ref.watch(publicProgramsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          programsAsync.when(
            data: (programs) => DropdownButton<int>(
              value: filters['program_id'] == -1 ? null : filters['program_id'],
              hint: Text(l10n.allPrograms),
              items: [
                DropdownMenuItem(value: -1, child: Text(l10n.allPrograms)),
                ...programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
              ],
              onChanged: (val) {
                ref.read(studyPlanFiltersProvider.notifier).update((state) => {...state, 'program_id': val ?? -1});
              },
            ),
            loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Text('Error loading programs'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, StudyPlanModel plan) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'هل أنت متأكد من حذف الخطة الدراسية؟' : 'Are you sure you want to delete this study plan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(studyPlanRepositoryProvider).deleteStudyPlan(plan.id);
                ref.invalidate(allStudyPlansProvider);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPlanDialog(BuildContext context, WidgetRef ref, StudyPlanModel? plan) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = plan != null;
    
    int? selectedProgram = plan?.programId;
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final programsAsync = ref.watch(publicProgramsProvider);

            return AlertDialog(
              title: Text(isEdit 
                ? (Localizations.localeOf(context).languageCode == 'ar' ? 'تعديل الخطة الدراسية' : 'Edit Study Plan') 
                : (Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة خطة دراسية' : 'Add Study Plan')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEdit)
                      programsAsync.maybeWhen(
                        data: (programs) => DropdownButtonFormField<int>(
                          decoration: InputDecoration(labelText: Localizations.localeOf(context).languageCode == 'ar' ? 'التخصص' : 'Program'),
                          initialValue: selectedProgram,
                          items: programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) => setState(() => selectedProgram = val),
                        ),
                        orElse: () => const CircularProgressIndicator(),
                      ),
                    if (!isEdit) const SizedBox(height: 16),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                              withData: true,
                            );
                            if (result != null) {
                              setState(() => pickedFile = result.files.first);
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text(pickedFile != null ? (pickedFile!.name) : (Localizations.localeOf(context).languageCode == 'ar' ? 'اختر ملف PDF' : 'Pick PDF File')),
                        ),
                        if (pickedFile != null)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: () => setState(() => pickedFile = null),
                          )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                ElevatedButton(
                  onPressed: () async {
                    if (!isEdit && selectedProgram == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار التخصص')));
                      return;
                    }
                    if (pickedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إرفاق ملف PDF')));
                      return;
                    }

                    try {
                      final repo = ref.read(studyPlanRepositoryProvider);
                      if (isEdit) {
                        await repo.updateStudyPlan(
                          plan.id,
                          fileBytes: pickedFile!.bytes!,
                          filename: pickedFile!.name,
                        );
                      } else {
                        await repo.createStudyPlan(
                          programId: selectedProgram!,
                          fileBytes: pickedFile!.bytes!,
                          filename: pickedFile!.name,
                        );
                      }
                      ref.invalidate(allStudyPlansProvider);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
