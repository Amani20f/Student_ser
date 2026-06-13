import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../../core/providers/back_action_provider.dart';
import '../data/log_model.dart';
import '../providers/logs_provider.dart';


/// Fixed action list — includes dynamic ones + user management events.
const _knownActions = [
  'user_created',
  'user_deleted',
  'request_approved',
  'request_rejected',
  'payment_verified',
  'payment_rejected',
  'grade_updated',
  'login',
  'logout',
];

class LogsPage extends ConsumerStatefulWidget {
  const LogsPage({super.key});

  @override
  ConsumerState<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends ConsumerState<LogsPage> {
  String? _filterAction;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _hasFetched = false;
  List<LogModel>? _logs;
  bool _loading = false;
  String? _error;

  DateTime? get _fromDate => _dateFrom;
  DateTime? get _toDate => _dateTo != null
      ? DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day, 23, 59, 59)
      : null;

  Future<void> _fetchLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(logRepositoryProvider);
      final result = await repo.getLogs(
        action: _filterAction == '___all___' ? null : _filterAction,
        from: _fromDate,
        to: _toDate,
      );
      setState(() {
        _logs = result;
        _hasFetched = true;
        ref.read(backActionProvider.notifier).state = _clearFilters;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clearFilters() {
    if (!mounted) return;
    setState(() {
      _filterAction = null;
      _dateFrom = null;
      _dateTo = null;
      _logs = null;
      _hasFetched = false;
      ref.read(backActionProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter bar ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.outlineVariant.withAlpha(40)),
            boxShadow: [
              BoxShadow(color: cs.shadow.withAlpha(6), blurRadius: 12, offset: const Offset(0, 2)),
            ],
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.filter_list_rounded, color: cs.primary, size: 20),
              // Time period
              _filterChip(
                cs, tt,
                label: l10n.timePeriod,
                child: InkWell(
                  onTap: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: (_dateFrom != null && _dateTo != null)
                          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
                          : null,
                    );
                    if (picked != null) {
                      setState(() {
                        _dateFrom = picked.start;
                        _dateTo = picked.end;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      (_dateFrom != null && _dateTo != null)
                          ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year} - ${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
                          : 'Select Date Range',
                      style: tt.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              // Action filter
              _filterChip(
                cs, tt,
                label: l10n.actionColumn,
                child: DropdownButton<String?>(
                  value: _filterAction,
                  underline: const SizedBox(),
                  dropdownColor: cs.surface,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  hint: Text(l10n.actionColumn,
                    style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(140))),
                  items: [
                    DropdownMenuItem<String?>(value: '___all___', child: Text(l10n.allActions)),
                    ..._knownActions.map((a) => DropdownMenuItem(value: a, child: Text(a))),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _filterAction = v;
                    });
                  },
                ),
              ),
              // Apply button
              FilledButton.icon(
                onPressed: _loading ? null : _fetchLogs,
                icon: _loading
                    ? SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
                    : const Icon(Icons.search_rounded, size: 18),
                label: Text(l10n.applyFilters),
              ),
              // Clear button
              if (_hasFetched)
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 18),
                  label: Text(l10n.clearFilters),
                ),
              if (_logs != null)
                Text(
                  l10n.entriesCount(_logs!.length),
                  style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(120)),
                ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
        const SizedBox(height: 24),

        // ── Content area ───────────────────────────────────────────────────
        Expanded(
          child: _buildContent(cs, tt, l10n),
        ),
      ],
    );
  }

  Widget _buildContent(ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
    if (!_hasFetched && _logs == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, color: cs.primary.withAlpha(80), size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.selectFiltersToSearch,
              style: tt.titleMedium?.copyWith(color: cs.onSurface.withAlpha(140)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 48),
            const SizedBox(height: 16),
            Text('${l10n.failedToLoadLogs}: $_error',
                style: tt.bodyMedium?.copyWith(color: cs.onSurface.withAlpha(140))),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: _fetchLogs, icon: const Icon(Icons.refresh), label: Text(l10n.retry)),
          ],
        ),
      );
    }

    final logs = _logs ?? [];
    if (logs.isEmpty) {
      return Center(child: Text(l10n.noLogsFound,
          style: tt.titleMedium?.copyWith(color: cs.onSurface.withAlpha(120))));
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outlineVariant.withAlpha(40)),
          boxShadow: [BoxShadow(color: cs.shadow.withAlpha(8), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 20,
              columns: [
                DataColumn(label: Text(l10n.userColumn)),
                DataColumn(label: Text(l10n.actionColumn)),
                DataColumn(label: Text(l10n.modelColumn)),
                DataColumn(label: Text(l10n.oldValuesColumn)),
                DataColumn(label: Text(l10n.newValuesColumn)),
                DataColumn(label: Text(l10n.dateColumn)),
              ],
              rows: logs.map((l) => _buildRow(context, l)).toList(),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
    );
  }

  DataRow _buildRow(BuildContext context, LogModel log) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final isUserEvent = log.action == 'user_created' || log.action == 'user_deleted';
    final badgeColor = isUserEvent ? cs.tertiary : cs.primary;

    return DataRow(cells: [
      DataCell(Text(log.causer ?? l10n.system)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(log.action ?? '-',
              style: tt.bodySmall?.copyWith(color: badgeColor, fontWeight: FontWeight.w500)),
        ),
      ),
      DataCell(Text(log.subjectType ?? '-')),
      DataCell(ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Tooltip(
          message: log.oldValuesDisplay,
          child: Text(log.oldValuesDisplay,
              overflow: TextOverflow.ellipsis,
              style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(120))),
        ),
      )),
      DataCell(ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Tooltip(
          message: log.newValuesDisplay,
          child: Text(log.newValuesDisplay,
              overflow: TextOverflow.ellipsis,
              style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(120))),
        ),
      )),
      DataCell(Text(log.createdAt ?? '-',
          style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(120)))),
    ]);
  }

  Widget _filterChip(ColorScheme cs, TextTheme tt, {required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(160))),
          child,
        ],
      ),
    );
  }
}
