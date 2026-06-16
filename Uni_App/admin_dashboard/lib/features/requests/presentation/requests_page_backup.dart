import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/requests_provider.dart';
import '../../../core/providers/back_action_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/utils/status_helper.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  bool _showAdvancedFilters = false;

  void _updateBackAction(WidgetRef ref) {
    final filters = ref.read(requestFiltersProvider);

    if (filters.isNotEmpty) {
      ref.read(backActionProvider.notifier).state = () {
        ref.read(requestFiltersProvider.notifier).state = {};
      };
    } else {
      ref.read(backActionProvider.notifier).state = null;
    }
  }

  Widget _buildFilters(ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
    final filters = ref.watch(requestFiltersProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        children: [
          // Row 1
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchStudentPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (val) {
                    ref.read(requestFiltersProvider.notifier).state = {
                      ...filters,
                      'search': val,
                    };
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.statusColumn,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  initialValue: filters['status'] as String?,
                  items: [
                    const DropdownMenuItem(
                        value: '___all___', child: Text('الكل')),
                    DropdownMenuItem(
                        value: 'pending',
                        child: Text(StatusHelper.localize(context, 'pending'))),
                    DropdownMenuItem(
                        value: 'approved',
                        child:
                            Text(StatusHelper.localize(context, 'approved'))),
                    DropdownMenuItem(
                        value: 'ratified',
                        child:
                            Text(StatusHelper.localize(context, 'ratified'))),
                    DropdownMenuItem(
                        value: 'rejected',
                        child:
                            Text(StatusHelper.localize(context, 'rejected'))),
                  ],
                  onChanged: (val) {
                    ref.read(requestFiltersProvider.notifier).state = {
                      ...filters,
                      'status': val,
                    };
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: l10n.requestTypeLabel,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  initialValue: filters['request_type_id'] as int?,
                  items: [
                    DropdownMenuItem(value: -1, child: Text('الكل')),
                    DropdownMenuItem(value: 1, child: Text(l10n.absenceExcuse)),
                    DropdownMenuItem(
                        value: 2, child: Text(l10n.studyPostponement)),
                    DropdownMenuItem(value: 3, child: Text(l10n.reEnrollment)),
                    DropdownMenuItem(value: 4, child: Text(l10n.gradeAppeal)),
                  ],
                  onChanged: (val) {
                    ref.read(requestFiltersProvider.notifier).state = {
                      ...filters,
                      'request_type_id': val,
                    };
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                    _showAdvancedFilters ? Icons.tune : Icons.tune_outlined),
                tooltip: l10n.advancedFilterTooltip,
                color: _showAdvancedFilters ? cs.primary : null,
                onPressed: () => setState(
                    () => _showAdvancedFilters = !_showAdvancedFilters),
              ),
            ],
          ),

          if (_showAdvancedFilters) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: l10n.specializationLabel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    initialValue: filters['program_id'] as int?,
                    items: [
                      DropdownMenuItem(value: -1, child: Text('الكل')),
                      DropdownMenuItem(
                          value: 1, child: Text(l10n.computerScience)),
                      DropdownMenuItem(
                          value: 2, child: Text(l10n.electricalEngineering)),
                      DropdownMenuItem(
                          value: 3, child: Text(l10n.businessAdministration)),
                    ],
                    onChanged: (val) {
                      ref.read(requestFiltersProvider.notifier).state = {
                        ...filters,
                        'program_id': val,
                      };
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: l10n.academicLevelLabel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    initialValue: filters['current_level'] as int?,
                    items: List.generate(
                        8,
                        (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text(l10n.levelNumber(index + 1)),
                            ))
                      ..insert(
                          0,
                          const DropdownMenuItem(
                              value: -1, child: Text('الكل'))),
                    onChanged: (val) {
                      ref.read(requestFiltersProvider.notifier).state = {
                        ...filters,
                        'current_level': val,
                      };
                    },
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () {
                    ref.read(requestFiltersProvider.notifier).state = {};
                    setState(() => _showAdvancedFilters = false);
                  },
                  icon: const Icon(Icons.clear_all),
                  label: Text(l10n.clearFilters),
                  style: TextButton.styleFrom(foregroundColor: cs.error),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(allRequestsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    ref.listen(requestFiltersProvider, (_, __) => _updateBackAction(ref));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Area
        _buildFilters(cs, tt, l10n),

        // List
        Expanded(
          child: requestsAsync.when(
            loading: () =>
                Center(child: CircularProgressIndicator(color: cs.primary)),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: cs.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.failedToLoadRequestsExt(error.toString()),
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withAlpha(140),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(allRequestsProvider),
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
                      l10n.totalRequests(requests.length),
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  if (requests.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              color: cs.onSurface.withAlpha(100),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.selectFiltersToSearch,
                              textAlign: TextAlign.center,
                              style: tt.titleMedium?.copyWith(
                                  color: cs.onSurface.withAlpha(140)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          return _RequestCard(request: requests[index])
                              .animate()
                              .fadeIn(duration: 400.ms, delay: (60 * index).ms)
                              .slideY(begin: 0.05, end: 0, duration: 400.ms);
                        },
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

class _RequestCard extends ConsumerStatefulWidget {
  final dynamic request;

  const _RequestCard({required this.request});

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _expanded = false;
  final _adminNotesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _adminNotesController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(String status) async {
    final cs = Theme.of(context).colorScheme;

    if (status == 'rejected' && _adminNotesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ملاحظات الإدارة مطلوبة في حالة الرفض'),
          backgroundColor: cs.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(requestRepositoryProvider);
      await repo.updateStatus(
        widget.request.id,
        status,
        _adminNotesController.text.trim(),
      );
      _adminNotesController.clear();
      ref.invalidate(allRequestsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved' ? 'تم قبول الطلب بنجاح' : 'تم رفض الطلب',
            ),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: cs.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStatusBadge(String status, ColorScheme cs, TextTheme tt) {
    return StatusBadge(label: status);
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isAdmin = ref.watch(authProvider).primaryRole == 'admin';
    final isPending = req.status == 'pending';
    final isRatified = req.status == 'ratified';
    final userRole = ref.watch(authProvider).primaryRole;
    final isAccountant = userRole == 'accountant';
    final isStudentAffairs = userRole == 'student_affairs';

    bool canTakeAction = false;
    if (!isAdmin) {
      if (req.requestTypeSlug == 'suspension_of_enrollment') {
        if (isAccountant && isPending) canTakeAction = true;
        if (isStudentAffairs && isRatified) canTakeAction = true;
      } else {
        if (isPending) canTakeAction = true;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Name
                Text(
                  req.studentName ?? 'طالب غير معروف',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Request Type & Reference
                Row(
                  children: [
                    Text(
                      req.requestType ?? 'طلب عام',
                      style: tt.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (req.id != null) ...[
                      const Spacer(),
                      Text(
                        '#S2026${req.id.toString().padLeft(4, '0')}',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withAlpha(150),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 8),

                // Specialization - Level
                if (req.programName != null || req.level != null)
                  Text(
                    '${req.programName ?? ""} ${req.level != null ? "- المستوى ${req.level}" : ""}',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withAlpha(180),
                    ),
                  ),

                // Description
                if (req.description != null && req.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    req.description!,
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Date & Status
                Row(
                  children: [
                    Text(
                      req.createdAt != null ? req.createdAt!.split(' ')[0] : '',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withAlpha(140),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildStatusBadge(req.status ?? 'pending', cs, tt),
                  ],
                ),

                // Quick Actions
                if (canTakeAction) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handleAction('approved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('قبول'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handleAction('rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('رفض'),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        icon: Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more),
                        label:
                            Text(_expanded ? 'إخفاء التفاصيل' : 'عرض التفاصيل'),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more),
                      label:
                          Text(_expanded ? 'إخفاء التفاصيل' : 'عرض التفاصيل'),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Expanded Details Area
          if (_expanded) ...[
            Divider(height: 1, color: cs.outlineVariant.withAlpha(40)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Data Fields
                  if (req.formData != null && req.formData!.isNotEmpty) ...[
                    Text(
                      'بيانات الطلب الإضافية:',
                      style:
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...req.formData!.entries.map((entry) {
                      final key = entry.key;
                      final value = entry.value?.toString() ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$key: ',
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                value,
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withAlpha(160),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Attachments
                  if (req.attachment != null && req.attachment!.isNotEmpty) ...[
                    Text(
                      'المرفقات:',
                      style:
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: req.attachment!.entries.map((entry) {
                        final fileUrl =
                            '${ApiConstants.baseUrl.replaceFirst('/api', '')}/storage/${entry.value}';
                        return ActionChip(
                          avatar: Icon(Icons.attach_file,
                              size: 16, color: cs.primary),
                          label: Text(
                            entry.key,
                            style: tt.bodySmall?.copyWith(color: cs.primary),
                          ),
                          backgroundColor: cs.primary.withAlpha(20),
                          side: BorderSide(color: cs.primary.withAlpha(60)),
                          onPressed: () async {
                            final uri = Uri.parse(fileUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Absence Records
                  if (req.absenceExcuse != null &&
                      req.absenceExcuse!['items'] != null) ...[
                    Text(
                      'سجلات الغياب:',
                      style:
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...(req.absenceExcuse!['items'] as List)
                        .map((item) => Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: cs.outlineVariant.withAlpha(30)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['course_name']?.toString() ??
                                          'مقرر غير معروف',
                                      style: tt.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    'بعذر: ${item['prev_excused_count'] ?? 0} | بدون عذر: ${item['prev_unexcused_count'] ?? 0}',
                                    style: tt.bodySmall?.copyWith(
                                        color: cs.onSurface.withAlpha(150)),
                                  ),
                                ],
                              ),
                            )),
                    const SizedBox(height: 12),
                  ],

                  // Action Form
                  if (canTakeAction) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _adminNotesController,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات الإدارة',
                        hintText: 'أدخل سبب الرفض أو ملاحظات القبول (إن وجدت)',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
