import 'package:flutter/material.dart';

enum FilterType { text, dropdown, dateRange }

class FilterValue {
  final String label;
  final dynamic value;

  const FilterValue({required this.label, required this.value});
}

class FilterDefinition {
  final String id;
  final String label;
  final FilterType type;
  final List<FilterValue>? options;
  final String? hint;
  final IconData? icon;

  const FilterDefinition({
    required this.id,
    required this.label,
    required this.type,
    this.options,
    this.hint,
    this.icon,
  });
}
