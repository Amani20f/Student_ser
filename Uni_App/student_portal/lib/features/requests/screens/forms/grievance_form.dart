import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';

class GrievanceFormScreen extends StatefulWidget {
  const GrievanceFormScreen({super.key});

  @override
  State<GrievanceFormScreen> createState() => _GrievanceFormScreenState();
}

class _GrievanceFormScreenState extends State<GrievanceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _academicYearController;
  final TextEditingController _otherMajorController = TextEditingController();

  String? _selectedCollege;
  String? _selectedMajor;
  String? _selectedLevel;
  String? _selectedSemester;

  static const Map<String, List<String>> _collegeMajors = {
    'كلية الهندسةو تقنية المعلومات': [
      'تقنية المعلومات',
      'تصميم داخلي',
      'تعدين',
      ' هندسة معمارية',
      'هندسة مدنية',
      'الذكاء الاصطناعي',
    ],
    'كلية الطب والعلوم الصحية': [
      'طب بشري',
      'مختبرات',
      'سمع ونطق',
      'علاج طبيعي',
      'صيدلة',
    ],
    'كلية العلوم الادارية ': ['إدارة أعمال', 'محاسبة'],
    'كلية طب الاسنان ': ['طب الاسنان'],
  };

  final List<TextEditingController> _courseControllers = [TextEditingController()];
  final _reasonController = TextEditingController();

  bool isEditableFields = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _academicYearController = TextEditingController(text: '${currentYear - 1}/$currentYear');
  }

  @override
  void dispose() {
    _otherMajorController.dispose();
    _academicYearController.dispose();
    _reasonController.dispose();
    for (var c in _courseControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCourse() {
    if (_courseControllers.length < 4) {
      setState(() {
        _courseControllers.add(TextEditingController());
      });
    }
  }

  void _removeCourse(int index) {
    if (_courseControllers.length > 1) {
      setState(() {
        _courseControllers[index].dispose();
        _courseControllers.removeAt(index);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseFillRequiredFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<RequestsRepository>();

      final courseNames = _courseControllers
          .map((c) => c.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      await repo.submitGrievance(
        requestTypeId: 4, // slug: grade_grievance
        college: _selectedCollege ?? 'كلية الهندسةو تقنية المعلومات',
        major: _selectedMajor ?? _otherMajorController.text.trim(),
        level: _selectedLevel ?? 'المستوى الرابع',
        academicYear: _academicYearController.text.trim(),
        semester: _selectedSemester ?? 'الفصل الثاني',
        courseNames: courseNames,
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.success),
            content: const Text('تم إرسال التظلم بنجاح وسوف يأتيك الرد عبر التطبيق.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الإرسال: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Widget buildSectionCard({required String title, required Widget child}) {
      return Card(
        margin: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.grievanceFormTitle)),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionCard(
                  title: l10n.studentInfo,
                  child: Column(
                    children: [
                      LabeledTextField(label: l10n.fullName, readOnly: true, hint: l10n.studentName),
                      const SizedBox(height: 16),
                      LabeledTextField(label: l10n.studentIdLabel, readOnly: true, hint: '20241010'),
                      const SizedBox(height: 16),
                      if (!isEditableFields) ...[
                        LabeledTextField(label: l10n.college, readOnly: true, hint: 'كلية الهندسةو تقنية المعلومات'),
                        const SizedBox(height: 16),
                        LabeledTextField(label: l10n.major, readOnly: true, hint: 'تقنية المعلومات'),
                        const SizedBox(height: 16),
                        LabeledTextField(label: l10n.level, readOnly: true, hint: 'المستوى الرابع'),
                        const SizedBox(height: 16),
                        LabeledTextField(label: l10n.academicYear, readOnly: true, hint: _academicYearController.text),
                        const SizedBox(height: 16),
                        LabeledTextField(label: l10n.semester, readOnly: true, hint: 'الفصل الثاني'),
                      ] else ...[
                        DropdownField(
                          label: l10n.college,
                          items: _collegeMajors.keys.toList(),
                          value: _selectedCollege,
                          onChanged: (val) => setState(() {
                            _selectedCollege = val;
                            _selectedMajor = null;
                            _otherMajorController.clear();
                          }),
                          validator: (val) => val == null || val.isEmpty ? l10n.pleaseFillRequiredFields : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownField(
                          label: l10n.major,
                          items: _selectedCollege != null ? _collegeMajors[_selectedCollege] ?? [] : [],
                          value: _selectedMajor,
                          onChanged: _selectedCollege == null ? null : (val) => setState(() => _selectedMajor = val),
                          validator: (val) => val == null || val.isEmpty ? l10n.pleaseFillRequiredFields : null,
                        ),
                        if (_selectedMajor == 'أخرى') ...[
                          const SizedBox(height: 16),
                          LabeledTextField(
                            label: 'اكتب تخصصك',
                            controller: _otherMajorController,
                            validator: (val) => val == null || val.trim().isEmpty ? l10n.pleaseFillRequiredFields : null,
                          ),
                        ],
                        const SizedBox(height: 16),
                        DropdownField(
                          label: l10n.level,
                          items: const ['المستوى الأول', 'المستوى الثاني', 'المستوى الثالث', 'المستوى الرابع', 'المستوى الخامس', 'المستوى السادس', 'المستوى السابع'],
                          value: _selectedLevel,
                          onChanged: (val) => setState(() => _selectedLevel = val),
                          validator: (val) => val == null || val.isEmpty ? l10n.pleaseFillRequiredFields : null,
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: l10n.academicYear,
                          controller: _academicYearController,
                          validator: (val) => val == null || val.isEmpty ? l10n.pleaseFillRequiredFields : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownField(
                          label: l10n.semester,
                          items: const ['الفصل الأول', 'الفصل الثاني'],
                          value: _selectedSemester,
                          onChanged: (val) => setState(() => _selectedSemester = val),
                          validator: (val) => val == null || val.isEmpty ? l10n.pleaseFillRequiredFields : null,
                        ),
                      ],
                    ],
                  ),
                ),
                buildSectionCard(
                  title: '${l10n.grievanceDetails} - ${l10n.grievanceResultsRequest}',
                  child: Column(
                    children: [
                      ...List.generate(_courseControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: LabeledTextField(
                                  label: '${l10n.courseName} ${index + 1}',
                                  controller: _courseControllers[index],
                                  validator: (val) => val == null || val.isEmpty ? l10n.pleaseFillRequiredFields : null,
                                ),
                              ),
                              if (_courseControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  tooltip: l10n.remove,
                                  onPressed: () => _removeCourse(index),
                                ),
                            ],
                          ),
                        );
                      }),
                      if (_courseControllers.length < 4)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: _addCourse,
                            icon: const Icon(Icons.add_circle, size: 20),
                            label: Text(l10n.addCourse),
                          ),
                        ),
                      const SizedBox(height: 16),
                      LabeledTextField(
                        label: 'سبب التظلم',
                        controller: _reasonController,
                        maxLines: 4,
                        validator: (val) => val == null || val.isEmpty ? l10n.pleaseFillRequiredFields : null,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'لسداد رسوم الطلب يرجى التوجه إلى نموذج سداد الرسوم',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                buildSectionCard(
                  title: l10n.payment,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payment, color: theme.colorScheme.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.grievanceFee,
                            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.submitGrievance),
                  ),
                ).animate().scale(delay: 500.ms, duration: 300.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
