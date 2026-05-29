import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/widgets/modern_text_field.dart';
import 'package:university_app/core/widgets/modern_dropdown_field.dart';
import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';

import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/student_registration/widgets/step_container.dart';
import 'package:intl/intl.dart';

class ContactStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const ContactStep({required this.formKey, super.key});

  @override
  State<ContactStep> createState() => _ContactStepState();
}

class _ContactStepState extends State<ContactStep> {
  late TextEditingController _idNumberController;
  late TextEditingController _issuePlaceController;
  late TextEditingController _issueDateController;
  late TextEditingController _mobileController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _landlineController;

  @override
  void initState() {
    super.initState();
    final data = context.read<RegistrationCubit>().state.data;
    _idNumberController = TextEditingController(text: data.identityNumber);
    _issuePlaceController = TextEditingController(text: data.issuePlace);
    _issueDateController = TextEditingController(
      text: data.issueDate != null
          ? DateFormat('yyyy-MM-dd').format(data.issueDate!)
          : '',
    );
    _mobileController = TextEditingController(text: data.mobileNumber);
    _whatsappController = TextEditingController(text: data.whatsappNumber);
    _emailController = TextEditingController(text: data.email);
    _addressController = TextEditingController(text: data.homeAddress);
    _landlineController = TextEditingController(text: data.landline);
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _issuePlaceController.dispose();
    _issueDateController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _landlineController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final cubit = context.read<RegistrationCubit>();
    final initialDate = cubit.state.data.issueDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      cubit.updateData(cubit.state.data.copyWith(issueDate: picked));
      _issueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
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
          title: l10n
              .contactInfo, // Ensure this key exists or use localized string
          icon: Icons.contact_mail_rounded,
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernDropdownField<String>(
                  label: l10n.identityType,
                  prefixIcon: Icons.badge_rounded,
                  value: state.data.identityType,
                  items: ['National ID', 'Passport']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(identityType: value),
                  ),
                  validator: (value) =>
                      value == null ? l10n.requiredField : null,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.identityNumber,
                  prefixIcon: Icons.perm_identity_rounded,
                  controller: _idNumberController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(identityNumber: value),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.requiredField;
                    if (value.length < 5) return 'يجب ألا يقل عن 5 خانات';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.issuePlace,
                  prefixIcon: Icons.place_rounded,
                  controller: _issuePlaceController,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(issuePlace: value)),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: ModernTextField(
                      label: l10n.issueDate,
                      prefixIcon: Icons.calendar_month_rounded,
                      controller: _issueDateController,
                      validator: (value) => (value == null || value.isEmpty)
                          ? l10n.requiredField
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Divider(
                  thickness: 1.5,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade500,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.contactDetails, // Assuming key exists or use fallback
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.mobileNumber,
                  prefixIcon: Icons.phone_android_rounded,
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(mobileNumber: value),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.requiredField;
                    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) return 'رقم الجوال غير صحيح (8 إلى 15 رقماً)';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.whatsappNumber,
                  prefixIcon: Icons.message_rounded,
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(whatsappNumber: value),
                  ),
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.email,
                  prefixIcon: Icons.email_rounded,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(email: value)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.requiredField;
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return l10n.invalidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.homeAddress,
                  prefixIcon: Icons.home_rounded,
                  controller: _addressController,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(homeAddress: value)),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.landline,
                  prefixIcon: Icons.phone_rounded,
                  controller: _landlineController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) =>
                      cubit.updateData(state.data.copyWith(landline: value)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
