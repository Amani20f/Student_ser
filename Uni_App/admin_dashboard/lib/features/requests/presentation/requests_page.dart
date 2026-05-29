import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/requests_provider.dart';
import '../../../core/providers/back_action_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/filter_definition.dart';
import '../../../core/widgets/filter_bar.dart';

class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
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

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(allRequestsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Listen for filter changes to update global back action
    ref.listen(requestFiltersProvider, (_, __) => _updateBackAction(ref));

    return Column(
      children: [
        // Title Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Text(
                l10n.serviceRequests,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),

        // Filter Bar
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: FilterBar(
            filters: [
              FilterDefinition(
                id: 'status',
                label: l10n.statusColumn,
                type: FilterType.dropdown,
                icon: Icons.info_outline,
                options: const [
                  FilterValue(label: 'Pending', value: 'pending'),
                  FilterValue(label: 'Approved', value: 'approved'),
                  FilterValue(label: 'Rejected', value: 'rejected'),
                ],
              ),
              const FilterDefinition(
                id: 'request_type_id',
                label: 'Request Type',
                type: FilterType.dropdown,
                icon: Icons.category_outlined,
                options: [
                  FilterValue(label: 'Absence Excuse', value: 1),
                  FilterValue(label: 'Study Deferral', value: 2),
                  FilterValue(label: 'Re-enrollment', value: 3),
                  FilterValue(label: 'Grade Appeal', value: 4),
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
                label: 'Student Name/Card',
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
            currentValues: ref.watch(requestFiltersProvider),
            onFilterChanged: (id, value) {
              final current = ref.read(requestFiltersProvider);
              ref.read(requestFiltersProvider.notifier).state = {
                ...current,
                id: value,
              };
            },
            onClearAll: () {
              ref.read(requestFiltersProvider.notifier).state = {};
            },
          ),
        ),

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
                    '${l10n.failedToLoadRequests}: $error',
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
              final filters = ref.watch(requestFiltersProvider);
              final hasActiveFilter = filters.values
                  .any((value) => value != null && value.toString().isNotEmpty);
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

              if (requests.isEmpty) {
                return Center(
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
                        l10n.noPendingRequests,
                        style: tt.titleMedium?.copyWith(
                          color: cs.onSurface.withAlpha(140),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return _RequestCard(request: requests[index])
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (60 * index).ms)
                      .slideY(begin: 0.05, end: 0, duration: 400.ms);
                },
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
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (status == 'rejected' && _adminNotesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adminNotesRequired),
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
              status == 'approved'
                  ? l10n.requestApproved
                  : l10n.requestRejected,
            ),
            backgroundColor: status == 'approved' ? cs.primary : cs.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error(e.toString())),
            backgroundColor: cs.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(authProvider).primaryRole == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        req.studentName ?? l10n.unknownStudent,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    StatusBadge(label: req.status ?? 'pending'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        req.requestType ?? l10n.general,
                        style: tt.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (req.studentNumber != null)
                      Text(
                        '#${req.studentNumber}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withAlpha(150),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      req.createdAt ?? '',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withAlpha(120),
                      ),
                    ),
                  ],
                ),
                if (req.programName != null || req.level != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${req.programName ?? ""} • Level ${req.level ?? ""}',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withAlpha(140),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (req.description != null && req.description!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    req.description!,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withAlpha(160),
                    ),
                  ),
                ],
                if (req.formData != null && req.formData!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ...req.formData!.entries.map((entry) {
                    final key = entry.key;
                    final value = entry.value?.toString() ?? '';
                    // Format key nicely (e.g. "academic_year" -> "Academic Year")
                    final displayKey = key.split('_').map((word) {
                      if (word.isEmpty) return '';
                      return word[0].toUpperCase() +
                          word.substring(1).toLowerCase();
                    }).join(' ');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$displayKey: ',
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
                ],
                if (req.attachment != null && req.attachment!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
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
                ],

                // Absence Excuse Items
                if (req.absenceExcuse != null &&
                    req.absenceExcuse!['items'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Absence Records:',
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
                                        'Unknown Course',
                                    style: tt.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  'Excused: ${item['prev_excused_count'] ?? 0} | Unexcused: ${item['prev_unexcused_count'] ?? 0}',
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurface.withAlpha(150)),
                                ),
                              ],
                            ),
                          )),
                ],
                const SizedBox(height: 10),
                if (!isAdmin)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more,
                            color: cs.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _expanded ? l10n.hideActions : l10n.takeAction,
                            style: tt.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Expandable action area
          if (_expanded) ...[
            Divider(height: 1, color: cs.outlineVariant.withAlpha(40)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _adminNotesController,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.adminNotesLabel,
                      hintText: l10n.enterAdminNotes,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handleAction('rejected'),
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(l10n.reject),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handleAction('approved'),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(l10n.approve),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
