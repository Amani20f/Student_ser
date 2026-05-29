import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../models/filter_definition.dart';

class FilterBar extends ConsumerWidget {
  final List<FilterDefinition> filters;
  final Map<String, dynamic> currentValues;
  final Function(String id, dynamic value) onFilterChanged;
  final VoidCallback onClearAll;

  const FilterBar({
    super.key,
    required this.filters,
    required this.currentValues,
    required this.onFilterChanged,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(Icons.filter_list_rounded, color: cs.primary, size: 20),
          ...filters.map((f) => _buildFilterItem(context, f)),
          if (currentValues.values.any((v) => v != null && v != ''))
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: Text(l10n.clearFilters),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(BuildContext context, FilterDefinition filter) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    switch (filter.type) {
      case FilterType.text:
        return SizedBox(
          width: 200,
          child: TextField(
            onChanged: (v) => onFilterChanged(filter.id, v.isEmpty ? null : v),
            decoration: InputDecoration(
              isDense: true,
              hintText: filter.label,
              prefixIcon: Icon(filter.icon ?? Icons.search_rounded, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        );
      case FilterType.dropdown:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withAlpha(40)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (filter.icon != null) ...[
                Icon(filter.icon, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
              ],
              Text('${filter.label}: ',
                  style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(160))),
              DropdownButtonHideUnderline(
                child: DropdownButton<dynamic>(
                  value: currentValues[filter.id],
                  dropdownColor: cs.surface,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...(filter.options ?? []).map((o) => DropdownMenuItem(
                          value: o.value,
                          child: Text(o.label),
                        )),
                  ],
                  onChanged: (v) => onFilterChanged(filter.id, v),
                ),
              ),
            ],
          ),
        );
      case FilterType.dateRange:
        return OutlinedButton.icon(
          onPressed: () => _selectDateRange(context, filter.id),
          icon: const Icon(Icons.date_range_rounded, size: 18),
          label: Text(
            currentValues[filter.id] ?? filter.label,
            style: tt.bodySmall,
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        );
    }
  }

  Future<void> _selectDateRange(BuildContext context, String id) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onFilterChanged('${id}_from', picked.start.toIso8601String().split('T')[0]);
      onFilterChanged('${id}_to', picked.end.toIso8601String().split('T')[0]);
      onFilterChanged(id, '${picked.start.toIso8601String().split('T')[0]} - ${picked.end.toIso8601String().split('T')[0]}');
    }
  }
}
