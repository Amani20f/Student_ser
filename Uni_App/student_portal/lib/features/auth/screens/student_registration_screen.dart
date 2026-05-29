import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:university_app/core/data/academic_repository.dart';
import 'package:university_app/core/network/api_client.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // -- Personal Info Controllers --
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'سعودي');
  String? _selectedGender;

  // -- Contact Info Controllers --
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // -- Academic Selection --
  List<CollegeModel> _colleges = [];
  List<ProgramModel> _availablePrograms = [];
  CollegeModel? _selectedCollege;
  ProgramModel? _selectedProgram;
  bool _loadingColleges = true;

  // -- Attachments --
  PlatformFile? _identityDoc;
  PlatformFile? _qualificationDoc;
  PlatformFile? _personalPhoto;

  bool _isSubmitting = false;
  String? _submittedAppNumber;

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiClient = ApiClient(prefs);
      final repo = AcademicRepository(apiClient);
      final colleges = await repo.getColleges();
      setState(() {
        _colleges = colleges;
        _loadingColleges = false;
      });
    } catch (e) {
      setState(() => _loadingColleges = false);
    }
  }

  void _onCollegeChanged(CollegeModel? college) {
    setState(() {
      _selectedCollege = college;
      _selectedProgram = null;
      _availablePrograms = [];
      if (college != null) {
        for (var dept in college.departments) {
          _availablePrograms.addAll(dept.programs);
        }
      }
    });
  }

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        switch (type) {
          case 'identity':
            _identityDoc = result.files.single;
            break;
          case 'qualification':
            _qualificationDoc = result.files.single;
            break;
          case 'photo':
            _personalPhoto = result.files.single;
            break;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار التخصص'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final apiClient = ApiClient(prefs);

      final fields = <String, String>{
        'full_name': _nameController.text.trim(),
        'national_id_number': _nationalIdController.text.trim(),
        'date_of_birth': _dobController.text.trim(),
        'gender': _selectedGender ?? 'female',
        'nationality': _nationalityController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'email_address': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'desired_program_id': _selectedProgram!.id.toString(),
        'desired_academic_level': '1',
      };

      final files = <http.MultipartFile>[];
      if (_identityDoc?.path != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'identity_document',
            _identityDoc!.path!,
          ),
        );
      }
      if (_qualificationDoc?.path != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'qualification_document',
            _qualificationDoc!.path!,
          ),
        );
      }
      if (_personalPhoto?.path != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'personal_photo',
            _personalPhoto!.path!,
          ),
        );
      }

      final response = await apiClient.postMultipart(
        '/apply',
        fields: fields,
        files: files,
      );

      if (mounted) {
        setState(() {
          _submittedAppNumber = response['application_number'] ?? '';
          _isSubmitting = false;
        });
        _showSuccessDialog(response['application_number'] ?? '');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الإرسال: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String appNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('تم إرسال الطلب'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تم استلام طلب تسجيلك بنجاح. سيتم مراجعته والتواصل معك.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'رقم الطلب المرجعي:',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appNumber,
                    style: GoogleFonts.robotoMono(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'احتفظ بهذا الرقم للاستعلام عن حالة طلبك',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to login
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل طالب جديد'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: theme.colorScheme.surface,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: GradientBackground(
        child: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              // ─── Page 1: Personal Info ─────────────────────────────────
              _buildPage(
                title: 'المعلومات الشخصية',
                icon: Icons.person_outline,
                children: [
                  LabeledTextField(
                    label: 'الاسم الكامل رباعياً',
                    controller: _nameController,
                    validator: (v) => v!.trim().length < 5
                        ? 'الاسم مطلوب (4 كلمات على الأقل)'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'رقم الهوية الوطنية',
                    controller: _nationalIdController,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v!.trim().length < 10 ? 'رقم هوية غير صحيح' : null,
                  ),
                  const SizedBox(height: 16),
                  DatePickerField(
                    label: 'تاريخ الميلاد',
                    controller: _dobController,
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownField(
                    label: 'الجنس',
                    items: const ['female', 'male'],
                    value: _selectedGender,
                    onChanged: (v) => setState(() => _selectedGender = v),
                    validator: (v) => v == null ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'الجنسية',
                    controller: _nationalityController,
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                ],
              ),

              // ─── Page 2: Contact + Academic ─────────────────────────────
              _buildPage(
                title: 'بيانات التواصل والتخصص',
                icon: Icons.school_outlined,
                children: [
                  LabeledTextField(
                    label: 'رقم الجوال',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'البريد الإلكتروني',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        !v!.contains('@') ? 'بريد غير صحيح' : null,
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'العنوان (اختياري)',
                    controller: _addressController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (_loadingColleges)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الكلية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<CollegeModel>(
                          isExpanded: true,
                          initialValue: _selectedCollege,
                          hint: const Text('اختر الكلية'),
                          items: _colleges
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _onCollegeChanged,
                          validator: (v) => v == null ? 'اختر الكلية' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التخصص',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ProgramModel>(
                          isExpanded: true,
                          initialValue: _selectedProgram,
                          hint: const Text('اختر التخصص'),
                          items: _availablePrograms
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedProgram = v),
                          validator: (v) => v == null ? 'اختر التخصص' : null,
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              // ─── Page 3: Attachments ─────────────────────────────────────
              _buildPage(
                title: 'المستندات والمرفقات',
                icon: Icons.attach_file,
                children: [
                  _buildFileRow(
                    label: 'صورة الهوية الوطنية *',
                    file: _identityDoc,
                    onPick: () => _pickFile('identity'),
                  ),
                  const SizedBox(height: 16),
                  _buildFileRow(
                    label: 'شهادة الثانوية / المؤهل *',
                    file: _qualificationDoc,
                    onPick: () => _pickFile('qualification'),
                  ),
                  const SizedBox(height: 16),
                  _buildFileRow(
                    label: 'الصورة الشخصية',
                    file: _personalPhoto,
                    onPick: () => _pickFile('photo'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'سيتم إرسال رقم مرجعي عند الإرسال. احتفظ به للاستعلام عن حالة طلبك.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                isLastPage: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool isLastPage = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الخطوة ${_currentPage + 1} من 3',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          ...children,
          const SizedBox(height: 32),
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    ),
                    child: const Text('السابق'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : isLastPage
                      ? _submit
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(isLastPage ? 'إرسال الطلب' : 'التالي'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFileRow({
    required String label,
    required PlatformFile? file,
    required VoidCallback onPick,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(
                color: file != null
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(10),
              color: file != null
                  ? theme.colorScheme.primary.withOpacity(0.05)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  file != null ? Icons.check_circle : Icons.upload_file,
                  color: file != null
                      ? theme.colorScheme.primary
                      : theme.hintColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file != null
                        ? file.name
                        : 'انقر لرفع الملف (PDF, JPG, PNG)',
                    style: TextStyle(
                      color: file != null
                          ? theme.colorScheme.primary
                          : theme.hintColor,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (file != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() {
                      if (label.contains('هوية')) _identityDoc = null;
                      if (label.contains('شهادة')) _qualificationDoc = null;
                      if (label.contains('صورة')) _personalPhoto = null;
                    }),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
