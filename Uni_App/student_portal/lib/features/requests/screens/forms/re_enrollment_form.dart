import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';

class ReEnrollmentScreen extends StatefulWidget {
  const ReEnrollmentScreen({super.key});

  @override
  State<ReEnrollmentScreen> createState() => _ReEnrollmentScreenState();
}

class _ReEnrollmentScreenState extends State<ReEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _prevStopsCountController = TextEditingController();
  final _prevSemesterController = TextEditingController();
  final _requestTextController = TextEditingController();

  List<PlatformFile> _stopFormFiles = [];
  List<PlatformFile> _idCardFiles = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _prevStopsCountController.dispose();
    _prevSemesterController.dispose();
    _requestTextController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles(bool isIdCard) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null) {
      setState(() {
        if (isIdCard) {
          _idCardFiles = [result.files.single];
        } else {
          _stopFormFiles = [result.files.single];
        }
      });
    }
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

      File? stopFormFile;
      if (_stopFormFiles.isNotEmpty && _stopFormFiles.first.path != null) {
        stopFormFile = File(_stopFormFiles.first.path!);
      }

      File? idCardFile;
      if (_idCardFiles.isNotEmpty && _idCardFiles.first.path != null) {
        idCardFile = File(_idCardFiles.first.path!);
      }

      await repo.submitReEnrollment(
        requestTypeId: 3, // slug: re_enrollment
        prevStopsCount: _prevStopsCountController.text.trim(),
        prevSemester: _prevSemesterController.text.trim(),
        requestText: _requestTextController.text.trim(),
        stopFormFile: stopFormFile,
        idCardFile: idCardFile,
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
      appBar: AppBar(title: const Text('نموذج إعادة القيد')),
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
                const LabeledTextField(label: 'الاسم الكامل', readOnly: true, hint: 'نورة أحمد'),
                const SizedBox(height: 16),
                const LabeledTextField(
                  label: 'الرقم الجامعي',
                  readOnly: true,
                  hint: '20241010',
                ),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'الكلية', readOnly: true, hint: 'كلية الهندسةو تقنية المعلومات'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'التخصص', readOnly: true, hint: 'تقنية المعلومات'),
                const SizedBox(height: 16),
                const LabeledTextField(label: 'المستوى الدراسي', readOnly: true, hint: 'المستوى الرابع'),
                const SizedBox(height: 16),
                DropdownField(
                  label: 'عدد مرات وقف القيد السابق',
                  items: const ['0', '1', '2', '3+'],
                  onChanged: (val) =>
                      _prevStopsCountController.text = val ?? '',
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownField(
                  label: 'الفصل الدراسي السابق',
                  items: const ['الأول', 'الثاني'],
                  onChanged: (val) => _prevSemesterController.text = val ?? '',
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                const LabeledTextField(
                  label: 'العام الجامعي',
                  readOnly: true,
                  hint: '2023/2024',
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                LabeledTextField(
                  label: 'نص طلب إعادة القيد',
                  controller: _requestTextController,
                  maxLines: 4,
                  hint: 'أرجو التكرم بالموافقة على إعادة قيدي...',
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 24),
                FileUploadWidget(
                  label: 'صورة استمارة وقف القيد',
                  files: _stopFormFiles,
                  onPickFiles: () => _pickFiles(false),
                  onRemoveFile: (file) =>
                      setState(() => _stopFormFiles.clear()),
                  errorText: null,
                ),
                const SizedBox(height: 16),
                FileUploadWidget(
                  label: 'البطاقة الجامعية / الهوية',
                  files: _idCardFiles,
                  onPickFiles: () => _pickFiles(true),
                  onRemoveFile: (file) => setState(() => _idCardFiles.clear()),
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
                    'أقر بصحة البيانات المرفقة وتحملي للمسؤولية.',
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
