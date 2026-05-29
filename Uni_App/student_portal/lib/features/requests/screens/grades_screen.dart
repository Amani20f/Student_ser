import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/theme/app_theme.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:university_app/features/auth/cubit/auth_cubit.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? _selectedSemester;
  bool _isLoading = true;
  Map<String, List<dynamic>> _semesterGrades = {};

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  void _loadGrades() async {
    try {
      final response = await context.read<ApiClient>().get(ApiConstants.grades);
      final data = response['data'] as Map<String, dynamic>;
      final semesterGrades = data.map((key, value) {
        return MapEntry(key, List<dynamic>.from(value));
      });
      setState(() {
        _semesterGrades = semesterGrades;
        if (semesterGrades.isNotEmpty) {
          _selectedSemester = semesterGrades.keys.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الدرجات: ${e.toString().replaceAll('Exception:', '').replaceAll('ApiException:', '').trim()}'),
          backgroundColor: Colors.red,
        ),
      );
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

    final semestersList = _semesterGrades.keys.toList();
    final isReady = _selectedSemester != null;
    final displayedGrades = isReady
        ? (_semesterGrades[_selectedSemester] ?? [])
        : [];

    return Scaffold(
      appBar: AppBar(title: const Text('كشف الدرجات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.almarai(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              studentId,
                              style: GoogleFonts.almarai(
                                color: AppTheme.goldAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'المعدل التراكمي (GPA): $cumulativeGpa',
                            style: GoogleFonts.almarai(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filters
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

                  const SizedBox(height: 24),

                  if (isReady) ...[
                    if (displayedGrades.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('لا توجد درجات متوفرة لهذا الفصل'),
                        ),
                      )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.surface,
                        ),
                        columns: const [
                          DataColumn(label: Text('اسم المقرر',       style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('الأعمال الدراسية', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('امتحان نصفي',      style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('امتحان نهائي',     style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('درجة الكنترول',    style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('درجة الرأفة',      style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('حالة دور أول',     style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('دور الإعادة',      style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('حالة الإعادة',     style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('سنة الإعادة',      style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('المعدل',           style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('التقدير',          style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: displayedGrades.map((course) {
                          final courseMap = course as Map<String, dynamic>;
                          final courseName = courseMap['courseName'] ?? '';
                          final courseworkVal = (courseMap['first'] ?? 0) + (courseMap['second'] ?? 0);
                          final midtermVal = courseMap['midterm'] ?? 0;
                          final finalVal = courseMap['final'] ?? 0;
                          final totalVal = courseMap['total'] ?? 0;
                          
                          final rawStatus = courseMap['status'] ?? 'pass';
                          final statusText = rawStatus == 'pass' ? 'ناجح' : 'راسب';
                          
                          final gpaVal = courseMap['gpa'] ?? 0.0;
                          final gradeLetter = _calculateLetterGrade(totalVal);

                          return DataRow(
                            cells: [
                              DataCell(SizedBox(
                                width: 130,
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
                              DataCell(Text(gpaVal.toString())),
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
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isPass = status == 'ناجح';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isPass ? Colors.green : Colors.red).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPass ? Colors.green[700] : Colors.red[700],
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
      case 'D':  return Colors.deepOrange[600]!;
      default:   return Colors.red[700]!;
    }
  }
}
