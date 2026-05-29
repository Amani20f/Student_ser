import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';

class ExcusedAbsenceScreen extends StatefulWidget {
  const ExcusedAbsenceScreen({super.key});

  @override
  State<ExcusedAbsenceScreen> createState() => _ExcusedAbsenceScreenState();
}

class _CourseAbsenceItem {
  TextEditingController courseName = TextEditingController();
  String? selectedDay;
  TextEditingController absenceDate = TextEditingController();
}

class _ExcusedAbsenceScreenState extends State<ExcusedAbsenceScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCollege;
  String? _selectedMajor;
  String? _selectedLevel;
  final TextEditingController _otherMajorController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  late final TextEditingController _academicYearController;

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

  final _reasonController = TextEditingController();
  final List<_CourseAbsenceItem> _courses = [];
  List<PlatformFile> _uploadedFiles = [];
  bool _isSubmitting = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _academicYearController = TextEditingController(text: '${currentYear - 1}/$currentYear');
    _addCourse();
  }

  @override
  void dispose() {
    for (var course in _courses) {
      course.courseName.dispose();
      course.absenceDate.dispose();
    }
    _otherMajorController.dispose();
    _semesterController.dispose();
    _academicYearController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _addCourse() {
    setState(() {
      _courses.add(_CourseAbsenceItem());
    });
  }

  void _removeCourse(int index) {
    if (_courses.length > 1) {
      setState(() {
        _courses[index].courseName.dispose();
        _courses[index].absenceDate.dispose();
        _courses.removeAt(index);
      });
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _uploadedFiles = result.files;
      });
    }
  }

  Future<void> _submit() async {
    if (!_isConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء الإقرار بصحة المعلومات'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<RequestsRepository>();

      // Build course list
      final coursesList = _courses.map((c) => {
        'course_name': c.courseName.text.trim(),
        'day': c.selectedDay ?? '',
        'absence_date': c.absenceDate.text.trim(),
      }).toList();

      // Convert PlatformFile to File
      final attachmentFiles = _uploadedFiles
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      await repo.submitAbsenceExcuse(
        requestTypeId: 1, // slug: absence_excuse
        college: _selectedCollege ?? '',
        major: _selectedMajor ?? _otherMajorController.text.trim(),
        level: _selectedLevel ?? '',
        semester: _semesterController.text.trim(),
        academicYear: _academicYearController.text.trim(),
        reason: _reasonController.text.trim(),
        courses: coursesList,
        attachments: attachmentFiles,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تم بنجاح'),
            content: const Text('طلبك قيد المراجعة وسوف يأتيك الرد عبر التطبيق.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('موافق'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('تبرير غياب')),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('بيانات الطالب', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'الاسم الكامل', readOnly: true, hint: 'نورة أحمد'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'الرقم الجامعي', readOnly: true, hint: '20241010'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'الكلية', readOnly: true, hint: 'كلية الهندسةو تقنية المعلومات'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'التخصص', readOnly: true, hint: 'تقنية المعلومات'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'المستوى', readOnly: true, hint: 'المستوى الرابع'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'الفصل الدراسي', readOnly: true, hint: 'الفصل الثاني'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'العام الجامعي', readOnly: true, hint: '2023/2024'),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'بيانات المقررات',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addCourse,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('إضافة مقرر', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._courses.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var course = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: LabeledTextField(
                                label: 'اسم المادة',
                                controller: course.courseName,
                                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                              ),
                            ),
                            if (_courses.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _removeCourse(idx),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownField(
                          label: 'اليوم',
                          items: const ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'],
                          value: course.selectedDay,
                          onChanged: (val) => setState(() => course.selectedDay = val),
                          validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 16),
                        DatePickerField(
                          label: 'التاريخ',
                          controller: course.absenceDate,
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Text('بيانات الغياب', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'سبب الغياب التفصيلي',
                  controller: _reasonController,
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'تاريخ تقديم الطلب',
                  readOnly: true,
                  hint: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                ),
                const SizedBox(height: 24),
                FileUploadWidget(
                  label: 'المرفقات / تقرير طبي',
                  files: _uploadedFiles,
                  onPickFiles: _pickFiles,
                  onRemoveFile: (file) => setState(() => _uploadedFiles.remove(file)),
                  allowMultiple: true,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'لسداد رسوم الطلب يرجى التوجه إلى نموذج سداد الرسوم',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  title: const Text('أقر بأن جميع المعلومات المقدمة صحيحة'),
                  value: _isConfirmed,
                  onChanged: (val) => setState(() => _isConfirmed = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('إرسال الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
