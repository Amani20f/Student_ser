import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/widgets/modern_text_field.dart';
import 'package:university_app/core/widgets/modern_dropdown_field.dart';
import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';
import 'package:university_app/features/student_registration/models/registration_data.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/student_registration/widgets/step_container.dart';
import 'package:intl/intl.dart';

class PersonalInfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const PersonalInfoStep({required this.formKey, super.key});

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  late TextEditingController _fullNameArController;
  late TextEditingController _fullNameEnController;
  late TextEditingController _nationalityController;
  late TextEditingController _governorateController;
  late TextEditingController _districtController;
  late TextEditingController _dobController;
  late TextEditingController _jobTitleController;

  @override
  void initState() {
    super.initState();
    final data = context.read<RegistrationCubit>().state.data;
    _fullNameArController = TextEditingController(text: data.fullNameAr);
    _fullNameEnController = TextEditingController(text: data.fullNameEn);
    _nationalityController = TextEditingController(text: data.nationality);
    _governorateController = TextEditingController(text: data.governorate);
    _districtController = TextEditingController(text: data.district);
    _dobController = TextEditingController(
      text: data.dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(data.dateOfBirth!)
          : '',
    );
    _jobTitleController = TextEditingController(text: data.jobTitle);
  }

  @override
  void dispose() {
    _fullNameArController.dispose();
    _fullNameEnController.dispose();
    _nationalityController.dispose();
    _governorateController.dispose();
    _districtController.dispose();
    _dobController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final cubit = context.read<RegistrationCubit>();
    final initialDate = cubit.state.data.dateOfBirth ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      cubit.updateData(cubit.state.data.copyWith(dateOfBirth: picked));
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RegistrationCubit>();

    return BlocBuilder<RegistrationCubit, RegistrationState>(
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        return StepContainer(
          title: l10n.personalInfo,
          icon: Icons.person_rounded,
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                ModernTextField(
                  label: l10n.fullNameAr,
                  prefixIcon: Icons.person_rounded,
                  controller: _fullNameArController,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(fullNameAr: value)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'مطلوب';
                    if (!RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(value)) return 'يجب أن يحتوي على أحرف عربية فقط';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.fullNameEn,
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _fullNameEnController,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(fullNameEn: value)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'مطلوب';
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'يجب أن يحتوي على أحرف إنجليزية فقط';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernDropdownField<Gender>(
                  label: l10n.gender,
                  prefixIcon: Icons.male_rounded,
                  value: state.data.gender,
                  items: [
                    DropdownMenuItem(
                      value: Gender.male,
                      child: Text(l10n.male),
                    ),
                    DropdownMenuItem(
                      value: Gender.female,
                      child: Text(l10n.female),
                    ),
                  ],
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(gender: value)),
                  validator: (value) {
                    if (value == null) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernDropdownField<String>(
                  label: l10n.bloodType,
                  prefixIcon: Icons.bloodtype,
                  value: state.data.bloodType.isNotEmpty
                      ? state.data.bloodType
                      : null,
                  items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(bloodType: value)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.nationality,
                  prefixIcon: Icons.flag_rounded,
                  controller: _nationalityController,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(nationality: value)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernDropdownField<String>(
                  label: l10n.maritalStatus,
                  prefixIcon: Icons.family_restroom_rounded,
                  value: state.data.maritalStatus.isNotEmpty
                      ? state.data.maritalStatus
                      : null,
                  items: [
                    DropdownMenuItem(value: 'Single', child: Text(l10n.single)),
                    DropdownMenuItem(
                      value: 'Married',
                      child: Text(l10n.married),
                    ),
                    DropdownMenuItem(
                      value: 'Divorced',
                      child: Text(l10n.divorced),
                    ),
                    DropdownMenuItem(
                      value: 'Widowed',
                      child: Text(l10n.widowed),
                    ),
                  ],
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(maritalStatus: value),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: ModernTextField(
                      label: l10n.dateOfBirth,
                      prefixIcon: Icons.calendar_month_rounded,
                      controller: _dobController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'مطلوب';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.governorate,
                  prefixIcon: Icons.location_city_rounded,
                  controller: _governorateController,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(governorate: value)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.district,
                  prefixIcon: Icons.map_rounded,
                  controller: _districtController,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(district: value)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Documents Upload
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (state.data.certificatePath == null) {
                        cubit.updateData(
                          state.data.copyWith(
                            certificatePath: 'uploaded_doc.pdf',
                          ),
                        );
                      } else {
                        cubit.updateData(
                          state.data.copyWith(certificatePath: null),
                        );
                      }
                    },
                    icon: Icon(
                      state.data.certificatePath != null
                          ? Icons.check_circle_rounded
                          : Icons.upload_file,
                    ),
                    label: Text(l10n.uploadDocuments),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          state.data.certificatePath != null
                              ? Colors.green
                              : const Color(0xFF009688),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Photos Upload
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (state.data.profilePicturePath == null) {
                        cubit.updateData(
                          state.data.copyWith(
                            profilePicturePath: 'uploaded_photo.jpg',
                          ),
                        );
                      } else {
                        cubit.updateData(
                          state.data.copyWith(profilePicturePath: null),
                        );
                      }
                    },
                    icon: Icon(
                      state.data.profilePicturePath != null
                          ? Icons.check_circle_rounded
                          : Icons.add_photo_alternate_rounded,
                    ),
                    label: Text(l10n.uploadPhotos),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          state.data.profilePicturePath != null
                              ? Colors.green
                              : const Color(0xFF009688),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  thickness: 1.5,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade500,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.isEmployed),
                  value: state.data.isEmployed,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(isEmployed: value)),
                ),
                if (state.data.isEmployed) ...[
                  const SizedBox(height: 16),
                  ModernDropdownField<Sector>(
                    label: l10n.sector,
                    prefixIcon: Icons.business_rounded,
                    value: state.data.sector,
                    items: [
                      DropdownMenuItem(
                        value: Sector.government,
                        child: Text(l10n.government),
                      ),
                      DropdownMenuItem(
                        value: Sector.private,
                        child: Text(l10n.private),
                      ),
                    ],
                    onChanged: (value) =>
                        cubit.updateData(state.data.copyWith(sector: value)),
                    validator: (value) {
                      if (state.data.isEmployed && value == null) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ModernTextField(
                    label: l10n.jobTitle,
                    prefixIcon: Icons.work_rounded,
                    controller: _jobTitleController,
                    onChanged: (value) =>
                        cubit.updateData(state.data.copyWith(jobTitle: value)),
                    validator: (value) {
                      if (state.data.isEmployed &&
                          (value == null || value.isEmpty)) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
