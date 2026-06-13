import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:university_app/l10n/app_localizations.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/modern_text_field.dart';
import 'login_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _inputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _verifyIdentity() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      try {
        final email = _inputController.text.trim();
        if (!email.contains('@')) {
          throw Exception(
            'الرجاء إدخال البريد الإلكتروني لإرسال رابط تعيين كلمة المرور',
          );
        }
        await context.read<AuthRepository>().forgotPassword(email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني بنجاح',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e
                  .toString()
                  .replaceAll('Exception:', '')
                  .replaceAll('ApiException:', '')
                  .trim(),
            ),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        title: Text(l10n.forgotPasswordTitle),
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ).animate().scale(
                  delay: 150.ms,
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.forgotPasswordDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 40),
                ModernTextField(
                  label: l10n.emailOrIdLabel,
                  prefixIcon: Icons.badge_rounded,
                  controller: _inputController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.requiredField;
                    }
                    final val = value.trim();
                    // If it is entirely numbers, it must be an ID of 10 digits
                    if (RegExp(r'^[0-9]+$').hasMatch(val)) {
                      if (val.length != 10) {
                        return 'رقم الهوية يجب أن يتكون من 10 أرقام';
                      }
                    } else {
                      // Otherwise it must be a valid email
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(val)) {
                        return 'البريد الإلكتروني غير صحيح';
                      }
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyIdentity,
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
                          l10n.verifyIdentityButton,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
