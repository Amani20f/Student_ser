import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../../core/utils/status_helper.dart';
import '../providers/appeals_provider.dart';
import '../data/appeal_model.dart';

class AppealsPage extends ConsumerWidget {
  const AppealsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final appealsAsync = ref.watch(underReviewAppealsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage and track all grade grievances and appeals from the database.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurface.withAlpha(150)),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          
          // Filter Bar
          _buildFilterBar(context, ref, cs, tt, l10n),
          const SizedBox(height: 24),

          Expanded(
            child: appealsAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: cs.primary)),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, color: cs.error, size: 64),
                    const SizedBox(height: 16),
                    Text('Failed to load appeals: $error'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(underReviewAppealsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (appeals) {
                if (appeals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grading_rounded,
                          color: cs.primary.withAlpha(40),
                          size: 80,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No appeals found for the selected filter.',
                          style: tt.titleMedium?.copyWith(
                            color: cs.onSurface.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: appeals.length,
                  itemBuilder: (context, index) {
                    final appeal = appeals[index];
                    return _AppealCard(appeal: appeal, index: index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
    final currentFilter = ref.watch(appealStatusFilterProvider);
    final isSelected = currentFilter != null && currentFilter != '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? cs.primary.withAlpha(20) : cs.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? cs.primary.withAlpha(50) : cs.outlineVariant.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list_rounded, color: isSelected ? cs.primary : cs.onSurfaceVariant, size: 20),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: isSelected ? currentFilter : null,
              hint: Text(l10n.statusColumn, style: tt.bodyMedium?.copyWith(color: cs.onSurface.withAlpha(180))),
              dropdownColor: cs.surface,
              style: tt.bodyMedium?.copyWith(color: isSelected ? cs.primary : cs.onSurface),
              items: [
                DropdownMenuItem(value: '___all___', child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الكل' : 'All')),
                DropdownMenuItem(value: 'pending_payment', child: Text(StatusHelper.localize(context, 'pending_payment'))),
                DropdownMenuItem(value: 'paid', child: Text(StatusHelper.localize(context, 'paid'))),
                DropdownMenuItem(value: 'under_review', child: Text(StatusHelper.localize(context, 'under_review'))),
                DropdownMenuItem(value: 'approved', child: Text(StatusHelper.localize(context, 'approved'))),
                DropdownMenuItem(value: 'rejected', child: Text(StatusHelper.localize(context, 'rejected'))),
              ],
              onChanged: (v) => ref.read(appealStatusFilterProvider.notifier).state = v,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18),
              onPressed: () => ref.read(appealStatusFilterProvider.notifier).state = null,
              tooltip: l10n.clearFilters,
            ),
          ],
        ],
      ),
    );
  }
}

class _AppealCard extends StatelessWidget {
  final AppealModel appeal;
  final int index;

  const _AppealCard({required this.appeal, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: InkWell(
        onTap: () => context.go('/appeals/${appeal.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_outline_rounded, color: cs.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appeal.studentName,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${appeal.studentNumber} • ${appeal.program ?? "General"}',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${appeal.items.length} Courses',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submitted: ${appeal.createdAt.day}/${appeal.createdAt.month}/${appeal.createdAt.year}',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withAlpha(100),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Icon(Icons.chevron_right_rounded, color: cs.onSurface.withAlpha(60)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: (index * 80).ms,
        ).slideY(begin: 0.1, end: 0);
  }
}
