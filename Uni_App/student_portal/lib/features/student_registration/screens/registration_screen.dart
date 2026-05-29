import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/registration_success_dialog.dart';
import 'package:university_app/features/student_registration/cubit/registration_cubit.dart';
import 'package:university_app/features/student_registration/widgets/academic_desires_step.dart';
import 'package:university_app/features/student_registration/widgets/academic_qualifications_step.dart';
import 'package:university_app/features/student_registration/widgets/contact_step.dart';
import 'package:university_app/features/student_registration/widgets/declaration_step.dart';

import 'package:university_app/features/student_registration/widgets/guardian_info_step.dart';
import 'package:university_app/features/student_registration/widgets/marketing_step.dart';
import 'package:university_app/features/student_registration/widgets/personal_info_step.dart';
import 'package:university_app/l10n/app_localizations.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationCubit(),
      child: const RegistrationView(),
    );
  }
}

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  late List<GlobalKey<FormState>> _formKeys;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // 6 steps with forms, 7th step (Declaration) has manual validation
    _formKeys = List.generate(6, (_) => GlobalKey<FormState>());
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRegistrationWarningDialog();
    });
  }

  void _showRegistrationWarningDialog() {
    if (!mounted) return;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.warning,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              content: Text(
                l10n.registrationFeeWarning,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.ok,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newStudentRegistration),
        centerTitle: true,
      ),
      body: BlocConsumer<RegistrationCubit, RegistrationState>(
        listener: (context, state) {
          // Auto-scroll to current step
          if (_scrollController.hasClients) {
            // Simple calculation: assumes roughly 80px per item + 30px separator
            // A better approach would be to calculate exact offsets or use a specialized package
            // But this heuristic works for basic centering
            final double offset = state.currentStep * 100.0;
            _scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }

          if (state.status == RegistrationStatus.success) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RegistrationSuccessDialog(
                title: l10n.registrationSuccessful,
                onOkPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to login
                },
              ),
            );
          } else if (state.status == RegistrationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                _buildStepHeader(context, state, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // Retrieve the step index from the ValueKey
                          // We use the animation status to determine if entering or exiting
                          // In a standard AnimatedSwitcher, sliding based on animation status
                          // gives a nice predictable slide-in/slide-out effect without tracking previous State.

                          final isRTL =
                              Directionality.of(context) == TextDirection.rtl;
                          final offsetDx = isRTL ? -1.0 : 1.0;

                          // We use the animation status to determine if entering or exiting
                          final isEntering =
                              animation.status == AnimationStatus.forward ||
                              animation.status == AnimationStatus.completed;

                          // Determine offset based on whether it's entering or exiting
                          // Without knowing previous step definitively, this is an approximation:
                          Offset beginOffset = Offset(
                            isEntering ? offsetDx : -offsetDx,
                            0.0,
                          );

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: beginOffset,
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<int>(state.currentStep),
                          child: _getStepContent(state.currentStep),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildControls(context, state, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepHeader(
    BuildContext context,
    RegistrationState state,
    AppLocalizations l10n,
  ) {
    final steps = _getStepTitles(l10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        // Removed the hard shadow/card color block
      ),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: steps.length,
        separatorBuilder: (context, index) {
          final isCompleted = index < state.currentStep;
          return Center(
            child: Container(
              width: 30,
              height: 2, // Explicit height
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.orange
                    : (isDark ? Colors.grey[700] : Colors.grey[400]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final isCompleted = index < state.currentStep;
          final isCurrent = index == state.currentStep;
          final color = isCompleted || isCurrent
              ? const Color.fromRGBO(255, 152, 0, 1)
              : (isDark ? Colors.grey[400] : Colors.grey[700]);

          return GestureDetector(
            onTap: () {
              if (index <= state.currentStep) {
                context.read<RegistrationCubit>().jumpToStep(index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isCurrent ? 40 : 32,
                    height: isCurrent ? 40 : 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent
                          ? color
                          : Colors.transparent,
                      border: Border.all(color: color!, width: 2),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCompleted || isCurrent
                                    ? Colors.white
                                    : color,
                                fontWeight: FontWeight.bold,
                                fontSize: isCurrent ? 16 : 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[index],
                    style: TextStyle(
                      color: isCurrent
                          ? (isDark ? Colors.white : Colors.black)
                          : color,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: isCurrent ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    RegistrationState state,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: (state.currentStep == 6 && !state.data.declarationChecked)
                  ? null
                  : () {
                      bool isValid = true;
                      if (state.currentStep < 6) {
                        isValid = _formKeys[state.currentStep].currentState?.validate() ?? true;
                      } else {
                        if (!state.data.declarationChecked) {
                          isValid = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.declarationText)));
                        } else if (state.data.signaturePath == null) {
                          isValid = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.signature)));
                        }
                      }

                      if (isValid) {
                        if (state.currentStep == 6) {
                          context.read<RegistrationCubit>().submitRegistration();
                        } else {
                          context.read<RegistrationCubit>().nextStep();
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(state.currentStep == 6 ? l10n.submit : l10n.next),
            ),
          ),
          if (state.currentStep > 0) ...[
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<RegistrationCubit>().previousStep();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.previous),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _getStepTitles(AppLocalizations l10n) {
    return [
      l10n.stepPersonalInfo,
      // Employment Step merged into Personal Info
      l10n.stepAcademic,
      l10n.stepDesires,
      l10n.stepContact,
      l10n.stepGuardian,
      l10n.stepMarketing,
      l10n.stepDeclaration,
    ];
  }

  Widget _getStepContent(int step) {
    switch (step) {
      case 0:
        return PersonalInfoStep(formKey: _formKeys[0]);
      case 1:
        return AcademicQualificationsStep(formKey: _formKeys[1]);
      case 2:
        return AcademicDesiresStep(formKey: _formKeys[2]);
      case 3:
        return ContactStep(formKey: _formKeys[3]);
      case 4:
        return GuardianInfoStep(formKey: _formKeys[4]);
      case 5:
        return MarketingStep(formKey: _formKeys[5]);
      case 6:
        return const DeclarationStep();
      default:
        return const SizedBox.shrink();
    }
  }
}
