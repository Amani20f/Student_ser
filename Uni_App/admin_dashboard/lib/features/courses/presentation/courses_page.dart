import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../providers/courses_provider.dart';
import '../data/course_model.dart';
import '../providers/colleges_provider.dart';
import '../data/college_model.dart';
import '../../../core/providers/back_action_provider.dart';

class CoursesPage extends ConsumerStatefulWidget {
  const CoursesPage({super.key});

  @override
  ConsumerState<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends ConsumerState<CoursesPage> {
  CollegeModel? _selectedCollege;
  CollegeProgramModel? _selectedProgram;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(coursesProvider);
    List<CourseModel> programCourses = [];
    if (_selectedProgram != null) {
      coursesAsync.whenData((allCourses) {
        programCourses = allCourses.where((c) => c.programId == _selectedProgram!.id).toList();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_selectedCollege != null) {
        ref.read(backActionProvider.notifier).state = () {
          setState(() {
            if (_selectedProgram != null) {
              _selectedProgram = null;
            } else {
              _selectedCollege = null;
              _searchQuery = '';
            }
          });
        };
      } else {
        ref.read(backActionProvider.notifier).state = null;
      }
    });

    return Scaffold(
      floatingActionButton: _selectedProgram != null
          ? FloatingActionButton(
              onPressed: () => _showCourseDialog(context, ref, null, programCourses, l10n),
              child: const Icon(Icons.add),
            )
          : null,
      body: _buildBody(context, l10n, programCourses, coursesAsync),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, List<CourseModel> programCourses, AsyncValue<List<CourseModel>> coursesAsync) {
    if (_selectedCollege == null) {
      return _buildCollegesView(l10n);
    } else if (_selectedProgram == null) {
      return _buildProgramsView(l10n);
    } else {
      return _buildStudyPlanView(l10n, programCourses, coursesAsync);
    }
  }

  Widget _buildCollegesView(AppLocalizations l10n) {
    final collegesAsync = ref.watch(collegesProvider);

    return collegesAsync.when(
      data: (colleges) {
        if (colleges.isEmpty) return Center(child: Text(l10n.pleaseSelectCollege));
        return ListView.builder(
          itemCount: colleges.length,
          itemBuilder: (context, index) {
            final college = colleges[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(college.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Code: ${college.code} | Departments: ${college.departments.length}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  setState(() {
                    _selectedCollege = college;
                    _searchQuery = '';
                  });
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('${l10n.error}: $err')),
    );
  }

  Widget _buildProgramsView(AppLocalizations l10n) {
    final allPrograms = _selectedCollege!.programs;
    final filteredPrograms = allPrograms.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Lightweight Selected College Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          child: Row(
            children: [
              Text('${l10n.selectedCollegeText} ', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
              Text(_selectedCollege!.name, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              labelText: l10n.searchPrograms,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: filteredPrograms.isEmpty
              ? Center(child: Text(l10n.pleaseSelectProgram))
              : ListView.builder(
                  itemCount: filteredPrograms.length,
                  itemBuilder: (context, index) {
                    final prog = filteredPrograms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            _selectedProgram = prog;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prog.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: Text('${l10n.programCodeLabel}: ${prog.code}')),
                                  Expanded(child: Text('${l10n.degreeType}: ${prog.degreeType}')),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${l10n.studyDurationLabel}: ${prog.durationYears} ${l10n.years}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStudyPlanView(AppLocalizations l10n, List<CourseModel> programCourses, AsyncValue<List<CourseModel>> coursesAsync) {
    return Column(
      children: [
        // Lightweight Selected Program Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_selectedProgram!.name, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text('${l10n.degreeType}: ${_selectedProgram!.degreeType} | ${l10n.studyDurationLabel}: ${_selectedProgram!.durationYears} ${l10n.years}', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 13)),
            ],
          ),
        ),
        // Courses List grouped by level
        Expanded(
          child: coursesAsync.when(
            data: (_) {
              if (programCourses.isEmpty) {
                return Center(child: Text(l10n.noCoursesCurrently, style: const TextStyle(fontSize: 16)));
              }

              // Group by semesterLevel
              final grouped = <int, List<CourseModel>>{};
              for (final c in programCourses) {
                grouped.putIfAbsent(c.semesterLevel, () => []).add(c);
              }
              final levels = grouped.keys.toList()..sort();

              return ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  final courses = grouped[level]!..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text('${l10n.semesterLevel} $level',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      ),
                      ...courses.map((course) => Card(
                            color: course.isArchived ? Colors.grey[300] : null,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              title: Text('${course.courseName} (${course.courseCode})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${l10n.creditHours}: ${course.creditHours} | ${course.isArchived ? "ARCHIVED" : "ACTIVE"}\n${l10n.prerequisites}: ${course.prerequisites.isEmpty ? "-" : course.prerequisites.map((e) => e.courseCode).join(', ')}',
                                style: TextStyle(color: course.isArchived ? Colors.red : Colors.grey[700]),
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showCourseDialog(context, ref, course, programCourses, l10n),
                                  ),
                                  if (course.isArchived)
                                    IconButton(
                                      icon: const Icon(Icons.restore, color: Colors.green),
                                      onPressed: () => ref.read(coursesNotifierProvider.notifier).restoreCourse(course.id),
                                    )
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.archive, color: Colors.orange),
                                      onPressed: () => _confirmArchive(context, ref, course),
                                    ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('${l10n.error}: $err')),
          ),
        ),
      ],
    );
  }

  void _confirmArchive(BuildContext context, WidgetRef ref, CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Course'),
        content: Text('Are you sure you want to archive ${course.courseName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(coursesNotifierProvider.notifier).archiveCourse(course.id);
              Navigator.pop(context);
            },
            child: const Text('Archive', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showCourseDialog(BuildContext context, WidgetRef ref, CourseModel? course, List<CourseModel> programCourses, AppLocalizations l10n) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: course?.courseName);
    final codeCtrl = TextEditingController(text: course?.courseCode);
    final creditsCtrl = TextEditingController(text: course?.creditHours.toString() ?? '3');
    final levelCtrl = TextEditingController(text: course?.semesterLevel.toString() ?? '1');

    Set<int> selectedPrereqIds = course?.prerequisites.map((e) => e.id).toSet() ?? {};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(course == null ? 'New Course' : 'Edit Course', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 600, // wider dialog
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Section 1
                        Text(l10n.academicDetails, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: TextFormField(
                              controller: nameCtrl,
                              decoration: InputDecoration(labelText: l10n.courseName, border: const OutlineInputBorder()),
                              validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال اسم المادة' : null,
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(
                              controller: codeCtrl,
                              decoration: InputDecoration(labelText: l10n.courseCode, border: const OutlineInputBorder()),
                              validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال رمز المادة' : null,
                            )),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Section 2
                        Text(l10n.studyPlanDetails, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: TextFormField(
                              controller: creditsCtrl,
                              decoration: InputDecoration(labelText: l10n.creditHours, border: const OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'مطلوب';
                                if (int.tryParse(v) == null || int.parse(v) <= 0) return 'قيمة غير صالحة';
                                return null;
                              },
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(
                              controller: levelCtrl,
                              decoration: InputDecoration(labelText: l10n.semesterLevel, border: const OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'مطلوب';
                                if (int.tryParse(v) == null || int.parse(v) <= 0) return 'قيمة غير صالحة';
                                return null;
                              },
                            )),
                          ],
                        ),
                        const SizedBox(height: 24),

                      // Section 3
                      Text(l10n.prerequisites, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                      const Divider(),
                      const SizedBox(height: 8),
                      programCourses.isEmpty || (programCourses.length == 1 && programCourses.first.id == course?.id)
                          ? const Text('لا توجد مواد سابقة متاحة كمتطلب.')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: programCourses.where((c) => c.id != course?.id).map((c) {
                                final isSelected = selectedPrereqIds.contains(c.id);
                                return FilterChip(
                                  label: Text('${c.courseName} (${c.courseCode})'),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setStateDialog(() {
                                      if (selected) {
                                        selectedPrereqIds.add(c.id);
                                      } else {
                                        selectedPrereqIds.remove(c.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final prereqIds = selectedPrereqIds.toList();

                    int calculatedOrder = 0;
                    if (course == null) {
                       final level = int.tryParse(levelCtrl.text) ?? 1;
                       final levelCourses = programCourses.where((c) => c.semesterLevel == level);
                       if (levelCourses.isNotEmpty) {
                          calculatedOrder = levelCourses.map((c) => c.orderIndex).reduce((a, b) => a > b ? a : b) + 1;
                       }
                    } else {
                       calculatedOrder = course.orderIndex;
                    }

                    final data = {
                      'course_name': nameCtrl.text,
                      'course_code': codeCtrl.text,
                      'credit_hours': int.tryParse(creditsCtrl.text) ?? 3,
                      'semester_level': int.tryParse(levelCtrl.text) ?? 1,
                      'order_index': calculatedOrder,
                      'prerequisites': prereqIds,
                      if (course == null) 'program_id': _selectedProgram!.id,
                    };

                    if (course == null) {
                      ref.read(coursesNotifierProvider.notifier).createCourse(data);
                    } else {
                      ref.read(coursesNotifierProvider.notifier).updateCourse(course.id, data);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
