import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StepContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;

  const StepContainer({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
        const SizedBox(height: 24),
        // Details/Content
        child.animate().fadeIn(
          duration: 350.ms,
          curve: Curves.easeInOut,
        ), // Simpler animation
      ],
    );
  }
}
