import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';
import 'package:university_app/features/requests/screens/forms/payment_form.dart';
import 'package:university_app/features/auth/cubit/auth_cubit.dart';

class _GrievanceCourseItem {
  int? selectedCourseId;
  String? selectedCourseName;
}

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

  final List<_GrievanceCourseItem> _courses = [_GrievanceCourseItem()];
  List<dynamic> _availableCourses = [];
  bool _isLoadingCourses = false;
  final _reasonController = TextEditingController();

  bool isEditableFields = false;
  bool _isSubmitting = false;

  final List<PlatformFile> _uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _academicYearController = TextEditingController(
      text: '${currentYear - 1}/$currentYear',
    );
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoadingCourses = true;
    });
    try {
      final courses = await context
          .read<RequestsRepository>()
          .getCurrentCourses();
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
    _otherMajorController.dispose();
    _academicYearController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _addCourse() {
    if (_courses.length < 4) {
      setState(() {
        _courses.add(_GrievanceCourseItem());
      });
    }
  }

  void _removeCourse(int index) {
    if (_courses.length > 1) {
      setState(() {
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
        _uploadedFiles.addAll(result.files);
      });
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _uploadedFiles.removeWhere((element) => element == file);
    });
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

    if (_uploadedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إرفاق المستندات الداعمة (مرفق واحد على الأقل)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<RequestsRepository>();

      final coursesList = _courses
          .where((c) => c.selectedCourseId != null)
          .map(
            (c) => {
              'course_id': c.selectedCourseId,
              'course_name': c.selectedCourseName,
            },
          )
          .toList();

      final authState = context.read<AuthCubit>().state;
      String collegeName = _selectedCollege ?? '';
      String majorName = _selectedMajor ?? _otherMajorController.text.trim();
      String levelName = _selectedLevel ?? '';

      if (authState is Authenticated && !isEditableFields) {
        final user = authState.user;
        final student = user['student'] ?? {};
        final program = student['program'] ?? {};
        final college = program['college'] ?? {};

        collegeName = college['name'] ?? '';
        majorName = program['name'] ?? '';

        final lvl = student['current_level'];
        if (lvl != null) {
          final intLvl = int.tryParse(lvl.toString()) ?? 1;
          final arabicLevels = {
            1: 'المستوى الأول',
            2: 'المستوى الثاني',
            3: 'المستوى الثالث',
            4: 'المستوى الرابع',
            5: 'المستوى الخامس',
            6: 'المستوى السادس',
            7: 'المستوى السابع',
            8: 'المستوى الثامن',
          };
          levelName = arabicLevels[intLvl] ?? 'المستوى $intLvl';
        }
      }

      final attachmentFiles = _uploadedFiles
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      final response = await repo.submitGrievance(
        requestTypeId: 4, // slug: grade_grievance
        college: collegeName,
        major: majorName,
        level: levelName,
        academicYear: _academicYearController.text.trim(),
        semester: _selectedSemester ?? 'الفصل الثاني',
        courses: coursesList,
        reason: _reasonController.text.trim(),
        attachments: attachmentFiles,
      );

      final requestId = response['data']?['id']?.toString() ?? '';
      final refNumber = requestId.isNotEmpty ? 'REF-$requestId' : '';

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('تم بنجاح'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تم استلام طلبك بنجاح وهو قيد المراجعة.'),
                const SizedBox(height: 8),
                if (refNumber.isNotEmpty)
                  Text(
                    'رقمك المرجعي: $refNumber',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close form screen
                },
                child: const Text('إغلاق'),
              ),
              if (refNumber.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentFormScreen(
                          initialRefNumber: refNumber,
                          initialServiceType: 'تظلم — 10 دولار',
                        ),
                      ),
                    );
                  },
                  child: const Text('سداد الرسوم الآن'),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإرسال: $e'),
            backgroundColor: Colors.red,
          ),
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
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
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
                            studentNumber =
                                student['student_number']?.toString() ?? '';
                            collegeName = college['name'] ?? '';
                            majorName = program['name'] ?? '';

                            final lvl = student['current_level'];
                            if (lvl != null) {
                              final intLvl = int.tryParse(lvl.toString()) ?? 1;
                              final arabicLevels = {
                                1: 'المستوى الأول',
                                2: 'المستوى الثاني',
                                3: 'المستوى الثالث',
                                4: 'المستوى الرابع',
                                5: 'المستوى الخامس',
                                6: 'المستوى السادس',
                                7: 'المستوى السابع',
                                8: 'المستوى الثامن',
                              };
                              levelName =
                                  arabicLevels[intLvl] ?? 'المستوى $intLvl';
                            }
                          }

                          return Column(
                            children: [
                              LabeledTextField(
                                label: l10n.fullName,
                                readOnly: true,
                                hint: name.isNotEmpty ? name : l10n.studentName,
                              ),
                              const SizedBox(height: 16),
                              LabeledTextField(
                                label: l10n.studentIdLabel,
                                readOnly: true,
                                hint: studentNumber.isNotEmpty
                                    ? studentNumber
                                    : 'جاري التحميل...',
                              ),
                              const SizedBox(height: 16),
                              if (!isEditableFields) ...[
                                LabeledTextField(
                                  label: l10n.college,
                                  readOnly: true,
                                  hint: collegeName.isNotEmpty
                                      ? collegeName
                                      : 'جاري التحميل...',
                                ),
                                const SizedBox(height: 16),
                                LabeledTextField(
                                  label: l10n.major,
                                  readOnly: true,
                                  hint: majorName.isNotEmpty
                                      ? majorName
                                      : 'جاري التحميل...',
                                ),
                                const SizedBox(height: 16),
                                LabeledTextField(
                                  label: l10n.level,
                                  readOnly: true,
                                  hint: levelName.isNotEmpty
                                      ? levelName
                                      : 'جاري التحميل...',
                                ),
                                const SizedBox(height: 16),
                                LabeledTextField(
                                  label: l10n.academicYear,
                                  readOnly: true,
                                  hint: _academicYearController.text,
                                ),
                                const SizedBox(height: 16),
                                LabeledTextField(
                                  label: l10n.semester,
                                  readOnly: true,
                                  hint: 'الفصل الثاني',
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      if (isEditableFields) ...[
                        DropdownField(
                          label: l10n.college,
                          items: _collegeMajors.keys.toList(),
                          value: _selectedCollege,
                          onChanged: (val) => setState(() {
                            _selectedCollege = val;
                            _selectedMajor = null;
                            _otherMajorController.clear();
                          }),
                          validator: (val) => val == null || val.isEmpty
                              ? l10n.pleaseFillRequiredFields
                              : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownField(
                          label: l10n.major,
                          items: _selectedCollege != null
                              ? _collegeMajors[_selectedCollege] ?? []
                              : [],
                          value: _selectedMajor,
                          onChanged: _selectedCollege == null
                              ? null
                              : (val) => setState(() => _selectedMajor = val),
                          validator: (val) => val == null || val.isEmpty
                              ? l10n.pleaseFillRequiredFields
                              : null,
                        ),
                        if (_selectedMajor == 'أخرى') ...[
                          const SizedBox(height: 16),
                          LabeledTextField(
                            label: 'اكتب تخصصك',
                            controller: _otherMajorController,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? l10n.pleaseFillRequiredFields
                                : null,
                          ),
                        ],
                        const SizedBox(height: 16),
                        DropdownField(
                          label: l10n.level,
                          items: const [
                            'المستوى الأول',
                            'المستوى الثاني',
                            'المستوى الثالث',
                            'المستوى الرابع',
                            'المستوى الخامس',
                            'المستوى السادس',
                            'المستوى السابع',
                          ],
                          value: _selectedLevel,
                          onChanged: (val) =>
                              setState(() => _selectedLevel = val),
                          validator: (val) => val == null || val.isEmpty
                              ? l10n.pleaseFillRequiredFields
                              : null,
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: l10n.academicYear,
                          controller: _academicYearController,
                          validator: (val) => val == null || val.isEmpty
                              ? l10n.pleaseFillRequiredFields
                              : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownField(
                          label: l10n.semester,
                          items: const ['الفصل الأول', 'الفصل الثاني'],
                          value: _selectedSemester,
                          onChanged: (val) =>
                              setState(() => _selectedSemester = val),
                          validator: (val) => val == null || val.isEmpty
                              ? l10n.pleaseFillRequiredFields
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
                buildSectionCard(
                  title:
                      '${l10n.grievanceDetails} - ${l10n.grievanceResultsRequest}',
                  child: Column(
                    children: [
                      ...List.generate(_courses.length, (index) {
                        final course = _courses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${l10n.courseName} ${index + 1}',
                                      style: const TextStyle(
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
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : DropdownButtonFormField<int>(
                                            initialValue:
                                                course.selectedCourseId,
                                            items: _availableCourses
                                                .map<DropdownMenuItem<int>>((
                                                  c,
                                                ) {
                                                  final name =
                                                      c['course_name'] ?? '';
                                                  final code =
                                                      c['course_code'] ?? '';
                                                  return DropdownMenuItem<int>(
                                                    value: c['id'] as int,
                                                    child: Text(
                                                      '$name ($code)',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  );
                                                })
                                                .toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                course.selectedCourseId = val;
                                                final selected =
                                                    _availableCourses
                                                        .firstWhere(
                                                          (c) => c['id'] == val,
                                                        );
                                                course.selectedCourseName =
                                                    selected['course_name'] ??
                                                    '';
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText:
                                                  _availableCourses.isEmpty
                                                  ? 'لا توجد مقررات متاحة'
                                                  : 'اختر المقرر',
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            validator: (val) => val == null
                                                ? l10n.pleaseFillRequiredFields
                                                : null,
                                          ),
                                  ],
                                ),
                              ),
                              if (_courses.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  tooltip: l10n.remove,
                                  onPressed: () => _removeCourse(index),
                                ),
                            ],
                          ),
                        );
                      }),
                      if (_courses.length < 4)
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
                        validator: (val) => val == null || val.trim().isEmpty
                            ? l10n.pleaseFillRequiredFields
                            : null,
                      ),
                    ],
                  ),
                ),
                FileUploadWidget(
                  label: 'المستندات الداعمة للتظلم',
                  files: _uploadedFiles,
                  onPickFiles: _pickFiles,
                  onRemoveFile: _removeFile,
                  errorText: null,
                ),
                const SizedBox(height: 16),
                Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'لسداد رسوم الطلب يرجى التوجه إلى نموذج سداد الرسوم',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, duration: 400.ms),
                buildSectionCard(
                  title: l10n.payment,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payment, color: theme.colorScheme.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.grievanceFee,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10n.submitGrievance,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
