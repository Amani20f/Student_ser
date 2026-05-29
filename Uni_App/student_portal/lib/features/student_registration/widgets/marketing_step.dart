import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/core/widgets/modern_text_field.dart';
import 'package:university_app/core/widgets/modern_dropdown_field.dart';
import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';

import 'package:university_app/l10n/app_localizations.dart';
import 'package:university_app/features/student_registration/widgets/step_container.dart';

class MarketingStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const MarketingStep({required this.formKey, super.key});

  @override
  State<MarketingStep> createState() => _MarketingStepState();
}

class _MarketingStepState extends State<MarketingStep> {
  late TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    final data = context.read<RegistrationCubit>().state.data;
    _reasonController = TextEditingController(text: data.reasonForChoosing);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<RegistrationCubit>();

    // Mapping localization keys/values for simplicity. Ideally should be better structured.
    final List<String> marketingOptions = [
      l10n.friend,
      l10n.relative,
      l10n.teacher,
      l10n.universityStudent,
      l10n.facebook,
      l10n.instagram,
      l10n.twitter,
      l10n.radioTv,
      l10n.billboards,
    ];

    return BlocBuilder<RegistrationCubit, RegistrationState>(
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        return StepContainer(
          title:
              l10n.marketingInfo, // Ensure this key exists or use fallback/icon
          icon: Icons.poll_rounded,
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                ModernDropdownField<String>(
                  label: l10n.marketingQuestion,
                  prefixIcon: Icons.campaign_rounded,
                  value: marketingOptions.contains(state.data.marketingChannel)
                      ? state.data.marketingChannel
                      : null,
                  items: marketingOptions
                      .map(
                        (e) =>
                            DropdownMenuItem<String>(value: e, child: Text(e)),
                      )
                      .toList(),
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(marketingChannel: value),
                  ),
                  validator: (value) =>
                      value == null ? l10n.requiredField : null,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: l10n.reasonForChoosing,
                  prefixIcon: Icons.textsms_rounded,
                  controller: _reasonController,
                  onChanged: (value) => cubit.updateData(
                    state.data.copyWith(reasonForChoosing: value),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.requiredField;
                    }
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
