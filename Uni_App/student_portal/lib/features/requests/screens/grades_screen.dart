import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/theme/app_theme.dart';
import 'package:university_app/features/requests/widgets/form_inputs.dart';
import 'package:university_app/l10n/app_localizations.dart';
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
  bool _hasError = false;
  bool _surveyOpened = false;
  Map<String, List<dynamic>> _semesterGrades = {};
  Map<String, dynamic>? _surveyData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGrades();
    });
  }

  void _loadGrades() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }
      final response = await context.read<ApiClient>().get(ApiConstants.grades);
      
      if (response == null) {
        if (mounted) {
          setState(() {
            _semesterGrades = {};
            _surveyData = null;
            _isLoading = false;
          });
        }
        return;
      }

      if (response['requires_survey'] == true) {
        if (mounted) {
          setState(() {
            _surveyData = response['survey'];
            _isLoading = false;
          });
        }
        return;
      }

      final data = response['data'];
      if (data == null || data is! Map<String, dynamic>) {
        if (mounted) {
          setState(() {
            _semesterGrades = {};
            _surveyData = null;
            _isLoading = false;
          });
        }
        return;
      }

      final semesterGrades = data.map((key, value) {
        return MapEntry(key, List<dynamic>.from(value));
      });
      if (mounted) {
        setState(() {
          _semesterGrades = semesterGrades;
          _surveyData = null;
          if (semesterGrades.isNotEmpty) {
            _selectedSemester = semesterGrades.keys.first;
          } else {
            _selectedSemester = null;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingGrades),
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

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingGrades,
              textAlign: TextAlign.center,
              style: GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadGrades,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grading_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.noPreviousRequests, // Using existing key as fallback
              textAlign: TextAlign.center,
              style: GoogleFonts.almarai(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
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

    final name = user['name'] ?? '';
    final studentId = student['student_number'] ?? '';
    final rawGpa = student['cumulative_gpa'];
    final cumulativeGpa = rawGpa == null
        ? 'N/A'
        : double.parse(rawGpa.toString()).toStringAsFixed(2);
    final completedCreditHours = (student['completed_credit_hours'] ?? '0').toString();
    final remainingCreditHours = (student['remaining_credit_hours'] ?? '0').toString();
    final statusVal = student['status']?.toString().toLowerCase() ?? 'active';

    final semestersList = _semesterGrades.keys.toList();
    final isReady = _selectedSemester != null;
    final displayedGrades = isReady
        ? (_semesterGrades[_selectedSemester] ?? [])
        : [];

    final semesterGpa = _calculateSemesterGPA(displayedGrades);
    final semesterHours = _calculateSemesterHours(displayedGrades);

    final isMobile = MediaQuery.of(context).size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gradesAndResults),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : _surveyData != null
                  ? _buildSurveyLock()
                  : _semesterGrades.isEmpty
                      ? _buildEmptyState()
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
                                studentId.isNotEmpty ? l10n.academicIdLabel(studentId) : '',
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
                              color: (statusVal == 'active'
                                      ? Colors.green
                                      : (statusVal == 'suspended' ? Colors.red : Colors.blue))
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              statusVal == 'active'
                                  ? l10n.statusActive
                                  : (statusVal == 'suspended'
                                      ? l10n.statusSuspended
                                      : (statusVal == 'graduated'
                                          ? l10n.statusGraduated
                                          : statusVal)),
                              style: GoogleFonts.almarai(
                                color: statusVal == 'active'
                                    ? Colors.green
                                    : (statusVal == 'suspended' ? Colors.red : Colors.blue),
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
                              title: l10n.cumulativeGpa,
                              value: cumulativeGpa,
                              icon: Icons.auto_graph_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: l10n.semesterGpa,
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
                              title: l10n.completedHours,
                              value: completedCreditHours,
                              icon: Icons.school_rounded,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: l10n.remainingHours,
                              value: remainingCreditHours,
                              icon: Icons.hourglass_empty_rounded,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: l10n.semesterHoursLabel,
                              value: semesterHours > 0 ? '$semesterHours' : '-',
                              icon: Icons.menu_book_rounded,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Semester Dropdown Filter
                      if (semestersList.isNotEmpty)
                        DropdownField(
                          label: l10n.academicSemester,
                          items: semestersList,
                          value: _selectedSemester,
                          onChanged: (val) => setState(() => _selectedSemester = val),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l10n.noSemestersRegistered,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Grades display (Table or Cards depending on device size)
                      if (isReady) ...[
                        if (displayedGrades.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(l10n.noGradesForSemester),
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
                                  columns: [
                                    DataColumn(label: Text(l10n.courseNameCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.courseworkCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.midtermCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.finalExamCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.controlGradeCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.mercyGradeCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.firstRoundStatusCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.retakeCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.retakeStatusCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.retakeYearCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.gpaCol, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text(l10n.gradeCol, style: const TextStyle(fontWeight: FontWeight.bold))),
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
                                    String statusText = l10n.failedStatus;
                                    if (rawStatus == 'passed') {
                                      statusText = l10n.passedStatus;
                                    } else if (rawStatus == 'incomplete') {
                                      statusText = l10n.incompleteStatus;
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
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              l10n.pleaseSelectSemester,
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
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
    final l10n = AppLocalizations.of(context)!;
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
        String statusText = l10n.failedStatus;
        if (rawStatus == 'passed') {
          statusText = l10n.passedStatus;
        } else if (rawStatus == 'incomplete') {
          statusText = l10n.incompleteStatus;
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
                          '$courseCode | $creditHours ${l10n.semesterHoursLabel}',
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
                  _buildCardScoreItem(l10n.courseworkCol, courseworkVal.toString()),
                  _buildCardScoreItem(l10n.midtermCol, midtermVal.toString()),
                  _buildCardScoreItem(l10n.finalExamCol, finalVal.toString()),
                  _buildCardScoreItem(l10n.totalGradeCol, totalVal.toString(), isHighlight: true),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${l10n.gpaCol}: ',
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
    final l10n = AppLocalizations.of(context)!;
    final surveyTitle = _surveyData?['title'] ?? l10n.openSurvey;
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
                l10n.gradesAndResults,
                textAlign: TextAlign.center,
                style: GoogleFonts.almarai(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.pleaseCompleteSurveyFirst,
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
                  _surveyOpened ? l10n.surveyOpened : l10n.openSurvey,
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
                          SnackBar(content: Text(l10n.failedToOpenSurveyLink)),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.failedToOpenSurveyLink)),
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
                  l10n.viewGrades,
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
                  l10n.pleaseCompleteSurveyFirst,
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
    final l10n = AppLocalizations.of(context)!;
    final isPass = status == l10n.passedStatus;
    final isPending = status == l10n.incompleteStatus;
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
