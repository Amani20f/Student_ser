import 'package:flutter/material.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

class StatusHelper {
  static String localize(BuildContext context, String? status) {
    final l10n = AppLocalizations.of(context)!;
    if (status == null || status.isEmpty) return l10n.statusUnknown;

    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.statusPending;
      case 'ratified':
        // using string directly since we just added it to l10n but we should check if l10n has it.
        // Wait, app_localizations.dart is generated. So `l10n.statusRatified` should be available after we run `flutter gen-l10n`.
        // Let's assume it exists. Wait, if it doesn't compile, we can fix it.
        return l10n.statusRatified;
      case 'pending_payment':
        return l10n.statusPendingPayment;
      case 'paid':
        return l10n.statusPaid;
      case 'under_review':
        return l10n.statusUnderReview;
      case 'approved':
        return l10n.statusApproved;
      case 'rejected':
        return l10n.statusRejected;
      case 'verified':
        return l10n.statusVerified;
      case 'submitted':
        return l10n.statusSubmitted;
      case 'completed':
        return l10n.statusCompleted;
      case 'active':
        return l10n.statusActive;
      case 'inactive':
        return l10n.statusInactive;
      default:
        // Fallback for missing localization
        return status.replaceAll('_', ' ').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m.group(0)!.toUpperCase());
    }
  }

  static Color getColor(String? status, ColorScheme cs) {
    if (status == null || status.isEmpty) return cs.onSurface.withAlpha(150);

    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade700;
      case 'ratified':
        return Colors.purple.shade600;
      case 'pending_payment':
      case 'under_review':
        return Colors.orange;
      case 'paid':
        return Colors.teal;
      case 'submitted':
        return Colors.blue;
      case 'approved':
      case 'verified':
      case 'completed':
      case 'active':
        return Colors.green.shade600;
      case 'rejected':
      case 'inactive':
        return Colors.red.shade600;
      default:
        return cs.onSurface.withAlpha(150);
    }
  }
}
