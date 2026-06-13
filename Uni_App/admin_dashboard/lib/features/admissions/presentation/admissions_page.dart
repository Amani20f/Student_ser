import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/utils/status_helper.dart';
import '../providers/admissions_provider.dart';
import 'application_details_dialog.dart';

class AdmissionsPage extends ConsumerStatefulWidget {
  const AdmissionsPage({super.key});

  @override
  ConsumerState<AdmissionsPage> createState() => _AdmissionsPageState();
}

class _AdmissionsPageState extends ConsumerState<AdmissionsPage> {
  final _searchController = TextEditingController();
  String _selectedStatus = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    if (_searchController.text.isNotEmpty) {
      filters['search'] = _searchController.text;
    }
    if (_selectedStatus.isNotEmpty) {
      filters['status'] = _selectedStatus;
    }
    ref.read(admissionsFiltersProvider.notifier).state = filters;
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(applicationsListProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top filters bar
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Name, National ID, or Application No...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: [
                  const DropdownMenuItem(value: '', child: Text('الكل')),
                  DropdownMenuItem(value: 'pending', child: Text(StatusHelper.localize(context, 'pending'))),
                  DropdownMenuItem(value: 'submitted', child: Text(StatusHelper.localize(context, 'submitted'))),
                  DropdownMenuItem(value: 'completed', child: Text(StatusHelper.localize(context, 'completed'))),
                  DropdownMenuItem(value: 'rejected', child: Text(StatusHelper.localize(context, 'rejected'))),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val ?? '';
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.filter_list),
              label: const Text('Filter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // List
        Expanded(
          child: applicationsAsync.when(
            data: (apps) {
              if (apps.isEmpty) {
                return Center(
                  child: Text(
                    'No applications found.',
                    style: tt.bodyLarge?.copyWith(color: cs.onSurface.withAlpha(150)),
                  ),
                );
              }

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant.withAlpha(60)),
                ),
                child: ListView.separated(
                  itemCount: apps.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: cs.outlineVariant.withAlpha(40)),
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      title: Text(
                        app.fullName,
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('App No: ${app.applicationNumber} | Program: ${app.desiredProgram ?? "N/A"}'),
                          Text('Submitted: ${app.submittedAt ?? "N/A"}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusBadge(context, app.status ?? ''),
                          const SizedBox(width: 16),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ApplicationDetailsDialog(applicationId: app.id),
                        );
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    return StatusBadge(label: status);
  }
}
