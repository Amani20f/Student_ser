import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;

  const StatusBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(cs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(80), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme cs) {
    switch (label.toLowerCase()) {
      case 'pending':
        return cs.secondary;
      case 'approved':
      case 'verified':
        return cs.primary;
      case 'paid':
        return Colors.teal;
      case 'under_review':
        return Colors.orange;
      case 'rejected':
        return cs.error;
      default:
        return cs.onSurface.withAlpha(150);
    }
  }
}
