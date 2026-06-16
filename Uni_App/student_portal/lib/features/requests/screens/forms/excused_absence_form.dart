import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';
import 'package:university_app/features/auth/cubit/auth_cubit.dart';

class ExcusedAbsenceScreen extends StatefulWidget {
  const ExcusedAbsenceScreen({super.key});

  @override
  State<ExcusedAbsenceScreen> createState() => _ExcusedAbsenceScreenState();
}

class _CourseAbsenceItem {
  int? selectedCourseId;
  String? selectedCourseName;
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
  List<dynamic> _availableCourses = [];
  bool _isLoadingCourses = false;
  bool _isSubmitting = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _academicYearController = TextEditingController(text: '${currentYear - 1}/$currentYear');
    _addCourse();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });
    try {
      final courses = await context.read<RequestsRepository>().getCurrentCourses();
      setState(() {
        _availableCourses = courses;
        _isLoadingCourses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  @override
  void dispose() {
    for (var course in _courses) {
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

    if (_uploadedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إرفاق المستندات الداعمة (مرفق واحد على الأقل)'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<RequestsRepository>();

      // Build course list
      final coursesList = _courses.map((c) => {
        'course_id': c.selectedCourseId ?? 0,
        'course_name': c.selectedCourseName ?? '',
        'day': c.selectedDay ?? '',
        'absence_date': c.absenceDate.text.trim(),
      }).toList();

      // Convert PlatformFile to File
      final attachmentFiles = _uploadedFiles
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      final authState = context.read<AuthCubit>().state;
      String collegeName = _selectedCollege ?? '';
      String majorName = _selectedMajor ?? _otherMajorController.text.trim();
      String levelName = _selectedLevel ?? '';

      if (authState is Authenticated) {
        final user = authState.user;
        final student = user['student'] ?? {};
        final program = student['program'] ?? {};
        final college = program['college'] ?? {};

        collegeName = college['name'] ?? '';
        majorName = program['name'] ?? '';

        final lvl = student['current_level'];
        if (lvl != null) {
          final intLvl = int.tryParse(lvl.toString()) ?? 1;
          levelName = intLvl.toString();
        }
      }

      await repo.submitAbsenceExcuse(
        requestTypeId: 1, // slug: absence_excuse
        college: collegeName,
        major: majorName,
        level: levelName,
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
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    String name = '';
                    String studentNumber = '';
                    String collegeName = '';
                    String majorName = '';
                    String levelName = '';

                    if (state is Authenticated) {
                      final user = state.user;
                      final student = user['student'] ?? {};
                      final program = student['program'] ?? {};
                      final college = program['college'] ?? {};

                      name = user['name'] ?? '';
                      studentNumber = student['student_number']?.toString() ?? '';
                      collegeName = college['name'] ?? '';
                      majorName = program['name'] ?? '';

                      final lvl = student['current_level'];
                      if (lvl != null) {
                        final intLvl = int.tryParse(lvl.toString()) ?? 1;
                        final arabicLevels = {
                          1: 'المستوى الأول', 2: 'المستوى الثاني',
                          3: 'المستوى الثالث', 4: 'المستوى الرابع',
                          5: 'المستوى الخامس', 6: 'المستوى السادس',
                          7: 'المستوى السابع', 8: 'المستوى الثامن',
                        };
                        levelName = arabicLevels[intLvl] ?? 'المستوى $intLvl';
                      }
                    }

                    return Column(
                      children: [
                        LabeledTextField(
                          label: 'الاسم الكامل',
                          readOnly: true,
                          hint: name.isNotEmpty ? name : 'جاري التحميل...',
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'الرقم الجامعي',
                          readOnly: true,
                          hint: studentNumber.isNotEmpty ? studentNumber : 'جاري التحميل...',
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'الكلية',
                          readOnly: true,
                          hint: collegeName.isNotEmpty ? collegeName : 'جاري التحميل...',
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'التخصص',
                          readOnly: true,
                          hint: majorName.isNotEmpty ? majorName : 'جاري التحميل...',
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'المستوى الدراسي',
                          readOnly: true,
                          hint: levelName.isNotEmpty ? levelName : 'جاري التحميل...',
                        ),
                      ],
                    );
                  },
                ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'المادة',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _isLoadingCourses
                                      ? const Center(
                                          child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                      : DropdownButtonFormField<int>(
                                          value: course.selectedCourseId,
                                          items: _availableCourses.map<DropdownMenuItem<int>>((c) {
                                            final name = c['course_name'] ?? '';
                                            final code = c['course_code'] ?? '';
                                            return DropdownMenuItem<int>(
                                              value: c['id'] as int,
                                              child: Text(
                                                '$name ($code)',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              course.selectedCourseId = val;
                                              final selected = _availableCourses.firstWhere((c) => c['id'] == val);
                                              course.selectedCourseName = selected['course_name'] ?? '';
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: _availableCourses.isEmpty ? 'لا توجد مقررات متاحة' : 'اختر المقرر',
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          validator: (val) => val == null ? 'مطلوب' : null,
                                        ),
                                ],
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
                        LabeledTextField(
                          label: 'اليوم',
                          hint: course.selectedDay ?? 'اختر التاريخ أولاً',
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        DatePickerField(
                          label: 'التاريخ',
                          controller: course.absenceDate,
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          onDateSelected: (date) {
                            setState(() {
                              final arabicDays = {
                                1: 'الإثنين',
                                2: 'الثلاثاء',
                                3: 'الأربعاء',
                                4: 'الخميس',
                                5: 'الجمعة',
                                6: 'السبت',
                                7: 'الأحد',
                              };
                              course.selectedDay = arabicDays[date.weekday];
                            });
                          },
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
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
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
