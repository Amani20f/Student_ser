import 'package:flutter/material.dart';
import '../utils/status_helper.dart';

class StatusBadge extends StatelessWidget {
  final String label;

  const StatusBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = StatusHelper.getColor(label, cs);
    final localizedLabel = StatusHelper.localize(context, label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(80), width: 1),
      ),
      child: Text(
        localizedLabel,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
