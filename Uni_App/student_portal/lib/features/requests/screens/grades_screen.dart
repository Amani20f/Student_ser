import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/theme/app_theme.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:university_app/features/auth/cubit/auth_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? _selectedSemester;
  bool _isLoading = true;
  bool _surveyOpened = false;
  Map<String, List<dynamic>> _semesterGrades = {};
  Map<String, dynamic>? _surveyData;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  void _loadGrades() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      final response = await context.read<ApiClient>().get(ApiConstants.grades);
      
      if (response['requires_survey'] == true) {
        if (mounted) {
          setState(() {
            _surveyData = response['survey'];
            _isLoading = false;
          });
        }
        return;
      }

      final data = response['data'] as Map<String, dynamic>;
      final semesterGrades = data.map((key, value) {
        return MapEntry(key, List<dynamic>.from(value));
      });
      if (mounted) {
        setState(() {
          _semesterGrades = semesterGrades;
          _surveyData = null;
          if (semesterGrades.isNotEmpty) {
            _selectedSemester = semesterGrades.keys.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الدرجات: ${e.toString().replaceAll('Exception:', '').replaceAll('ApiException:', '').trim()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _calculateLetterGrade(num total) {
    if (total >= 95) return 'A+';
    if (total >= 90) return 'A';
    if (total >= 85) return 'B+';
    if (total >= 80) return 'B';
    if (total >= 75) return 'C+';
    if (total >= 70) return 'C';
    if (total >= 65) return 'D+';
    if (total >= 60) return 'D';
    return 'F';
  }

  double _calculateSemesterGPA(List<dynamic> grades) {
    double totalPoints = 0.0;
    int totalHours = 0;
    for (var grade in grades) {
      final map = grade as Map<String, dynamic>;
      final hours = int.tryParse(map['credit_hours']?.toString() ?? '0') ?? 0;
      final gpaVal = double.tryParse(map['gpa']?.toString() ?? '0.0') ?? 0.0;
      final status = map['status']?.toString() ?? '';
      
      if (status != 'incomplete' && hours > 0) {
        totalPoints += gpaVal * hours;
        totalHours += hours;
      }
    }
    return totalHours > 0 ? (totalPoints / totalHours) : 0.0;
  }

  int _calculateSemesterHours(List<dynamic> grades) {
    int totalHours = 0;
    for (var grade in grades) {
      final map = grade as Map<String, dynamic>;
      final hours = int.tryParse(map['credit_hours']?.toString() ?? '0') ?? 0;
      totalHours += hours;
    }
    return totalHours;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    Map<String, dynamic> user = {};
    Map<String, dynamic> student = {};
    if (authState is Authenticated) {
      user = authState.user;
      student = user['student'] ?? {};
    }

    final name = user['name'] ?? 'طالب';
    final studentId = student['student_number'] ?? '';
    final cumulativeGpa = (student['cumulative_gpa'] ?? '0.0').toString();
    final completedCreditHours = (student['completed_credit_hours'] ?? '0').toString();

    final semestersList = _semesterGrades.keys.toList();
    final isReady = _selectedSemester != null;
    final displayedGrades = isReady
        ? (_semesterGrades[_selectedSemester] ?? [])
        : [];

    final semesterGpa = _calculateSemesterGPA(displayedGrades);
    final semesterHours = _calculateSemesterHours(displayedGrades);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدرجات والنتائج'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveyData != null
              ? _buildSurveyLock()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome & Student ID section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.almarai(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'الرقم الأكاديمي: $studentId',
                                style: GoogleFonts.almarai(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'نشط',
                              style: GoogleFonts.almarai(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Summary metrics section
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'المعدل التراكمي',
                              value: cumulativeGpa,
                              icon: Icons.auto_graph_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'المعدل الفصلي',
                              value: semesterGpa > 0 ? semesterGpa.toStringAsFixed(2) : '-',
                              icon: Icons.trending_up_rounded,
                              color: AppTheme.goldAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'الساعات المكتملة',
                              value: completedCreditHours,
                              icon: Icons.school_rounded,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'ساعات الفصل',
                              value: semesterHours > 0 ? '$semesterHours' : '-',
                              icon: Icons.menu_book_rounded,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Semester Dropdown Filter
                      if (semestersList.isNotEmpty)
                        DropdownField(
                          label: 'الفصل الدراسي الأكاديمي',
                          items: semestersList,
                          value: _selectedSemester,
                          onChanged: (val) => setState(() => _selectedSemester = val),
                        )
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'لا توجد فصول دراسية مسجلة',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Grades display (Table or Cards depending on device size)
                      if (isReady) ...[
                        if (displayedGrades.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('لا توجد درجات متوفرة لهذا الفصل'),
                            ),
                          )
                        else if (isMobile)
                          _buildGradesCardsList(displayedGrades)
                        else
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    Theme.of(context).colorScheme.surface,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('اسم المقرر', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('الأعمال الدراسية', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('امتحان نصفي', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('امتحان نهائي', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('درجة الكنترول', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('درجة الرأفة', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('حالة دور أول', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('دور الإعادة', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('حالة الإعادة', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('سنة الإعادة', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('المعدل', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('التقدير', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: displayedGrades.map((course) {
                                    final courseMap = course as Map<String, dynamic>;
                                    final courseName = courseMap['course_name']?.toString() ?? '';
                                    final firstVal = num.tryParse(courseMap['first']?.toString() ?? '0') ?? 0;
                                    final secondVal = num.tryParse(courseMap['second']?.toString() ?? '0') ?? 0;
                                    final courseworkVal = firstVal + secondVal;
                                    final midtermVal = num.tryParse(courseMap['midterm']?.toString() ?? '0') ?? 0;
                                    final finalVal = num.tryParse(courseMap['final']?.toString() ?? '0') ?? 0;
                                    final totalVal = num.tryParse(courseMap['total']?.toString() ?? '0') ?? 0;
                                    
                                    final rawStatus = courseMap['status']?.toString() ?? 'passed';
                                    String statusText = 'راسب';
                                    if (rawStatus == 'passed') {
                                      statusText = 'ناجح';
                                    } else if (rawStatus == 'incomplete') {
                                      statusText = 'غير مكتمل';
                                    }
                                    
                                    final gpaVal = num.tryParse(courseMap['gpa']?.toString() ?? '0') ?? 0.0;
                                    final gradeLetter = _calculateLetterGrade(totalVal);

                                    return DataRow(
                                      cells: [
                                        DataCell(SizedBox(
                                          width: 140,
                                          child: Text(courseName, overflow: TextOverflow.ellipsis),
                                        )),
                                        DataCell(Text(courseworkVal.toString())),
                                        DataCell(Text(midtermVal.toString())),
                                        DataCell(Text(finalVal.toString())),
                                        DataCell(Text(totalVal.toString())),
                                        DataCell(const Text('-')),
                                        DataCell(_statusChip(statusText)),
                                        DataCell(const Text('-')),
                                        DataCell(const Text('-')),
                                        DataCell(const Text('-')),
                                        DataCell(Text(gpaVal.toStringAsFixed(2))),
                                        DataCell(_gradeChip(gradeLetter)),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                      ] else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'يرجى اختيار الفصل الدراسي لعرض الدرجات',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.almarai(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.almarai(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesCardsList(List<dynamic> grades) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grades.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final courseMap = grades[index] as Map<String, dynamic>;
        final courseName = courseMap['course_name']?.toString() ?? '';
        final courseCode = courseMap['course_code']?.toString() ?? '';
        
        final firstVal = num.tryParse(courseMap['first']?.toString() ?? '0') ?? 0;
        final secondVal = num.tryParse(courseMap['second']?.toString() ?? '0') ?? 0;
        final courseworkVal = firstVal + secondVal;
        
        final midtermVal = num.tryParse(courseMap['midterm']?.toString() ?? '0') ?? 0;
        final finalVal = num.tryParse(courseMap['final']?.toString() ?? '0') ?? 0;
        final totalVal = num.tryParse(courseMap['total']?.toString() ?? '0') ?? 0;
        
        final rawStatus = courseMap['status']?.toString() ?? 'passed';
        String statusText = 'راسب';
        if (rawStatus == 'passed') {
          statusText = 'ناجح';
        } else if (rawStatus == 'incomplete') {
          statusText = 'غير مكتمل';
        }
        
        final gpaVal = num.tryParse(courseMap['gpa']?.toString() ?? '0') ?? 0.0;
        final gradeLetter = _calculateLetterGrade(totalVal);
        final creditHours = int.tryParse(courseMap['credit_hours']?.toString() ?? '0') ?? 0;
        
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseName,
                          style: GoogleFonts.almarai(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$courseCode | $creditHours ساعات معتمدة',
                          style: GoogleFonts.almarai(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(statusText),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCardScoreItem('أعمال السنة', courseworkVal.toString()),
                  _buildCardScoreItem('نصفي', midtermVal.toString()),
                  _buildCardScoreItem('نهائي', finalVal.toString()),
                  _buildCardScoreItem('المجموع', totalVal.toString(), isHighlight: true),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'المعدل للمادة: ',
                        style: GoogleFonts.almarai(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        gpaVal.toStringAsFixed(2),
                        style: GoogleFonts.almarai(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  _gradeChip(gradeLetter),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardScoreItem(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.almarai(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.almarai(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyLock() {
    final surveyTitle = _surveyData?['title'] ?? 'استبيان';
    final surveyUrl = _surveyData?['google_form_url'] ?? '';
    final surveyId = _surveyData?['id'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'الدرجات والنتائج محجوبة',
                textAlign: TextAlign.center,
                style: GoogleFonts.almarai(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'يرجى تعبئة الاستبيان التالي لتتمكن من الاطلاع على درجاتك ونتائجك الأكاديمية.',
                textAlign: TextAlign.center,
                style: GoogleFonts.almarai(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 28),
              
              // Survey Details Card
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment_rounded, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              surveyTitle,
                              style: GoogleFonts.almarai(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_surveyData?['description'] != null && _surveyData!['description'].toString().isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(
                          _surveyData!['description'].toString(),
                          style: GoogleFonts.almarai(
                            fontSize: 13,
                            height: 1.5,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Open Survey Button
              ElevatedButton.icon(
                icon: Icon(_surveyOpened ? Icons.check_rounded : Icons.open_in_new_rounded),
                label: Text(
                  _surveyOpened ? 'تم فتح الاستبيان' : 'فتح الاستبيان',
                  style: GoogleFonts.almarai(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _surveyOpened
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  try {
                    final url = Uri.parse(surveyUrl);
                    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                    if (launched) {
                      // Register survey completion on backend
                      try {
                        await context.read<ApiClient>().post(
                          ApiConstants.completeSurvey,
                          body: {'survey_id': surveyId},
                        );
                      } catch (_) {
                        // Ignore API errors here — survey opened successfully
                      }
                      if (mounted) {
                        setState(() => _surveyOpened = true);
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذر فتح رابط الاستبيان')),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تعذر فتح الرابط: $surveyUrl')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // View Grades Button — disabled until survey is opened
              ElevatedButton.icon(
                icon: const Icon(Icons.grading_rounded),
                label: Text(
                  'عرض الدرجات',
                  style: GoogleFonts.almarai(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _surveyOpened
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _surveyOpened
                    ? () {
                        setState(() => _surveyData = null);
                        _loadGrades();
                      }
                    : null,
              ),

              if (!_surveyOpened) ...[
                const SizedBox(height: 12),
                Text(
                  'يرجى فتح الاستبيان وتعبئته أولاً لتفعيل زر عرض الدرجات',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isPass = status == 'ناجح';
    final isPending = status == 'غير مكتمل';
    Color chipColor = Colors.red;
    if (isPass) {
      chipColor = Colors.green;
    } else if (isPending) {
      chipColor = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPass ? Colors.green[700] : (isPending ? Colors.orange[700] : Colors.red[700]),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _gradeChip(String grade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _gradeColor(grade).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: _gradeColor(grade),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+': return Colors.green[800]!;
      case 'A':  return Colors.green[600]!;
      case 'B+': return Colors.blue[700]!;
      case 'B':  return Colors.blue[500]!;
      case 'C+': return Colors.orange[700]!;
      case 'C':  return Colors.orange[500]!;
      case 'D+': return Colors.deepOrange[700]!;
      case 'D':  return Colors.deepOrange[500]!;
      default:   return Colors.red[700]!;
    }
  }
}
