import 'package:flutter/material.dart';
import 'package:university_app/l10n/app_localizations.dart';
import '../../home/main_screen.dart';
import 'login_screen.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/animated_success_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool isMandatory;
  const ChangePasswordScreen({super.key, this.isMandatory = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMandatory = widget.isMandatory;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
        title: Text(AppLocalizations.of(context)!.changePasswordTitle),
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  [
                      Text(
                        AppLocalizations.of(context)!.changePasswordDescription,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ModernTextField(
                        label: 'كلمة المرور الحالية',
                        prefixIcon: Icons.lock_open_outlined,
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _currentPassController,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'مطلوب';
                          if (val.length < 6) return 'يجب ألا تقل عن 6 رموز';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        label: AppLocalizations.of(context)!.newPassword,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passController,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'مطلوب';
                          if (val.length < 8) return 'يجب ألا تقل عن 8 رموز';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        label: AppLocalizations.of(context)!.confirmPassword,
                        prefixIcon: Icons.lock_reset,
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'مطلوب';
                          if (val != _passController.text) return 'كلمات المرور غير متطابقة';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) return;
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await context.read<AuthCubit>().changePassword(
                              _currentPassController.text,
                              _passController.text,
                            );
                            if (!mounted) return;
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierLabel: '',
                              barrierColor: Colors.black.withValues(alpha: 0.5),
                              pageBuilder: (context, anim1, anim2) {
                                return AnimatedSuccessDialog(
                                  title: AppLocalizations.of(
                                    context,
                                  )!.passwordChangedSuccess,
                                  onOkPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    if (isMandatory) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    } else {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString().replaceAll('Exception:', '').replaceAll('ApiException:', '').trim()),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          shadowColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.updatePasswordButton,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                      if (isMandatory) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.mandatoryPasswordNotice,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.black87,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ]
                    .animate(interval: 80.ms)
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.2, end: 0),
            ),
          ),
        ),
      ),
    );
  }
}
