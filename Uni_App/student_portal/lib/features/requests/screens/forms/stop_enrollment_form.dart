import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';

class StopEnrollmentScreen extends StatefulWidget {
  const StopEnrollmentScreen({super.key});

  @override
  State<StopEnrollmentScreen> createState() => _StopEnrollmentScreenState();
}

class _StopEnrollmentScreenState extends State<StopEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCollege;
  String? _selectedMajor;
  String? _selectedLevel;
  final TextEditingController _otherMajorController = TextEditingController();

  String? _selectedAcademicYear;
  String? _selectedYearStart;
  String? _selectedYearEnd;

  late final List<String> _academicYears;

  final _semesterStopController = TextEditingController();
  final _semesterToController = TextEditingController();
  final _reasonController = TextEditingController();

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

  List<PlatformFile> _uploadedFiles = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _academicYears = [
      '${currentYear - 1}/$currentYear',
      '$currentYear/${currentYear + 1}',
    ];
  }

  @override
  void dispose() {
    _otherMajorController.dispose();
    _semesterStopController.dispose();
    _semesterToController.dispose();
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
        yearStart: _selectedYearStart ?? '',
        semesterTo: _semesterToController.text.trim(),
        yearEnd: _selectedYearEnd ?? '',
        reason: _reasonController.text.trim(),
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
      appBar: AppBar(title: const Text('نموذج إيقاف القيد')),
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
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Text('بيانات الطلب', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'الكلية', readOnly: true, hint: 'كلية الهندسةو تقنية المعلومات'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'التخصص', readOnly: true, hint: 'تقنية المعلومات'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'المستوى الدراسي', readOnly: true, hint: 'المستوى الرابع'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'العام الجامعي', readOnly: true, hint: '2023/2024'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'الفصل الدراسي المراد إيقاف القيد منه', readOnly: true, hint: 'الفصل الثاني'),
                const SizedBox(height: 16),
                const Text('فترة الإيقاف', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownField(
                  label: 'من العام الجامعي',
                  items: _academicYears,
                  value: _selectedYearStart,
                  onChanged: (val) => setState(() => _selectedYearStart = val),
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownField(
                  label: 'إلى الفصل الدراسي',
                  items: const ['الفصل الأول', 'الفصل الثاني'],
                  onChanged: (val) => _semesterToController.text = val ?? '',
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownField(
                  label: 'نهاية العام الجامعي',
                  items: _academicYears,
                  value: _selectedYearEnd,
                  onChanged: (val) => setState(() => _selectedYearEnd = val),
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'سبب إيقاف القيد',
                  controller: _reasonController,
                  maxLines: 4,
                  hint: 'اشرح الأسباب الخاصة لطلب الإيقاف...',
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
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
