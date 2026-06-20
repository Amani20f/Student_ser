import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/survey.dart';
import '../providers/surveys_provider.dart';
import '../../programs/providers/programs_provider.dart';
import '../../courses/providers/colleges_provider.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

class SurveyFormDialog extends ConsumerStatefulWidget {
  final Survey? survey;

  const SurveyFormDialog({super.key, this.survey});

  @override
  ConsumerState<SurveyFormDialog> createState() => _SurveyFormDialogState();
}

class _SurveyFormDialogState extends ConsumerState<SurveyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  bool _isActive = true;
  bool _isRequired = false;
  bool _isLoading = false;
  int? _targetCollegeId;
  int? _targetProgramId;
  int? _targetLevel;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.survey?.title ?? '');
    _descriptionController = TextEditingController(text: widget.survey?.description ?? '');
    _urlController = TextEditingController(text: widget.survey?.googleFormUrl ?? '');
    _isActive = widget.survey?.isActive ?? true;
    _targetCollegeId = widget.survey?.targetCollegeId;
    _targetProgramId = widget.survey?.targetProgramId;
    _targetLevel = widget.survey?.targetLevel;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      'google_form_url': _urlController.text,
      'is_active': _isActive,
      'is_required_for_grades': _isRequired,
      'target_college_id': _targetCollegeId,
      'target_program_id': _targetProgramId,
      'target_level': _targetLevel,
    };

    try {
      if (widget.survey == null) {
        await ref.read(surveysProvider.notifier).createSurvey(data);
      } else {
        await ref.read(surveysProvider.notifier).updateSurvey(widget.survey!.id, data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final programsState = ref.watch(publicProgramsProvider);
    final programs = programsState.value ?? [];

    final collegesState = ref.watch(collegesProvider);
    final colleges = collegesState.value ?? [];

    final filteredPrograms = _targetCollegeId == null
        ? programs
        : programs.where((p) => p.collegeId == _targetCollegeId).toList();

    int maxLevels = 10;
    if (programs.isNotEmpty) {
      if (_targetProgramId != null) {
        final selectedProgram = programs.firstWhere((p) => p.id == _targetProgramId, orElse: () => programs.first);
        maxLevels = selectedProgram.durationYears * 2;
      } else if (_targetCollegeId != null && filteredPrograms.isNotEmpty) {
        final maxDuration = filteredPrograms.map((p) => p.durationYears).reduce((a, b) => a > b ? a : b);
        maxLevels = maxDuration * 2;
      } else {
        final maxDuration = programs.map((p) => p.durationYears).reduce((a, b) => a > b ? a : b);
        maxLevels = maxDuration * 2;
      }
    }

    final uniqueColleges = {for (var c in colleges) c.id: c}.values.toList();
    final uniquePrograms = {for (var p in filteredPrograms) p.id: p}.values.toList();

    // Ensure _targetCollegeId is valid
    if (_targetCollegeId != null && !uniqueColleges.any((c) => c.id == _targetCollegeId)) {
      _targetCollegeId = null;
    }

    // Ensure _targetProgramId is valid
    if (_targetProgramId != null && !uniquePrograms.any((p) => p.id == _targetProgramId)) {
      _targetProgramId = null;
    }

    // Ensure _targetLevel is valid to avoid Dropdown assertion errors.
    if (_targetLevel != null && _targetLevel! > maxLevels) {
      _targetLevel = null;
    }

    return AlertDialog(
      title: Text(widget.survey == null ? l10n.addSurvey : l10n.edit),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l10n.titleLabel, border: const OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? l10n.requiredField : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'وصف الاستبيان (اختياري)', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'رابط Google Form', border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty || !val.startsWith('http') ? 'أدخل رابطاً صحيحاً' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _targetCollegeId,
                  decoration: const InputDecoration(labelText: 'الكلية المستهدفة (اختياري)', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('الكل (غير محدد)')),
                    ...uniqueColleges.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _targetCollegeId = val;
                      _targetProgramId = null; // تصفير التخصص عند تغيير الكلية
                      _targetLevel = null; // تصفير المستوى عند تغيير الكلية
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  key: ValueKey('program_$_targetCollegeId'),
                  initialValue: _targetProgramId,
                  decoration: const InputDecoration(labelText: 'التخصص المستهدف (اختياري)', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('الكل (غير محدد)')),
                    ...uniquePrograms.map((p) => DropdownMenuItem<int?>(value: p.id, child: Text(p.name))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _targetProgramId = val;
                      _targetLevel = null; // تصفير المستوى عند تغيير التخصص
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  key: ValueKey('level_$maxLevels'),
                  initialValue: (_targetLevel != null && _targetLevel! <= maxLevels) ? _targetLevel : null,
                  decoration: const InputDecoration(labelText: 'المستوى المستهدف (اختياري)', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('الكل (غير محدد)')),
                    ...List.generate(maxLevels, (i) => i + 1).map((level) => DropdownMenuItem<int?>(value: level, child: Text('المستوى $level'))),
                  ],
                  onChanged: (val) => setState(() => _targetLevel = val),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('مفعل الآن؟'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
                SwitchListTile(
                  title: const Text('مطلوب لمشاهدة الدرجات؟'),
                  subtitle: const Text('سيحجب الدرجات عن الطالب حتى يكمله'),
                  value: _isRequired,
                  onChanged: (val) => setState(() => _isRequired = val),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.save),
        ),
      ],
    );
  }
}
