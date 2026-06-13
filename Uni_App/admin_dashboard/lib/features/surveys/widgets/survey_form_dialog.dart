import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/survey.dart';
import '../providers/surveys_provider.dart';
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
  late TextEditingController _urlController;
  bool _isActive = true;
  bool _isRequired = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.survey?.title ?? '');
    _urlController = TextEditingController(text: widget.survey?.googleFormUrl ?? '');
    _isActive = widget.survey?.isActive ?? true;
    _isRequired = widget.survey?.isRequiredForGrades ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text,
      'google_form_url': _urlController.text,
      'is_active': _isActive,
      'is_required_for_grades': _isRequired,
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
    return AlertDialog(
      title: Text(widget.survey == null ? l10n.addSurvey : l10n.edit),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l10n.titleLabel),
                validator: (val) => val!.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'رابط Google Form'),
                validator: (val) => val!.isEmpty || !val.startsWith('http') ? 'أدخل رابطاً صحيحاً' : null,
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
