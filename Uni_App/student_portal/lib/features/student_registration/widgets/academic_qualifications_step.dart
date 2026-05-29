import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/widgets/modern_text_field.dart';
import 'package:university_app/core/widgets/modern_dropdown_field.dart';
import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/student_registration/widgets/step_container.dart';

class AcademicQualificationsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const AcademicQualificationsStep({required this.formKey, super.key});

  @override
  State<AcademicQualificationsStep> createState() =>
      _AcademicQualificationsStepState();
}

class _AcademicQualificationsStepState
    extends State<AcademicQualificationsStep> {
  // late TextEditingController _majorController; // Removed as it is now a dropdown
  late TextEditingController _seatNumberController;
  late TextEditingController _gradeController;
  late TextEditingController _yearController;
  late TextEditingController _locationController;
  late TextEditingController _awardingBodyController;

  @override
  void initState() {
    super.initState();
    final data = context.read<RegistrationCubit>().state.data;
    // _majorController = TextEditingController(text: data.previousMajor); // Removed as it is now a dropdown
    _seatNumberController = TextEditingController(text: data.seatNumber);
    _gradeController = TextEditingController(
      text: data.gradePercentage?.toString() ?? '',
    );
    _yearController = TextEditingController(text: data.graduationYear);
    _locationController = TextEditingController(text: data.graduationLocation);
    _awardingBodyController = TextEditingController(text: data.awardingBody);
  }

  @override
  void dispose() {
    // _majorController.dispose(); // Removed as it is now a dropdown
    _seatNumberController.dispose();
    _gradeController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    _awardingBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RegistrationCubit>();

    return BlocBuilder<RegistrationCubit, RegistrationState>(
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        return StepContainer(
          title: l10n.academicInfo,
          icon: Icons.school_rounded,
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                ModernDropdownField<String>(
                  label: l10n.majorSpecialization,
                  prefixIcon: Icons.school_rounded,
                  value:
                      (state.data.previousMajor != null &&
                          state.data.previousMajor!.isNotEmpty &&
                          (state.data.previousMajor == 'Scientific' ||
                              state.data.previousMajor == 'Literary'))
                      ? state.data.previousMajor
                      : null,
                  items: [
                    DropdownMenuItem(
                      value: 'Scientific',
                      child: Text(l10n.scientific),
                    ),
                    DropdownMenuItem(
                      value: 'Literary',
                      child: Text(l10n.literary),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      cubit.updateData(
                        state.data.copyWith(previousMajor: value),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.seatNumber,
                  prefixIcon: Icons.confirmation_number_rounded,
                  controller: _seatNumberController,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(seatNumber: value)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.gradePercentage,
                  prefixIcon: Icons.percent_rounded,
                  keyboardType: TextInputType.number,
                  controller: _gradeController,
                  onChanged: (value) {
                    final grade = double.tryParse(value);
                    if (grade != null) {
                      cubit.updateData(
                        state.data.copyWith(gradePercentage: grade),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    if (double.tryParse(value) == null) return 'رقم غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.graduationYear,
                  prefixIcon: Icons.calendar_month_rounded,
                  keyboardType: TextInputType.number,
                  controller: _yearController,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(graduationYear: value),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.graduationLocation,
                  prefixIcon: Icons.location_on_rounded,
                  controller: _locationController,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(graduationLocation: value),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.awardingBody,
                  prefixIcon: Icons.account_balance_rounded,
                  controller: _awardingBodyController,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(awardingBody: value),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
