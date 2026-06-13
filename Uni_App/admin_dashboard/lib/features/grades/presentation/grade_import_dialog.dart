import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/grade_import_repository.dart';
import '../providers/grades_provider.dart';
import '../../semesters/providers/semesters_provider.dart';

class GradeImportDialog extends ConsumerStatefulWidget {
  const GradeImportDialog({super.key});

  @override
  ConsumerState<GradeImportDialog> createState() => _GradeImportDialogState();
}

class _GradeImportDialogState extends ConsumerState<GradeImportDialog> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Semester
  int? _selectedSemesterId;

  // Step 2: File
  PlatformFile? _selectedFile;
  Map<String, dynamic>? _previewData;

  // Step 3: Mapping & Validation
  final Map<String, String> _mapping = {};
  Map<String, dynamic>? _validationSummary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'استيراد الدرجات من Excel',
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(height: 32),

            // Stepper
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.transparent,
                  colorScheme: cs.copyWith(primary: cs.primary),
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  elevation: 0,
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_currentStep > 0 && _currentStep < 3)
                            TextButton(
                              onPressed: _isLoading ? null : details.onStepCancel,
                              child: const Text('السابق'),
                            ),
                          const SizedBox(width: 16),
                          if (_currentStep < 3)
                            FilledButton(
                              onPressed: _isLoading ? null : details.onStepContinue,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(_currentStep == 2 ? 'استيراد الدرجات' : 'التالي'),
                            ),
                        ],
                      ),
                    );
                  },
                  onStepContinue: _handleContinue,
                  onStepCancel: _handleCancel,
                  steps: [
                    Step(
                      title: const Text('الفصل الدراسي'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                      content: _buildStep1Semester(cs),
                    ),
                    Step(
                      title: const Text('رفع ملف Excel'),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                      content: _buildStep2File(cs, tt),
                    ),
                    Step(
                      title: const Text('معاينة البيانات'),
                      isActive: _currentStep >= 2,
                      content: _buildStep3Validation(cs, tt),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP 1 ─────────────────────────────────────────────────────────────

  Widget _buildStep1Semester(ColorScheme cs) {
    final semestersAsync = ref.watch(semestersProvider);

    return semestersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ في تحميل الفصول: $e')),
      data: (semesters) {
        if (semesters.isEmpty) {
          return const Center(child: Text('لا توجد فصول دراسية متاحة.'));
        }
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withAlpha(50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر الفصل الدراسي المستهدف للدرجات:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedSemesterId,
                isExpanded: true,
                dropdownColor: cs.surface,
                decoration: InputDecoration(
                  labelText: 'الفصل الدراسي',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.date_range),
                ),
                items: semesters.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text(s.displayLabel),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedSemesterId = val);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── STEP 2 ─────────────────────────────────────────────────────────────

  Widget _buildStep2File(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الخطوة 1: تحميل النموذج (اختياري)', style: tt.titleMedium),
            OutlinedButton.icon(
              onPressed: () async {
                final url = Uri.parse(ref.read(gradeImportRepositoryProvider).templateDownloadUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('تحميل النموذج'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('الخطوة 2: اختيار الملف المعبأ', style: tt.titleMedium),
        const SizedBox(height: 16),
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file_rounded, size: 48, color: cs.primary),
                const SizedBox(height: 16),
                Text(
                  _selectedFile?.name ?? 'اضغط هنا لاختيار ملف (xlsx, xls, csv)',
                  style: tt.bodyLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: _selectedFile != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true, // Necessary for web
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  // ─── STEP 3 ─────────────────────────────────────────────────────────────

  Widget _buildStep3Validation(ColorScheme cs, TextTheme tt) {
    if (_validationSummary == null) {
      return const Center(child: Text('جاري التحقق...'));
    }

    final summary = _validationSummary!['summary'];
    final total = summary['total_rows'] ?? 0;
    final valid = summary['valid_count'] ?? 0;
    final invalid = summary['invalid_count'] ?? 0;
    final updates = summary['will_update_count'] ?? 0;
    final List errors = summary['errors'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatCard('إجمالي الصفوف', total.toString(), Colors.blueGrey, cs),
            const SizedBox(width: 12),
            _buildStatCard('عدد السجلات الصحيحة', valid.toString(), Colors.green, cs),
            const SizedBox(width: 12),
            _buildStatCard('سجلات للتحديث', updates.toString(), Colors.orange, cs),
            const SizedBox(width: 12),
            _buildStatCard('عدد السجلات الخاطئة', invalid.toString(), Colors.red, cs),
          ],
        ),
        const SizedBox(height: 24),
        if (errors.isNotEmpty) ...[
          Text('تفاصيل الأخطاء:', style: tt.titleMedium?.copyWith(color: Colors.red)),
          const SizedBox(height: 8),
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withAlpha(50)),
            ),
            child: ListView.builder(
              itemCount: errors.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errors[index].toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                SizedBox(height: 12),
                Text(
                  'الملف صالح تماماً ولا توجد أخطاء!',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          )
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, ColorScheme cs) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ─── HANDLers ───────────────────────────────────────────────────────────

  void _handleCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _handleContinue() async {
    if (_currentStep == 0) {
      if (_selectedSemesterId == null) {
        _showError('الرجاء اختيار الفصل الدراسي أولاً.');
        return;
      }
      setState(() => _currentStep = 1);
    } 
    else if (_currentStep == 1) {
      if (_selectedFile == null) {
        _showError('الرجاء رفع الملف أولاً.');
        return;
      }
      await _uploadAndValidate();
    } 
    else if (_currentStep == 2) {
      await _commitImport();
    }
  }

  Future<void> _uploadAndValidate() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(gradeImportRepositoryProvider);
      
      // 1. Upload for Preview
      final previewResult = await repo.previewFile(
        _selectedFile!.bytes!,
        _selectedFile!.name,
      );

      _previewData = previewResult;
      
      // Auto-map based on exact header match
      final headers = (previewResult['headers'] as List).cast<String>();
      final dbFields = previewResult['db_fields'] as List;
      _mapping.clear();
      
      for (var field in dbFields) {
        final key = field['key'] as String;
        // Find best match in headers
        // Just defaulting to Header String for automatic mapping
        // In a real advanced app, we could show a mapping UI here, 
        // but since we provide a template, auto-mapping by name is fine.
        
        String mappedHeader = '';
        if (key == 'student_number') { mappedHeader = 'Student ID / Number'; }
        else if (key == 'course_code') { mappedHeader = 'Course Code'; }
        else if (key == 'first') { mappedHeader = 'First Exam'; }
        else if (key == 'second') { mappedHeader = 'Second Exam'; }
        else if (key == 'midterm') { mappedHeader = 'Midterm Exam'; }
        else if (key == 'final') { mappedHeader = 'Final Exam'; }
        else if (key == 'grade_estimate') { mappedHeader = 'Grade Estimate'; }

        if (headers.contains(mappedHeader)) {
          _mapping[key] = mappedHeader;
        }
      }

      // 2. Validate
      final tempPath = previewResult['temp_path'];
      final validationResult = await repo.validateImport(
        tempPath,
        _mapping,
        _selectedSemesterId!,
      );

      setState(() {
        _validationSummary = validationResult;
        _currentStep = 2; // Move to step 3 (Preview)
      });
    } catch (e) {
      _showError('فشل رفع الملف: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _commitImport() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(gradeImportRepositoryProvider);
      final result = await repo.storeImport(
        _previewData!['temp_path'],
        _mapping,
        _selectedSemesterId!,
      );

      if (mounted) {
        Navigator.pop(context); // Close dialog
        _showSuccess(result);
        ref.invalidate(allGradesProvider); // Auto refresh
      }
    } catch (e) {
      _showError('فشل الاستيراد: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(Map<String, dynamic> result) {
    final summary = result['summary'] ?? {};
    final success = summary['success_count'] ?? 0;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم الاستيراد بنجاح! تم حفظ $success سجلات.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
