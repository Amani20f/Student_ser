import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/providers/back_action_provider.dart';
import '../providers/payments_provider.dart';
import '../data/payment_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/filter_definition.dart';
import '../../../core/widgets/filter_bar.dart';

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(allPaymentsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(authProvider).primaryRole == 'admin';

    // Listen for filter changes to update global back action
    ref.listen(paymentFiltersProvider, (_, __) => _updateBackAction(ref));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar (always visible)
          _buildFilterBar(ref, cs, tt, l10n),
          const SizedBox(height: 24),

          // Content
          Expanded(
            child: paymentsAsync.when(
              loading: () =>
                  Center(child: CircularProgressIndicator(color: cs.primary)),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: cs.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.failedToLoadPayments}: $error',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withAlpha(140),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(allPaymentsProvider),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (payments) {
                final filters = ref.watch(paymentFiltersProvider);
                final hasActiveFilter = filters.values.any(
                    (value) => value != null && value.toString().isNotEmpty);

                if (!hasActiveFilter) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: cs.primary.withAlpha(100),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'الرجاء اختيار الفلترة لعرض البيانات',
                          style: tt.titleMedium?.copyWith(
                            color: cs.onSurface.withAlpha(140),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (payments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: cs.primary, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noPendingPayments,
                          style: tt.titleMedium?.copyWith(
                            color: cs.onSurface.withAlpha(140),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cs.outlineVariant.withAlpha(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withAlpha(8),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: DataTable(
                            columnSpacing: 28,
                            horizontalMargin: 24,
                            columns: [
                              DataColumn(label: Text(l10n.studentColumn)),
                              DataColumn(label: Text(l10n.amountColumn)),
                              DataColumn(label: Text(l10n.purposeColumn)),
                              DataColumn(label: Text(l10n.semesterColumn)),
                              DataColumn(label: Text(l10n.statusColumn)),
                              DataColumn(label: Text(l10n.receiptColumn)),
                              if (!isAdmin)
                                DataColumn(label: Text(l10n.actionsColumn)),
                            ],
                            rows: payments
                                .map((p) => _buildRow(context, ref, p, isAdmin))
                                .toList(),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.05, end: 0, duration: 400.ms),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
      WidgetRef ref, ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
    return FilterBar(
      filters: [
        FilterDefinition(
          id: 'status',
          label: l10n.statusColumn,
          type: FilterType.dropdown,
          icon: Icons.info_outline,
          options: const [
            FilterValue(label: 'Pending', value: 'pending'),
            FilterValue(label: 'Verified', value: 'verified'),
            FilterValue(label: 'Rejected', value: 'rejected'),
          ],
        ),
        const FilterDefinition(
          id: 'program_id',
          label: 'Specialization',
          type: FilterType.dropdown,
          icon: Icons.school_outlined,
          options: [
            FilterValue(label: 'Computer Science', value: 1),
            FilterValue(label: 'Electrical Engineering', value: 2),
            FilterValue(label: 'Business Administration', value: 3),
          ],
        ),
        const FilterDefinition(
          id: 'current_level',
          label: 'Academic Level',
          type: FilterType.dropdown,
          icon: Icons.layers_outlined,
          options: [
            FilterValue(label: 'Level 1', value: 1),
            FilterValue(label: 'Level 2', value: 2),
            FilterValue(label: 'Level 3', value: 3),
            FilterValue(label: 'Level 4', value: 4),
            FilterValue(label: 'Level 5', value: 5),
            FilterValue(label: 'Level 6', value: 6),
            FilterValue(label: 'Level 7', value: 7),
            FilterValue(label: 'Level 8', value: 8),
          ],
        ),
        const FilterDefinition(
          id: 'search',
          label: 'Search Student',
          type: FilterType.text,
          icon: Icons.person_search_outlined,
        ),
        FilterDefinition(
          id: 'created_at',
          label: l10n.allTime,
          type: FilterType.dateRange,
          icon: Icons.calendar_month_outlined,
        ),
      ],
      currentValues: ref.watch(paymentFiltersProvider),
      onFilterChanged: (id, value) {
        final current = ref.read(paymentFiltersProvider);
        ref.read(paymentFiltersProvider.notifier).state = {
          ...current,
          id: value,
        };
      },
      onClearAll: () {
        ref.read(paymentFiltersProvider.notifier).state = {};
      },
    );
  }

  DataRow _buildRow(
      BuildContext context, WidgetRef ref, PaymentModel payment, bool isAdmin) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isPending = payment.status == 'pending';

    return DataRow(
      cells: [
        DataCell(Text(payment.studentName ?? l10n.notApplicable)),
        DataCell(Text('\$${payment.amount.toStringAsFixed(2)}')),
        DataCell(Text(payment.purpose ?? '—',
            style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(160)))),
        DataCell(Text(payment.semesterDisplay)),
        DataCell(StatusBadge(label: payment.status ?? 'pending')),
        DataCell(
          payment.receiptImage != null
              ? InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () =>
                      _showReceiptDialog(context, payment.receiptImage!),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long, color: cs.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        l10n.view,
                        style: tt.bodySmall?.copyWith(color: cs.primary),
                      ),
                    ],
                  ),
                )
              : Text(
                  l10n.notApplicable,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withAlpha(120),
                  ),
                ),
        ),
        if (!isAdmin)
          DataCell(
            isPending
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            color: Colors.green),
                        tooltip: l10n.verify,
                        onPressed: () =>
                            _confirmApproval(context, ref, payment),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.orange),
                        tooltip: l10n.reject,
                        onPressed: () =>
                            _showRejectDialog(context, ref, payment),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }

  void _confirmApproval(
      BuildContext context, WidgetRef ref, PaymentModel payment) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.verify),
        content: Text(l10n.confirmApprovePayment),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processPayment(context, ref, payment, 'approve');
            },
            child: Text(l10n.approve),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, WidgetRef ref, PaymentModel payment) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectPayment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.confirmRejectPayment),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.reasonForRejection,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              await _processPayment(context, ref, payment, 'reject',
                  notes: controller.text);
            },
            child: Text(l10n.reject),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(
      BuildContext context, WidgetRef ref, PaymentModel payment, String action,
      {String? notes}) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(paymentRepositoryProvider);

    try {
      if (action == 'approve') {
        await repo.verifyPayment(payment.id);
      } else {
        await repo.rejectPayment(payment.id, notes!);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'approve'
                ? l10n.paymentVerifiedSuccess
                : l10n.paymentRejected),
            backgroundColor: action == 'approve' ? Colors.green : Colors.orange,
          ),
        );
        ref.invalidate(allPaymentsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showReceiptDialog(BuildContext context, String imageUrl) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.receiptPreview,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: cs.onSurface.withAlpha(140)),
                  ),
                ],
              ),
              Divider(color: cs.outlineVariant.withAlpha(40)),
              Flexible(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: cs.onSurface.withAlpha(100),
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.failedToLoadReceipt,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurface.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateBackAction(WidgetRef ref) {
    final filters = ref.read(paymentFiltersProvider);

    if (filters.isNotEmpty) {
      ref.read(backActionProvider.notifier).state = () {
        ref.read(paymentFiltersProvider.notifier).state = {};
      };
    } else {
      ref.read(backActionProvider.notifier).state = null;
    }
  }
}
