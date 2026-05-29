import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:university_app/features/requests/models/request_model.dart';
import 'package:university_app/features/requests/screens/form_preview_screen.dart';
import 'package:university_app/core/theme/app_theme.dart';

class RequestDetailScreen extends StatefulWidget {
  final RequestType request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  String? uploadedFileName;
  bool isSubmitting = false;

  Future<void> _uploadForm() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        uploadedFileName = result.files.single.name;
      });
    }
  }

  void _submitRequest() {
    if (uploadedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إرفاق الملف المكتمل قبل الإرسال'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => isSubmitting = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم بنجاح'),
          content: const Text(
            'تم استلام طلبك بنجاح. سيتم مراجعته من قبل القسم المختص.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.request.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('وصف الطلب'),
            const SizedBox(height: 12),
            Text(
              widget.request.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (!widget.request.isGradesRequest) ...[
              const Divider(height: 40),

              _buildSectionHeader('التعليمات'),
              const SizedBox(height: 12),
              _buildInstructionItem(
                'يرجى تعبئة النموذج الرسمي ثم رفعه بعد الإكمال.',
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FormPreviewScreen(request: widget.request),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                  label: const Text('عرض النموذج الرسمي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[50],
                    foregroundColor: AppTheme.navyPrimary,
                    elevation: 0,
                    side: BorderSide(
                      color: AppTheme.navyPrimary.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _uploadForm,
                  icon: const Icon(Icons.upload_file_outlined, size: 20),
                  label: Text(uploadedFileName ?? 'رفع الملف المكتمل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.navyPrimary,
                    elevation: 0,
                    side: const BorderSide(
                      color: AppTheme.navyPrimary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ] else ...[
              const SizedBox(height: 60),
              Center(
                child: Icon(
                  Icons.assessment_outlined,
                  size: 100,
                  color: AppTheme.navyPrimary.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 60),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : (widget.request.isGradesRequest
                          ? () {
                              setState(() => isSubmitting = true);
                              Future.delayed(const Duration(seconds: 1), () {
                                if (!mounted) return;
                                setState(() => isSubmitting = false);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تم بنجاح'),
                                    content: const Text(
                                      'سيتم عرض درجاتك قريباً.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('موافق'),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            }
                          : _submitRequest),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: AppTheme.navyPrimary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.request.isGradesRequest
                            ? 'طلب عرض الدرجات'
                            : 'إرسال الطلب',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.almarai(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppTheme.navyPrimary,
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppTheme.softBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.almarai(
                fontSize: 14,
                color: AppTheme.navyPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
