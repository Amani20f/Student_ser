import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/widgets/modern_dropdown_field.dart';

import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';
import 'package:university_app/features/student_registration/models/registration_data.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/student_registration/widgets/step_container.dart';

class AcademicDesiresStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const AcademicDesiresStep({required this.formKey, super.key});

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
          child: Form(
            key: formKey,
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
          ModernDropdownField<String>(
            label: l10n.college,
            prefixIcon: Icons.apartment_rounded,
            value: desire.college,
            items:
                <String>[
                      l10n.collegeIT,
                      l10n.collegeEngineering,
                      l10n.collegeBusiness,
                    ]
                    .map(
                      (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
            onChanged: (value) {
              final newDesires = List<AcademicDesire>.from(
                cubit.state.data.academicDesires,
              );
              newDesires[index] = desire.copyWith(college: value);
              cubit.updateData(
                cubit.state.data.copyWith(academicDesires: newDesires),
              );
            },
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.requiredField;
              return null;
            },
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          ModernDropdownField<String>(
            label: l10n.majorValue,
            prefixIcon: Icons.school_rounded,
            value: desire.major,
            items:
                <String>[
                      l10n.majorCS,
                      l10n.majorIT,
                      l10n.majorSE,
                      l10n.majorCE,
                      l10n.majorAccounting,
                    ]
                    .map(
                      (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
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
              if (value == null || value.isEmpty) return l10n.requiredField;
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
