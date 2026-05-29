import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'dart:ui';

class SupportDialog extends StatelessWidget {
  const SupportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child:
          Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.1,
                      ),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.headset_mic_rounded,
                          color: Colors.orange,
                          size: 36,
                        ),
                      ).animate().scale(
                        duration: 350.ms,
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 20),
                      Text(
                            AppLocalizations.of(
                              context,
                            )!.needHelp.replaceAll(': ', ''),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 150.ms)
                          .moveY(begin: 10, end: 0),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.supportMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 28),

                      // Contact Options
                      _buildContactOption(
                        context: context,
                        icon: Icons.phone_rounded,
                        title: AppLocalizations.of(context)!.phoneNumberLabel,
                        subtitle: '+967 77X XXX XXX',
                        color: Colors.blue,
                        delay: 300.ms,
                      ),
                      const SizedBox(height: 12),
                      _buildContactOption(
                        context: context,
                        icon: Icons.chat_bubble_rounded,
                        title: AppLocalizations.of(context)!.whatsappLabel,
                        subtitle: '+967 77X XXX XXX',
                        color: Colors.green,
                        delay: 350.ms,
                      ),
                      const SizedBox(height: 12),
                      _buildContactOption(
                        context: context,
                        icon: Icons.email_rounded,
                        title: AppLocalizations.of(context)!.emailLabel,
                        subtitle: 'support@university.edu',
                        color: Colors.redAccent,
                        delay: 400.ms,
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: theme
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              )
              .animate()
              .scale(
                duration: 300.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.8, 0.8),
              )
              .fadeIn(duration: 200.ms),
    );
  }

  Widget _buildContactOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Duration delay,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF333333) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.05,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}
