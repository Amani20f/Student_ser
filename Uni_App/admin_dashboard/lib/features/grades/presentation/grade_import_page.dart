import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../data/grade_import_repository.dart';
import '../providers/grades_provider.dart';
import '../../semesters/providers/semesters_provider.dart';
import '../../programs/providers/programs_provider.dart';
import '../../courses/providers/courses_provider.dart';
import '../../../core/utils/download_helper.dart';

class GradeImportPage extends ConsumerStatefulWidget {
  const GradeImportPage({super.key});

  @override
  ConsumerState<GradeImportPage> createState() => _GradeImportPageState();
}

class _GradeImportPageState extends ConsumerState<GradeImportPage> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Selections
  int? _selectedSemesterId;
  int? _selectedProgramId;
  int? _selectedCourseId;

  // File & Preview
  PlatformFile? _selectedFile;
  Map<String, dynamic>? _previewData;

  // Validation
  final Map<String, String> _mapping = {};
  Map<String, dynamic>? _validationSummary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        if (_currentStep > 0 && _currentStep < 5)
                          TextButton(
                            onPressed: _isLoading ? null : details.onStepCancel,
                            child: Text(isAr ? 'السابق' : 'Back'),
                          ),
                        const SizedBox(width: 16),
                        if (_currentStep < 5)
                          FilledButton(
                            onPressed: _isLoading ? null : details.onStepContinue,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(_currentStep == 4 
                                    ? (isAr ? 'استيراد الدرجات' : 'Import Grades') 
                                    : (isAr ? 'التالي' : 'Next')),
                          ),
                      ],
                    ),
                  );
                },
                onStepContinue: _handleContinue,
                onStepCancel: _handleCancel,
                steps: [
                  Step(
                    title: Text(isAr ? 'الفصل الدراسي' : 'Semester'),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    content: _buildStep1Semester(cs, isAr),
                  ),
                  Step(
                    title: Text(isAr ? 'البرنامج' : 'Program'),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    content: _buildStep2Program(cs, isAr),
                  ),
                  Step(
                    title: Text(isAr ? 'المقرر' : 'Course'),
                    isActive: _currentStep >= 2,
                    state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                    content: _buildStep3Course(cs, isAr),
                  ),
                  Step(
                    title: Text(isAr ? 'رفع ملف Excel' : 'Upload Excel'),
                    isActive: _currentStep >= 3,
                    state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                    content: _buildStep4File(cs, tt, isAr),
                  ),
                  Step(
                    title: Text(isAr ? 'معاينة البيانات' : 'Preview Data'),
                    isActive: _currentStep >= 4,
                    content: _buildStep5Validation(cs, tt, isAr),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionContainer(ColorScheme cs, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ─── STEP 1 ─────────────────────────────────────────────────────────────

  Widget _buildStep1Semester(ColorScheme cs, bool isAr) {
    final semestersAsync = ref.watch(semestersProvider);

    return semestersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(isAr ? 'خطأ في تحميل الفصول: $e' : 'Error loading semesters: $e')),
      data: (semesters) {
        if (semesters.isEmpty) {
          return Center(child: Text(isAr ? 'لا توجد فصول دراسية متاحة.' : 'No semesters available.'));
        }
        return _buildSelectionContainer(cs, [
          Text(
            isAr ? 'اختر الفصل الدراسي المستهدف للدرجات:' : 'Select target semester for grades:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedSemesterId,
            isExpanded: true,
            dropdownColor: cs.surface,
            decoration: InputDecoration(
              labelText: isAr ? 'الفصل الدراسي' : 'Semester',
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
              setState(() {
                _selectedSemesterId = val;
                _selectedProgramId = null;
                _selectedCourseId = null;
              });
            },
          ),
        ]);
      },
    );
  }

  // ─── STEP 2 ─────────────────────────────────────────────────────────────

  Widget _buildStep2Program(ColorScheme cs, bool isAr) {
    final programsAsync = ref.watch(staffProgramsProvider);

    return programsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(isAr ? 'خطأ: $e' : 'Error: $e')),
      data: (programs) {
        // Filter out any medical or unwanted programs if they snuck in
        final validPrograms = programs.where((p) => 
            !p.name.toLowerCase().contains('medicine') &&
            !p.name.toLowerCase().contains('nursing') &&
            !p.name.toLowerCase().contains('pharmacy') &&
            !p.name.toLowerCase().contains('dentistry') &&
            !p.name.toLowerCase().contains('test')
        ).toList();

        if (validPrograms.isEmpty) {
          return Center(child: Text(isAr ? 'لا توجد برامج متاحة.' : 'No programs available.'));
        }
        return _buildSelectionContainer(cs, [
          Text(
            isAr ? 'اختر التخصص:' : 'Select Program / Specialization:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedProgramId,
            isExpanded: true,
            dropdownColor: cs.surface,
            decoration: InputDecoration(
              labelText: isAr ? 'البرنامج' : 'Program',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.school),
            ),
            items: validPrograms.map((p) {
              return DropdownMenuItem(
                value: p.id,
                child: Text('${p.name} (${p.code})'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedProgramId = val;
                _selectedCourseId = null;
              });
            },
          ),
        ]);
      },
    );
  }

  // ─── STEP 3 ─────────────────────────────────────────────────────────────

  Widget _buildStep3Course(ColorScheme cs, bool isAr) {
    if (_selectedProgramId == null) {
      return Center(child: Text(isAr ? 'الرجاء اختيار التخصص أولاً.' : 'Please select a program first.'));
    }

    final coursesAsync = ref.watch(staffCoursesProvider);

    return coursesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(isAr ? 'خطأ: $e' : 'Error: $e')),
      data: (allCourses) {
        final programCourses = allCourses.where((c) => c.programId == _selectedProgramId).toList();

        if (programCourses.isEmpty) {
          return Center(child: Text(isAr ? 'لا توجد مقررات لهذا التخصص.' : 'No courses found for this program.'));
        }
        return _buildSelectionContainer(cs, [
          Text(
            isAr ? 'اختر المقرر:' : 'Select Course:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedCourseId,
            isExpanded: true,
            dropdownColor: cs.surface,
            decoration: InputDecoration(
              labelText: isAr ? 'المقرر' : 'Course',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.book),
            ),
            items: programCourses.map((c) {
              return DropdownMenuItem(
                value: c.id,
                child: Text('${c.courseName} (${c.courseCode})'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => _selectedCourseId = val);
            },
          ),
        ]);
      },
    );
  }

  // ─── STEP 4 ─────────────────────────────────────────────────────────────

  Widget _buildStep4File(ColorScheme cs, TextTheme tt, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isAr ? 'الخطوة 1: تحميل نموذج ببيانات تجريبية (اختياري)' : 'Step 1: Download Sample File (Optional)', style: tt.titleMedium),
            OutlinedButton.icon(
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  final bytes = await ref.read(gradeImportRepositoryProvider).downloadTemplateBytes();
                  downloadFileHelper(bytes, 'grades_sample.csv');
                } catch (e) {
                  _showError(isAr ? 'فشل تحميل الملف' : 'Failed to download file');
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              icon: const Icon(Icons.download_rounded),
              label: Text(isAr ? 'تحميل الملف' : 'Download Sample File'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(isAr ? 'الخطوة 2: اختيار الملف المعبأ' : 'Step 2: Select filled file', style: tt.titleMedium),
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
              border: Border.all(color: cs.primary.withAlpha(50), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file_rounded, size: 48, color: cs.primary),
                const SizedBox(height: 16),
                Text(
                  _selectedFile?.name ?? (isAr ? 'اضغط هنا لاختيار ملف (xlsx, xls, csv)' : 'Click here to choose file (xlsx, xls, csv)'),
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
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  // ─── STEP 5 ─────────────────────────────────────────────────────────────

  Widget _buildStep5Validation(ColorScheme cs, TextTheme tt, bool isAr) {
    if (_validationSummary == null) {
      return Center(child: Text(isAr ? 'جاري التحقق...' : 'Verifying...'));
    }

    final summary = _validationSummary!['summary'] ?? _validationSummary!;
    final total = summary['total'] ?? summary['total_rows'] ?? 0;
    final valid = summary['valid_count'] ?? 0;
    final invalid = summary['invalid_count'] ?? 0;
    final updates = summary['will_update_count'] ?? 0;
    final List errors = summary['errors'] ?? [];
    final List previewRows = summary['preview_rows'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatCard(isAr ? 'إجمالي الصفوف' : 'Total Rows', total.toString(), Colors.blueGrey, cs),
            const SizedBox(width: 12),
            _buildStatCard(isAr ? 'سجلات صحيحة' : 'Valid Records', valid.toString(), Colors.green, cs),
            const SizedBox(width: 12),
            _buildStatCard(isAr ? 'سجلات للتحديث' : 'Will Update', updates.toString(), Colors.orange, cs),
            const SizedBox(width: 12),
            _buildStatCard(isAr ? 'سجلات خاطئة' : 'Invalid Records', invalid.toString(), Colors.red, cs),
          ],
        ),
        const SizedBox(height: 24),
        if (errors.isNotEmpty) ...[
          Text(isAr ? 'تفاصيل الأخطاء:' : 'Errors details:', style: tt.titleMedium?.copyWith(color: Colors.red)),
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
        ],
        if (previewRows.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(isAr ? 'معاينة البيانات الصحيحة:' : 'Valid Data Preview:', style: tt.titleMedium),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant.withAlpha(50)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                columns: [
                  DataColumn(label: Text(isAr ? 'رقم الطالب' : 'Student ID')),
                  DataColumn(label: Text(isAr ? 'اسم الطالب' : 'Student Name')),
                  DataColumn(label: Text(isAr ? 'أعمال السنة' : 'Coursework')),
                  DataColumn(label: Text(isAr ? 'الاختبار النصفي' : 'Midterm')),
                  DataColumn(label: Text(isAr ? 'الاختبار النهائي' : 'Final')),
                  DataColumn(label: Text(isAr ? 'المجموع' : 'Total')),
                ],
                rows: previewRows.map<DataRow>((row) {
                  return DataRow(
                    cells: [
                      DataCell(Text(row['student_number'].toString())),
                      DataCell(Text(row['student_name'].toString())),
                      DataCell(Text(row['coursework'].toString())),
                      DataCell(Text(row['midterm'].toString())),
                      DataCell(Text(row['final'].toString())),
                      DataCell(Text(row['total'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  );
                }).toList(),
              ),
            ),
          )
        ]
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
            Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ─── HANDLERS ───────────────────────────────────────────────────────────

  void _handleCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _handleContinue() async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_currentStep == 0) {
      if (_selectedSemesterId == null) {
        _showError(isAr ? 'الرجاء اختيار الفصل الدراسي أولاً.' : 'Please select a semester first.');
        return;
      }
      setState(() => _currentStep = 1);
    } 
    else if (_currentStep == 1) {
      if (_selectedProgramId == null) {
        _showError(isAr ? 'الرجاء اختيار التخصص أولاً.' : 'Please select a program first.');
        return;
      }
      setState(() => _currentStep = 2);
    }
    else if (_currentStep == 2) {
      if (_selectedCourseId == null) {
        _showError(isAr ? 'الرجاء اختيار المقرر أولاً.' : 'Please select a course first.');
        return;
      }
      setState(() => _currentStep = 3);
    }
    else if (_currentStep == 3) {
      if (_selectedFile == null) {
        _showError(isAr ? 'الرجاء رفع الملف أولاً.' : 'Please upload file first.');
        return;
      }
      await _uploadAndValidate();
    } 
    else if (_currentStep == 4) {
      await _commitImport();
    }
  }

  Future<void> _uploadAndValidate() async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(gradeImportRepositoryProvider);
      
      final previewResult = await repo.previewFile(
        _selectedFile!.bytes!,
        _selectedFile!.name,
      );

      _previewData = previewResult;
      
      final headers = (previewResult['headers'] as List).cast<String>();
      final dbFields = previewResult['db_fields'] as List;
      _mapping.clear();
      
      for (var field in dbFields) {
        final key = field['key'] as String;
        
        String mappedHeader = '';
        if (key == 'student_number') { mappedHeader = 'Student ID'; }
        else if (key == 'coursework') { mappedHeader = 'Coursework'; }
        else if (key == 'midterm') { mappedHeader = 'Midterm'; }
        else if (key == 'final') { mappedHeader = 'Final'; }

        if (headers.contains(mappedHeader)) {
          _mapping[key] = mappedHeader;
        }
      }

      final tempPath = previewResult['temp_path'];
      final validationResult = await repo.validateImport(
        tempPath,
        _mapping,
        _selectedSemesterId!,
        _selectedProgramId!,
        _selectedCourseId!
      );

      setState(() {
        _validationSummary = validationResult;
        _currentStep = 4;
      });
    } catch (e) {
      _showError(isAr ? 'فشل رفع أو التحقق من الملف: $e' : 'Failed to upload or validate file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _commitImport() async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(gradeImportRepositoryProvider);
      final result = await repo.storeImport(
        _previewData!['temp_path'],
        _mapping,
        _selectedSemesterId!,
        _selectedProgramId!,
        _selectedCourseId!
      );

      if (mounted) {
        _showSuccess(result);
        ref.invalidate(allGradesProvider);
        setState(() {
          _currentStep = 0;
          _selectedFile = null;
          _previewData = null;
          _validationSummary = null;
        });
      }
    } catch (e) {
      _showError(isAr ? 'فشل استيراد الدرجات: $e' : 'Failed to import grades: $e');
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final summary = result['summary'] ?? result;
    final success = summary['success_count'] ?? 0;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAr 
            ? 'تم استيراد الدرجات بنجاح! تم حفظ $success سجلات.' 
            : 'Grades imported successfully! Saved $success records.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
