import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/utils/status_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admissions/presentation/application_details_dialog.dart';
import '../../payments/providers/payments_provider.dart';
import '../providers/requests_provider.dart';
import '../providers/unified_requests_provider.dart';
import '../data/unified_request_model.dart';

class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  final _searchController = TextEditingController();
  String _selectedStatus = '';
  String _selectedType = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(unifiedFiltersProvider.notifier).state = {
      'search': _searchController.text,
      'status': _selectedStatus,
      'request_type': _selectedType,
    };
  }

  Widget _buildFilters(ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchStudentPlaceholder,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(width: 12),

          // Status Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.statusColumn,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              initialValue: _selectedStatus,
              items: [
                const DropdownMenuItem(value: '', child: Text('الكل')),
                DropdownMenuItem(value: 'pending', child: Text(StatusHelper.localize(context, 'pending'))),
                DropdownMenuItem(value: 'approved', child: Text(StatusHelper.localize(context, 'approved'))),
                DropdownMenuItem(value: 'rejected', child: Text(StatusHelper.localize(context, 'rejected'))),
                DropdownMenuItem(value: 'ratified', child: Text(StatusHelper.localize(context, 'ratified'))),
                DropdownMenuItem(value: 'paid', child: Text(StatusHelper.localize(context, 'paid'))),
                DropdownMenuItem(value: 'under_review', child: Text(StatusHelper.localize(context, 'under_review'))),
                DropdownMenuItem(value: 'verified', child: Text(StatusHelper.localize(context, 'verified'))),
                DropdownMenuItem(value: 'completed', child: Text(StatusHelper.localize(context, 'completed'))),
              ],
              onChanged: (val) {
                setState(() => _selectedStatus = val ?? '');
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Request Type Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.requestTypeLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              initialValue: _selectedType,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('الكل')),
                DropdownMenuItem(value: 'student_application', child: Text('طلب قبول')),
                DropdownMenuItem(value: 'appeal', child: Text('تظلم درجة')),
                DropdownMenuItem(value: 'payment', child: Text('طلب دفع مالي')),
                DropdownMenuItem(value: 'absence_excuse', child: Text('عذر غياب')),
                DropdownMenuItem(value: 'suspension_of_enrollment', child: Text('تأجيل دراسة')),
                DropdownMenuItem(value: 're_enrollment', child: Text('إعادة قيد')),
                DropdownMenuItem(value: 'other_request', child: Text('طلب خدمات عامة')),
              ],
              onChanged: (val) {
                setState(() => _selectedType = val ?? 'all');
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 12),

          ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.filter_list),
            label: const Text('تصفية'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRowTap(UnifiedRequestModel item) async {
    if (item.originalType == 'student_application') {
      await showDialog(
        context: context,
        builder: (context) => ApplicationDetailsDialog(applicationId: item.id),
      );
      ref.invalidate(unifiedRequestsListProvider);
    } else if (item.originalType == 'appeal') {
      context.go('/appeals/${item.id}');
    } else if (item.originalType == 'payment') {
      _showPaymentDetailsDialog(item);
    } else {
      _showServiceRequestDetailsDialog(item);
    }
  }

  void _showPaymentDetailsDialog(UnifiedRequestModel item) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final details = item.details;
    final isPending = item.status == 'pending';
    final isAdmin = ref.read(authProvider).primaryRole == 'admin';

    showDialog(
      context: context,
      builder: (dialogContext) {
        final notesController = TextEditingController();
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> processPayment(String action) async {
              final messenger = ScaffoldMessenger.of(context);
              setState(() => isSubmitting = true);
              try {
                final repo = ref.read(paymentRepositoryProvider);
                if (action == 'approve') {
                  await repo.verifyPayment(item.id);
                } else {
                  if (notesController.text.trim().isEmpty) {
                    messenger.showSnackBar(
                      SnackBar(content: const Text('ملاحظات الرفض مطلوبة'), backgroundColor: cs.error),
                    );
                    setState(() => isSubmitting = false);
                    return;
                  }
                  await repo.rejectPayment(item.id, notesController.text.trim());
                }

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(action == 'approve' ? 'تم تأكيد الدفع بنجاح' : 'تم رفض الدفع'),
                      backgroundColor: action == 'approve' ? Colors.green : Colors.red,
                    ),
                  );
                  ref.invalidate(unifiedRequestsListProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('خطأ: $e'), backgroundColor: cs.error),
                  );
                }
              } finally {
                setState(() => isSubmitting = false);
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('تفاصيل طلب الدفع المالي', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(dialogContext)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildInfoRow('اسم الطالب', item.studentName),
                      _buildInfoRow('المبلغ', '\$${details['amount']}'),
                      _buildInfoRow('الغرض من الدفع', details['purpose'] ?? '—'),
                      _buildInfoRow('الفصل الدراسي', details['semester_display'] ?? '—'),
                      _buildInfoRow('الحالة', StatusHelper.localize(context, item.status)),
                      _buildInfoRow('تاريخ التقديم', item.submittedDate),
                      if (details['rejection_reason'] != null)
                        _buildInfoRow('سبب الرفض', details['rejection_reason'], color: cs.error),
                      const SizedBox(height: 16),

                      // Receipt image
                      if (details['receipt_image'] != null) ...[
                        Text('إيصال الدفع:', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            details['receipt_image'] as String,
                            fit: BoxFit.contain,
                            height: 250,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('فشل تحميل صورة الإيصال'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(details['receipt_image'] as String);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('فتح الإيصال في نافذة جديدة'),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (isPending && !isAdmin) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظات الإدارة / سبب الرفض',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        if (isSubmitting)
                          const Center(child: CircularProgressIndicator())
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => processPayment('reject'),
                                style: OutlinedButton.styleFrom(foregroundColor: cs.error, side: BorderSide(color: cs.error)),
                                child: const Text('رفض الدفع'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => processPayment('approve'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text('تأكيد وقبول الدفع'),
                              ),
                            ],
                          )
                      ]
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showServiceRequestDetailsDialog(UnifiedRequestModel item) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final details = item.details;
    final isPending = item.status == 'pending' || item.status == 'ratified';
    final isAdmin = ref.read(authProvider).primaryRole == 'admin';

    showDialog(
      context: context,
      builder: (dialogContext) {
        final notesController = TextEditingController();
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> processRequest(String actionStatus) async {
              final messenger = ScaffoldMessenger.of(context);
              if (actionStatus == 'rejected' && notesController.text.trim().isEmpty) {
                messenger.showSnackBar(
                  SnackBar(content: const Text('ملاحظات الإدارة مطلوبة في حالة الرفض'), backgroundColor: cs.error),
                );
                return;
              }

              setState(() => isSubmitting = true);
              try {
                final repo = ref.read(requestRepositoryProvider);
                await repo.updateStatus(
                  item.id,
                  actionStatus,
                  notesController.text.trim(),
                );

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(actionStatus == 'approved' ? 'تم قبول الطلب بنجاح' : 'تم رفض الطلب'),
                      backgroundColor: actionStatus == 'approved' ? Colors.green : Colors.red,
                    ),
                  );
                  ref.invalidate(unifiedRequestsListProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('خطأ: $e'), backgroundColor: cs.error),
                  );
                }
              } finally {
                setState(() => isSubmitting = false);
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                width: 700,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('تفاصيل الطلب: ${item.requestType}', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(dialogContext)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildInfoRow('اسم الطالب', item.studentName),
                      _buildInfoRow('البرنامج الدراسي', details['program_name'] ?? '—'),
                      if (details['level'] != null)
                        _buildInfoRow('المستوى الأكاديمي', 'المستوى ${details['level']}'),
                      _buildInfoRow('نوع الطلب', item.requestType),
                      _buildInfoRow('حالة الطلب', StatusHelper.localize(context, item.status)),
                      _buildInfoRow('تاريخ التقديم', item.submittedDate),
                      if (details['description'] != null && (details['description'] as String).isNotEmpty)
                        _buildInfoRow('الوصف والسبب', details['description']),
                      const SizedBox(height: 16),

                      // Form Data Fields
                      if (details['form_data'] != null && (details['form_data'] as Map).isNotEmpty) ...[
                        Text('بيانات الطلب الإضافية:', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...(details['form_data'] as Map).entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(child: Text(entry.value?.toString() ?? '—')),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Attachments
                      if (details['attachment'] != null && (details['attachment'] as Map).isNotEmpty) ...[
                        Text('المرفقات:', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (details['attachment'] as Map).entries.map((entry) {
                            final fileUrl = '${ApiConstants.baseUrl.replaceFirst('/api', '')}/storage/${entry.value}';
                            return ActionChip(
                              avatar: Icon(Icons.attach_file, size: 16, color: cs.primary),
                              label: Text(entry.key.toString(), style: TextStyle(color: cs.primary)),
                              backgroundColor: cs.primary.withAlpha(20),
                              onPressed: () async {
                                final uri = Uri.parse(fileUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Absence Record
                      if (details['absence_excuse'] != null) ...[
                        Text('سجلات الغياب والمقررات ذات العذر:', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildInfoRow('السنة الأكاديمية', details['absence_excuse']['academic_year'] ?? '—'),
                        _buildInfoRow('الفصل الدراسي', details['absence_excuse']['semester'] ?? '—'),
                        _buildInfoRow('السبب الرئيس', details['absence_excuse']['reason'] ?? '—'),
                        const SizedBox(height: 8),
                        if (details['absence_excuse']['items'] != null)
                          ...(details['absence_excuse']['items'] as List).map((excuseItem) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cs.outlineVariant.withAlpha(30)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      excuseItem['course_name']?.toString() ?? 'مقرر غير معروف',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    'بعذر: ${excuseItem['prev_excused_count'] ?? 0} | بدون عذر: ${excuseItem['prev_unexcused_count'] ?? 0}',
                                    style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(150)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 16),
                      ],

                      if (isPending && !isAdmin) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظات الإدارة',
                            hintText: 'أدخل سبب الرفض أو ملاحظات القبول (مطلوب عند الرفض)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        if (isSubmitting)
                          const Center(child: CircularProgressIndicator())
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => processRequest('rejected'),
                                style: OutlinedButton.styleFrom(foregroundColor: cs.error, side: BorderSide(color: cs.error)),
                                child: const Text('رفض الطلب'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => processRequest('approved'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text('موافقة وقبول'),
                              ),
                            ],
                          )
                      ]
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(unifiedRequestsListProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilters(cs, tt, l10n),
        Expanded(
          child: requestsAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: cs.primary)),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: cs.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'فشل تحميل الطلبات الموحدة: $error',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface.withAlpha(140)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(unifiedRequestsListProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (requests) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'إجمالي الطلبات الموحدة: ${requests.length}',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                  ),
                  if (requests.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_rounded, color: Colors.grey, size: 64),
                            SizedBox(height: 16),
                            Text('لا توجد طلبات مطابقة للمعايير المحددة.', textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: cs.outlineVariant.withAlpha(60)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 32,
                                columns: const [
                                  DataColumn(label: Text('نوع الطلب (Request Type)')),
                                  DataColumn(label: Text('اسم الطالب (Student Name)')),
                                  DataColumn(label: Text('تاريخ التقديم (Submitted Date)')),
                                  DataColumn(label: Text('الحالة (Status)')),
                                  DataColumn(label: Text('تفاصيل (Action)')),
                                ],
                                rows: requests.map((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(item.requestType, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(item.studentName)),
                                      DataCell(Text(item.submittedDate)),
                                      DataCell(StatusBadge(label: item.status)),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(Icons.open_in_new, color: cs.primary),
                                          onPressed: () => _handleRowTap(item),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
