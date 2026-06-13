import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../providers/programs_provider.dart';
import '../data/program_model.dart';

class ProgramsPage extends ConsumerWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final programsAsync = ref.watch(programsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProgramDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: programsAsync.when(
        data: (programs) {
          if (programs.isEmpty) {
            return Center(
                child: Text(l10n
                    .notApplicable)); // or a specific translation if available
          }
          return ListView.builder(
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final prog = programs[index];
              return Card(
                color: prog.isArchived ? Colors.grey[300] : null,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${prog.name} (${prog.code})'),
                  subtitle: Text(
                    '${l10n.programFees}: \$${prog.fees.toStringAsFixed(2)} | ${l10n.programDuration}: ${prog.durationYears} | ${prog.isArchived ? "ARCHIVED" : "ACTIVE"}',
                    style: TextStyle(
                        color: prog.isArchived ? Colors.red : Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showProgramDialog(context, ref, prog),
                      ),
                      if (prog.isArchived)
                        IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          onPressed: () => ref
                              .read(programsNotifierProvider.notifier)
                              .restoreProgram(prog.id),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.archive, color: Colors.orange),
                          onPressed: () => _confirmArchive(context, ref, prog),
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
    );
  }

  void _confirmArchive(BuildContext context, WidgetRef ref, ProgramModel prog) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Program'),
        content: Text('Are you sure you want to archive ${prog.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              ref
                  .read(programsNotifierProvider.notifier)
                  .archiveProgram(prog.id);
              Navigator.pop(context);
            },
            child:
                const Text('Archive', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showProgramDialog(
      BuildContext context, WidgetRef ref, ProgramModel? prog) {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: prog?.name);
    final codeCtrl = TextEditingController(text: prog?.code);
    final feesCtrl = TextEditingController(text: prog?.fees.toString() ?? '0');
    final durationCtrl =
        TextEditingController(text: prog?.durationYears.toString() ?? '4');
    String selectedDegreeType = prog?.degreeType ?? 'bachelor';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(prog == null ? l10n.newProgram : l10n.editProgram),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(labelText: l10n.programName),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'يرجى إدخال اسم التخصص'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: codeCtrl,
                      decoration: InputDecoration(labelText: l10n.programCode),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'يرجى إدخال رمز التخصص'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: feesCtrl,
                      decoration: InputDecoration(labelText: l10n.programFees),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'مطلوب';
                        if (double.tryParse(v) == null || double.parse(v) < 0) {
                          return 'قيمة غير صالحة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: durationCtrl,
                      decoration:
                          InputDecoration(labelText: l10n.programDuration),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'مطلوب';
                        if (int.tryParse(v) == null || int.parse(v) <= 0) {
                          return 'قيمة غير صالحة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: l10n.degreeType),
                      initialValue: selectedDegreeType,
                      items: [
                        DropdownMenuItem(
                            value: 'bachelor', child: Text(l10n.bachelor)),
                        DropdownMenuItem(
                            value: 'master', child: Text(l10n.master)),
                        DropdownMenuItem(
                            value: 'diploma', child: Text(l10n.diploma)),
                        DropdownMenuItem(value: 'phd', child: Text(l10n.phd)),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedDegreeType = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel)),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final data = {
                    'name': nameCtrl.text,
                    'code': codeCtrl.text,
                    'fees': double.tryParse(feesCtrl.text) ?? 0,
                    'duration_years': int.tryParse(durationCtrl.text) ?? 4,
                    'degree_type': selectedDegreeType,
                    // Simplified: default to dept id 1 for new ones unless we have a dept picker
                    if (prog == null) 'department_id': 1,
                  };
                  if (prog == null) {
                    ref
                        .read(programsNotifierProvider.notifier)
                        .createProgram(data);
                  } else {
                    ref
                        .read(programsNotifierProvider.notifier)
                        .updateProgram(prog.id, data);
                  }
                  Navigator.pop(context);
                },
                child: Text(l10n.save),
              ),
            ],
          );
        });
      },
    );
  }
}
