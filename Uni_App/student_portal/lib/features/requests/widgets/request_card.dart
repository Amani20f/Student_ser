import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:university_app/features/requests/models/request_model.dart';

class RequestCard extends StatefulWidget {
  final RequestType request;
  final VoidCallback onTap;

  const RequestCard({super.key, required this.request, required this.onTap});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.request.accentColor ?? theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child:
          GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.identity()
                    ..translate(0.0, _isHovered ? -6.0 : 0.0, 0.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isHovered ? accentColor : theme.dividerColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered
                            ? accentColor.withValues(alpha: 0.18)
                            : theme.shadowColor.withOpacity(0.05),
                        blurRadius: _isHovered ? 22 : 10,
                        offset: Offset(0, _isHovered ? 10 : 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon circle with accent color
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? accentColor.withValues(alpha: 0.18)
                              : accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedScale(
                          scale: _isHovered ? 1.18 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            widget.request.icon,
                            size: 30,
                            color: _isHovered
                                ? accentColor
                                : accentColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.request.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.request.description,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تقديم',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: _isHovered
                                  ? accentColor
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: _isHovered
                                ? accentColor
                                : theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 200.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.1,
                end: 0,
                duration: 200.ms,
                curve: Curves.easeOutQuart,
              ),
    );
  }
}
