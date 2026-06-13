import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:university_app/core/network/api_client.dart';
import 'package:university_app/core/data/academic_repository.dart';
import 'package:university_app/core/widgets/modern_dropdown_field.dart';

import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';
import 'package:university_app/features/student_registration/models/registration_data.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/student_registration/widgets/step_container.dart';

class AcademicDesiresStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const AcademicDesiresStep({required this.formKey, super.key});

  @override
  State<AcademicDesiresStep> createState() => _AcademicDesiresStepState();
}

class _AcademicDesiresStepState extends State<AcademicDesiresStep> {
  List<CollegeModel> _colleges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAcademicData();
  }

  Future<void> _loadAcademicData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiClient = ApiClient(prefs);
      final repository = AcademicRepository(apiClient);
      final colleges = await repository.getColleges();
      
      if (mounted) {
        setState(() {
          _colleges = colleges;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load academic data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RegistrationCubit>();

    return BlocBuilder<RegistrationCubit, RegistrationState>(
      buildWhen: (previous, current) =>
          previous.data.academicDesires != current.data.academicDesires,
      builder: (context, state) {
        return StepContainer(
          title: l10n.stepDesires,
          icon: Icons.star_rounded,
          child: _isLoading 
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))
              : Form(
                  key: widget.formKey,
                  child: Column(
                    children: [
                      for (int i = 0; i < 3; i++)
                        _buildDesireItem(
                          context,
                          cubit,
                          state.data.academicDesires[i],
                          i,
                          l10n,
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDesireItem(
    BuildContext context,
    RegistrationCubit cubit,
    AcademicDesire desire,
    int index,
    AppLocalizations l10n,
  ) {
    String title;
    switch (index) {
      case 0:
        title = l10n.academicDesire1;
        break;
      case 1:
        title = l10n.academicDesire2;
        break;
      case 2:
        title = l10n.academicDesire3;
        break;
      default:
        title = '';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter available programs based on selected college
    List<ProgramModel> availablePrograms = [];
    if (desire.college != null) {
      final college = _colleges.firstWhere(
        (c) => c.id == desire.college!.id, 
        orElse: () => _colleges.first,
      );
      // Flatten all programs across departments
      for (var dept in college.departments) {
        availablePrograms.addAll(dept.programs);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModernDropdownField<CollegeModel>(
            label: l10n.college,
            prefixIcon: Icons.apartment_rounded,
            value: desire.college,
            items: _colleges
                .map(
                  (c) => DropdownMenuItem<CollegeModel>(
                    value: c,
                    child: Text(c.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              final newDesires = List<AcademicDesire>.from(
                cubit.state.data.academicDesires,
              );
              // Reset major when college changes
              newDesires[index] = desire.copyWith(college: value, major: null);
              cubit.updateData(
                cubit.state.data.copyWith(academicDesires: newDesires),
              );
            },
            validator: (value) {
              if (value == null) return l10n.requiredField;
              return null;
            },
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          ModernDropdownField<ProgramModel>(
            label: l10n.majorValue,
            prefixIcon: Icons.school_rounded,
            value: desire.major,
            items: availablePrograms
                .map(
                  (p) => DropdownMenuItem<ProgramModel>(
                    value: p,
                    child: Text(p.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              final newDesires = List<AcademicDesire>.from(
                cubit.state.data.academicDesires,
              );
              newDesires[index] = desire.copyWith(major: value);
              cubit.updateData(
                cubit.state.data.copyWith(academicDesires: newDesires),
              );
            },
            validator: (value) {
              if (value == null) return l10n.requiredField;
              return null;
            },
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          ModernDropdownField<DegreeLevel>(
            label: l10n.degreeLevel,
            prefixIcon: Icons.workspace_premium_rounded,
            value: desire.degreeLevel,
            items: [
              DropdownMenuItem(
                value: DegreeLevel.bachelor,
                child: Text(l10n.bachelor),
              ),
              DropdownMenuItem(
                value: DegreeLevel.diploma,
                child: Text(l10n.diploma),
              ),
            ],
            onChanged: (value) {
              final newDesires = List<AcademicDesire>.from(
                cubit.state.data.academicDesires,
              );
              newDesires[index] = desire.copyWith(degreeLevel: value);
              cubit.updateData(
                cubit.state.data.copyWith(academicDesires: newDesires),
              );
            },
            validator: (value) {
              if (value == null) return l10n.requiredField;
              return null;
            },
          ),
        ],
      ),
    );
  }
}
