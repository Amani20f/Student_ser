import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/semesters_provider.dart';
import '../data/semester_model.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';

class SemesterDialog extends ConsumerStatefulWidget {
  final SemesterModel? semester;

  const SemesterDialog({super.key, this.semester});

  @override
  ConsumerState<SemesterDialog> createState() => _SemesterDialogState();
}

class _SemesterDialogState extends ConsumerState<SemesterDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _startYearCtrl;
  late TextEditingController _endYearCtrl;
  String _term = 'first';
  bool _isActive = false;
  
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _examsDate;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final s = widget.semester;
    
    String sYear = DateTime.now().year.toString();
    String eYear = (DateTime.now().year + 1).toString();

    if (s != null && s.academicYear.contains('/')) {
      final parts = s.academicYear.split('/');
      if (parts.length == 2) {
        sYear = parts[0];
        eYear = parts[1];
      }
    }

    _startYearCtrl = TextEditingController(text: sYear);
    _endYearCtrl = TextEditingController(text: eYear);
    
    if (s != null) {
      _term = s.term;
      _isActive = s.isActive;
      _startDate = DateTime.tryParse(s.startDate);
      _endDate = DateTime.tryParse(s.endDate);
      _examsDate = DateTime.tryParse(s.examsStartDate);
    }
  }

  @override
  void dispose() {
    _startYearCtrl.dispose();
    _endYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, DateTime? initialDate, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null || _examsDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requireAllDates)),
      );
      return;
    }

    final data = {
      'start_year': _startYearCtrl.text,
      'end_year': _endYearCtrl.text,
      'term': _term,
      'is_active': _isActive,
      'start_date': _dateFormat.format(_startDate!),
      'end_date': _dateFormat.format(_endDate!),
      'exams_start_date': _dateFormat.format(_examsDate!),
    };

    final notifier = ref.read(semesterNotifierProvider.notifier);
    bool success;

    if (widget.semester == null) {
      success = await notifier.createSemester(data);
    } else {
      success = await notifier.updateSemester(widget.semester!.id, data);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.semester == null ? l10n.addSuccess : l10n.editSuccess)),
      );
    } else if (mounted) {
      final err = ref.read(semesterNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err?.toString() ?? l10n.error('')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.semester != null;
    final isLoading = ref.watch(semesterNotifierProvider).isLoading;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(isEditing ? Icons.edit : Icons.add_circle, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? l10n.editSemester : l10n.addNewSemester,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startYearCtrl,
                      decoration: InputDecoration(labelText: l10n.startYear, border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? l10n.requiredField : null,
                      onChanged: (v) {
                        if (v.length == 4) {
                          final start = int.tryParse(v);
                          if (start != null) {
                            _endYearCtrl.text = (start + 1).toString();
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endYearCtrl,
                      decoration: InputDecoration(labelText: l10n.endYear, border: const OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? l10n.requiredField : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _term,
                decoration: InputDecoration(labelText: l10n.semester, border: const OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 'first', child: Text(l10n.firstTerm)),
                  DropdownMenuItem(value: 'second', child: Text(l10n.secondTerm)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _term = v);
                },
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: Text(l10n.setAsActiveSemester),
                subtitle: Text(l10n.activateSemesterWarning),
                value: _isActive,
                activeThumbColor: cs.primary,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _DateSelector(
                      label: l10n.startDate,
                      date: _startDate,
                      onTap: () => _pickDate(context, _startDate, (d) => setState(() => _startDate = d)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DateSelector(
                      label: l10n.endDate,
                      date: _endDate,
                      onTap: () => _pickDate(context, _endDate, (d) => setState(() => _endDate = d)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _DateSelector(
                label: l10n.examsStartDate,
                date: _examsDate,
                onTap: () => _pickDate(context, _examsDate, (d) => setState(() => _examsDate = d)),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: isLoading ? null : _save,
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? l10n.saveChanges : l10n.addSemester),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateSelector({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  date == null ? AppLocalizations.of(context)!.selectDate : DateFormat('yyyy-MM-dd').format(date!),
                  style: TextStyle(color: date == null ? cs.onSurfaceVariant : cs.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
