import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/widgets/modern_text_field.dart';
import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/student_registration/widgets/step_container.dart';

class GuardianInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const GuardianInfoStep({required this.formKey, super.key});

  @override
  State<GuardianInfoStep> createState() => _GuardianInfoStepState();
}

class _GuardianInfoStepState extends State<GuardianInfoStep> {
  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _occupationController;
  late TextEditingController _mobileController;
  late TextEditingController _landlineController;

  @override
  void initState() {
    super.initState();
    final data = context.read<RegistrationCubit>().state.data;
    _nameController = TextEditingController(text: data.guardianName);
    _relationshipController = TextEditingController(
      text: data.guardianRelationship,
    );
    _occupationController = TextEditingController(
      text: data.guardianOccupation,
    );
    _mobileController = TextEditingController(text: data.guardianMobile);
    _landlineController = TextEditingController(text: data.guardianLandline);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _occupationController.dispose();
    _mobileController.dispose();
    _landlineController.dispose();
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
          title: l10n.guardianInfo,
          icon: Icons.supervisor_account_rounded,
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                ModernTextField(
                  label: l10n.guardianName,
                  prefixIcon: Icons.person_rounded,
                  controller: _nameController,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(guardianName: value),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.relationship,
                  prefixIcon: Icons.family_restroom_rounded,
                  controller: _relationshipController,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(guardianRelationship: value),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.guardianOccupation,
                  prefixIcon: Icons.work_rounded,
                  controller: _occupationController,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(guardianOccupation: value),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.mobileNumber,
                  prefixIcon: Icons.phone_android_rounded,
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(guardianMobile: value),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.requiredField;
                    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) return 'رقم الجوال غير صحيح (8 إلى 15 رقماً)';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.landline,
                  prefixIcon: Icons.phone_rounded,
                  controller: _landlineController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(guardianLandline: value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
