import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';
import 'package:university_app/features/auth/cubit/auth_cubit.dart';

/// A single semester entry returned from GET /api/semesters
class _SuspensionSemesterOption {
  final int id;
  final String name;
  final String academicYear;
  final DateTime? examsStart;

  _SuspensionSemesterOption({
    required this.id,
    required this.name,
    required this.academicYear,
    this.examsStart,
  });

  factory _SuspensionSemesterOption.fromJson(Map<String, dynamic> json) {
    return _SuspensionSemesterOption(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      academicYear: json['year'] as String? ?? '',
      examsStart: json['exams_start_date'] != null
          ? DateTime.tryParse(json['exams_start_date'] as String)
          : null,
    );
  }

  /// Returns null if submission is allowed, or an Arabic error message.
  String? checkDeadline() {
    if (examsStart == null) return null;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final deadline = examsStart!.subtract(const Duration(days: 14));
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);

    if (todayDate.isAfter(deadlineDate)) {
      final fmt =
          '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}';
      return 'انتهت فترة تقديم طلب إيقاف القيد. كان آخر موعد للتقديم $fmt (14 يوماً قبل بدء الاختبارات).';
    }
    return null;
  }
}

class StopEnrollmentScreen extends StatefulWidget {
  const StopEnrollmentScreen({super.key});

  @override
  State<StopEnrollmentScreen> createState() => _StopEnrollmentScreenState();
}

class _StopEnrollmentScreenState extends State<StopEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _reasonController = TextEditingController();

  // ── Semester selection ──────────────────────────────────────────────────────
  List<_SuspensionSemesterOption> _semesters = [];
  _SuspensionSemesterOption? _selectedSemester;
  bool _loadingSemesters = true;
  String? _semesterLoadError;

  List<PlatformFile> _uploadedFiles = [];
  bool _isSubmitting = false;

  String? _selectedCollege;
  String? _selectedMajor;
  String? _selectedLevel;
  double? _requestPrice;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      final student = user['student'] ?? {};
      final program = student['program'] ?? {};
      final college = program['college'] ?? {};

      _selectedCollege = college['name'];
      _selectedMajor = program['name'];

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
        _selectedLevel = arabicLevels[intLvl] ?? 'المستوى $intLvl';
      }
    }
    _fetchSemesters();
  }

  Future<void> _fetchSemesters() async {
    try {
      final repo = context.read<RequestsRepository>();
      final data = await repo.getSemesters();

      double? price;
      try {
        final types = await repo.getActiveRequestTypes();
        final currentType = types.firstWhere(
          (t) => t['slug'] == 'suspension_of_enrollment',
          orElse: () => null,
        );
        if (currentType != null) {
          price = double.tryParse(currentType['price']?.toString() ?? '10');
        }
      } catch (_) {
        price = 10.0;
      }

      if (!mounted) return;
      setState(() {
        _semesters = data
            .map(
              (e) => _SuspensionSemesterOption.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
        _requestPrice = price ?? 10.0;
        _loadingSemesters = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _semesterLoadError = 'تعذّر تحميل الفصول الدراسية';
        _loadingSemesters = false;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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

  void _removeFile(PlatformFile file) {
    setState(() {
      _uploadedFiles.removeWhere((element) => element == file);
    });
  }

  Future<void> _submit() async {
    // ── 1. Semester must be selected ──────────────────────────────────────────
    if (_selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار الفصل الدراسي المراد إيقاف القيد منه'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ── 2. Exam deadline check (14 days before exams) ────────────────────────
    final deadlineError = _selectedSemester!.checkDeadline();
    if (deadlineError != null) {
      _showDeadlineError(deadlineError);
      return;
    }

    // ── 3. Form validation ────────────────────────────────────────────────────
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = context.read<RequestsRepository>();

      final attachmentFiles = _uploadedFiles
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      await repo.submitStopEnrollment(
        requestTypeId: 2, // slug: suspension_of_enrollment
        semesterId: _selectedSemester!.id,
        reason: _reasonController.text.trim(),
        attachments: attachmentFiles,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تم بنجاح'),
            content: const Text(
              'طلبك قيد المراجعة وسوف يأتيك الرد عبر التطبيق.',
            ),
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

  void _showDeadlineError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.red),
            SizedBox(width: 8),
            Text('لا يمكن تقديم الطلب'),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    String name = '';
    String studentNumber = '';

    if (authState is Authenticated) {
      final user = authState.user;
      name = user['name'] ?? '';
      final student = user['student'] ?? {};
      studentNumber = student['student_number'] ?? '';
    }

    Widget buildSemesterPicker() {
      if (_loadingSemesters) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (_semesterLoadError != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _semesterLoadError!,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        );
      }
      if (_semesters.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('لا توجد فصول دراسية متاحة'),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<_SuspensionSemesterOption>(
            decoration: InputDecoration(
              labelText: 'الفصل الدراسي المراد إيقاف القيد منه',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            initialValue: _selectedSemester,
            items: _semesters
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (val) => setState(() => _selectedSemester = val),
            validator: (val) => val == null ? 'مطلوب' : null,
          ),
          // ── Deadline banner ─────────────────────────────────────────────────
          if (_selectedSemester != null) ...[
            const SizedBox(height: 8),
            _DeadlineBanner(semester: _selectedSemester!),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('نموذج إيقاف القيد')),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بيانات الطالب',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'الاسم الكامل',
                  readOnly: true,
                  hint: name,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'الرقم الجامعي',
                  readOnly: true,
                  hint: studentNumber,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  'بيانات الطلب',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'الكلية',
                  readOnly: true,
                  hint: _selectedCollege ?? 'كلية الهندسةو تقنية المعلومات',
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'التخصص',
                  readOnly: true,
                  hint: _selectedMajor ?? 'تقنية المعلومات',
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'المستوى الدراسي',
                  readOnly: true,
                  hint: _selectedLevel ?? 'المستوى الرابع',
                ),
                const SizedBox(height: 16),
                // ── Semester picker ─────────────────────────────────────────
                buildSemesterPicker(),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'سبب إيقاف القيد',
                  controller: _reasonController,
                  maxLines: 4,
                  hint: 'اشرح الأسباب الخاصة لطلب الإيقاف...',
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'مطلوب';
                    if (val.trim().length < 10)
                      return 'يجب أن يكون سبب إيقاف القيد 10 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FileUploadWidget(
                  label: 'المرفقات / الوثائق الداعمة',
                  files: _uploadedFiles,
                  onPickFiles: _pickFiles,
                  onRemoveFile: _removeFile,
                  allowMultiple: true,
                  errorText: null,
                ),
                const SizedBox(height: 24),
                if (_requestPrice != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payment,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'رسوم طلب إيقاف القيد: ${_requestPrice!.toStringAsFixed(0)} دولار',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'أقر بأن جميع البيانات المدخلة صحيحة وأتحمل المسؤولية القانونية.',
                    style: GoogleFonts.almarai(fontSize: 13),
                  ),
                  value: true,
                  onChanged: (val) {},
                  activeColor: Theme.of(context).colorScheme.primary,
                  controlAffinity: ListTileControlAffinity.leading,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'إرسال الطلب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

// ── Exam Deadline Status Banner ────────────────────────────────────────────────
class _DeadlineBanner extends StatelessWidget {
  final _SuspensionSemesterOption semester;

  const _DeadlineBanner({required this.semester});

  @override
  Widget build(BuildContext context) {
    if (semester.examsStart == null) return const SizedBox.shrink();

    final error = semester.checkDeadline();
    final isAllowed = error == null;

    final deadline = semester.examsStart!.subtract(const Duration(days: 14));
    final deadlineFmt =
        '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isAllowed
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAllowed ? Colors.green : Colors.red,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAllowed ? Icons.check_circle_outline : Icons.warning_amber,
            color: isAllowed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAllowed
                  ? 'يمكنك التقديم حتى $deadlineFmt (14 يوماً قبل بدء الاختبارات)'
                  : error,
              style: TextStyle(
                fontSize: 13,
                color: isAllowed ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
