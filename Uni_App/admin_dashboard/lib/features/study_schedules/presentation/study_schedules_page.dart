import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/study_schedules_provider.dart';
import '../data/study_schedule_model.dart';
import '../../programs/providers/programs_provider.dart';

class StudySchedulesPage extends ConsumerWidget {
  const StudySchedulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final schedulesAsync = ref.watch(allStudySchedulesProvider);
    final filters = ref.watch(studyScheduleFiltersProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilterBar(context, ref, filters),
          const Divider(height: 1),
          Expanded(
            child: schedulesAsync.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return Center(
                    child: Text(l10n.noStudySchedules ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(schedule.programName ?? 'Unknown Program'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${l10n.level} ${schedule.level} | ${schedule.term ?? ""} ${schedule.academicYear ?? ""}'),
                            if (schedule.notes != null && schedule.notes!.isNotEmpty)
                              Text('${l10n.notes}: ${schedule.notes}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (schedule.scheduleImageUrl != null && schedule.scheduleImageUrl!.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () async {
                                  final url = schedule.scheduleImageUrl!;
                                  if (url.toLowerCase().endsWith('.pdf')) {
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  } else {
                                    _showImageDialog(context, url);
                                  }
                                },
                                tooltip: l10n.viewSchedule,
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showScheduleDialog(context, ref, schedule),
                              tooltip: l10n.editSchedule ,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, ref, schedule),
                              tooltip: 'Delete',
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
    final programsAsync = ref.watch(programsProvider);
    final semestersAsync = ref.watch(dynamicSemestersProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Program Filter
          programsAsync.when(
            data: (programs) => DropdownButton<int>(
              value: filters['program_id'] == -1 ? null : filters['program_id'],
              hint: Text(l10n.allPrograms ),
              items: [
                DropdownMenuItem(value: -1, child: Text(l10n.allPrograms )),
                ...programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
              ],
              onChanged: (val) {
                ref.read(studyScheduleFiltersProvider.notifier).update((state) => {...state, 'program_id': val ?? -1});
              },
            ),
            loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Text('Error loading programs'),
          ),

          // Semester Filter
          semestersAsync.when(
            data: (semesters) => DropdownButton<int>(
              value: filters['semester_id'] == -1 ? null : filters['semester_id'],
              hint: Text(l10n.allSemesters ),
              items: [
                DropdownMenuItem(value: -1, child: Text(l10n.allSemesters )),
                ...semesters.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} - ${s.year}'))),
              ],
              onChanged: (val) {
                ref.read(studyScheduleFiltersProvider.notifier).update((state) => {...state, 'semester_id': val ?? -1});
              },
            ),
            loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Text('Error loading semesters'),
          ),

          // Level Filter
          DropdownButton<int>(
            value: filters['level'] == -1 ? null : filters['level'],
            hint: Text(l10n.allLevels ),
            items: [
              DropdownMenuItem(value: -1, child: Text(l10n.allLevels )),
              ...List.generate(8, (index) => index + 1).map((lvl) => DropdownMenuItem(value: lvl, child: Text('${l10n.level} $lvl'))),
            ],
            onChanged: (val) {
              ref.read(studyScheduleFiltersProvider.notifier).update((state) => {...state, 'level': val ?? -1});
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, StudyScheduleModel schedule) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete ),
        content: Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(studyScheduleRepositoryProvider).deleteSchedule(schedule.id);
                ref.invalidate(allStudySchedulesProvider);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: Text(l10n.delete , style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.preview,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: cs.onSurface.withAlpha(100), size: 48),
                          const SizedBox(height: 8),
                          Text(l10n.failedToLoadImage),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, WidgetRef ref, StudyScheduleModel? schedule) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = schedule != null;
    
    int? selectedProgram = schedule?.programId;
    int? selectedSemester = schedule?.semesterId;
    int? selectedLevel = schedule?.level;
    final notesCtrl = TextEditingController(text: schedule?.notes);
    
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final programsAsync = ref.watch(programsProvider);
            final semestersAsync = ref.watch(dynamicSemestersProvider);

            return AlertDialog(
              title: Text(isEdit ? (l10n.editSchedule ) : (l10n.addStudySchedule )),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEdit) ...[
                      // Program
                      programsAsync.maybeWhen(
                        data: (programs) => DropdownButtonFormField<int>(
                          decoration: InputDecoration(labelText: l10n.programName),
                          initialValue: selectedProgram,
                          items: programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) => setState(() => selectedProgram = val),
                        ),
                        orElse: () => const CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 12),
                      
                      // Semester
                      semestersAsync.maybeWhen(
                        data: (semesters) => DropdownButtonFormField<int>(
                          decoration: const InputDecoration(labelText: 'Semester'),
                          initialValue: selectedSemester,
                          items: semesters.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} - ${s.year}'))).toList(),
                          onChanged: (val) => setState(() => selectedSemester = val),
                        ),
                        orElse: () => const CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 12),

                      // Level
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(labelText: l10n.level),
                        initialValue: selectedLevel,
                        items: List.generate(8, (index) => index + 1).map((lvl) => DropdownMenuItem(value: lvl, child: Text('$lvl'))).toList(),
                        onChanged: (val) => setState(() => selectedLevel = val),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Notes
                    TextFormField(
                      controller: notesCtrl,
                      decoration: InputDecoration(labelText: l10n.notes),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // File Picker
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                              withData: true,
                            );
                            if (result != null) {
                              setState(() => pickedFile = result.files.first);
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: Text(pickedFile != null ? (pickedFile!.name) : 'Pick PDF/Image'),
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
                    if (!isEdit && (selectedProgram == null || selectedSemester == null || selectedLevel == null || pickedFile == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select a file.')));
                      return;
                    }

                    try {
                      final repo = ref.read(studyScheduleRepositoryProvider);
                      if (isEdit) {
                        await repo.updateSchedule(
                          schedule.id,
                          fileBytes: pickedFile?.bytes,
                          filename: pickedFile?.name,
                          notes: notesCtrl.text,
                        );
                      } else {
                        await repo.createSchedule(
                          programId: selectedProgram!,
                          semesterId: selectedSemester!,
                          level: selectedLevel!,
                          fileBytes: pickedFile!.bytes!,
                          filename: pickedFile!.name,
                          notes: notesCtrl.text,
                        );
                      }
                      ref.invalidate(allStudySchedulesProvider);
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
