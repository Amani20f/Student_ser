import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../providers/appeals_provider.dart';
import '../data/appeal_model.dart';
import '../../auth/providers/auth_provider.dart';

class AppealDetailsPage extends ConsumerStatefulWidget {
  final int appealId;

  const AppealDetailsPage({super.key, required this.appealId});

  @override
  ConsumerState<AppealDetailsPage> createState() => _AppealDetailsPageState();
}

class _AppealDetailsPageState extends ConsumerState<AppealDetailsPage> {
  final Map<int, TextEditingController> _courseworkControllers = {};
  final Map<int, TextEditingController> _finalScoreControllers = {};
  final Map<int, TextEditingController> _totalControllers = {};
  final _committeeReportController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var c in _courseworkControllers.values) {
      c.dispose();
    }
    for (var c in _finalScoreControllers.values) {
      c.dispose();
    }
    for (var c in _totalControllers.values) {
      c.dispose();
    }
    _committeeReportController.dispose();
    super.dispose();
  }

  void _initializeControllers(List<AppealItemModel> items) {
    for (var item in items) {
      if (!_courseworkControllers.containsKey(item.id)) {
        _courseworkControllers[item.id] = TextEditingController(
            text: item.after.coursework?.toString() ?? '');
        _finalScoreControllers[item.id] = TextEditingController(
            text: item.after.finalScore?.toString() ?? '');
        _totalControllers[item.id] =
            TextEditingController(text: item.after.total?.toString() ?? '');
      }
    }
  }

  Future<void> _submitReview(String decision) async {
    final l10n = AppLocalizations.of(context)!;
    
    if (decision == 'approved') {
      // Validate all fields are filled
      for (var id in _courseworkControllers.keys) {
        if (_courseworkControllers[id]!.text.isEmpty ||
            _finalScoreControllers[id]!.text.isEmpty ||
            _totalControllers[id]!.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all grade fields before approving.')),
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final List<Map<String, dynamic>> items = [];
      if (decision == 'approved') {
        for (var id in _courseworkControllers.keys) {
          items.add({
            'appeal_item_id': id,
            'coursework_after': double.tryParse(_courseworkControllers[id]!.text),
            'final_after': double.tryParse(_finalScoreControllers[id]!.text),
            'total_after': double.tryParse(_totalControllers[id]!.text),
          });
        }
      }

      await ref.read(appealRepositoryProvider).reviewAppeal(
            appealId: widget.appealId,
            decision: decision,
            committeeReport: _committeeReportController.text,
            items: items,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(decision == 'approved'
                ? 'Appeal approved successfully.'
                : 'Appeal rejected.'),
            backgroundColor: decision == 'approved' ? Colors.green : Colors.orange,
          ),
        );
        ref.invalidate(underReviewAppealsProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final appealAsync = ref.watch(appealDetailsProvider(widget.appealId));
    final isAdmin = ref.watch(authProvider).primaryRole == 'admin';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: appealAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (appeal) {
          _initializeControllers(appeal.items);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(appeal, cs, tt),
                const SizedBox(height: 24),
                _buildStudentNote(appeal, cs, tt),
                const SizedBox(height: 24),
                ...appeal.items.map((item) => _buildItemCard(item, cs, tt, isAdmin)),
                const SizedBox(height: 32),
                _buildCommitteeReportSection(cs, tt, !isAdmin),
                const SizedBox(height: 40),
                if (!isAdmin) _buildActionButtons(cs),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms);
        },
      ),
    );
  }

  Widget _buildHeader(AppealModel appeal, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appeal.studentName,
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Student ID: ${appeal.studentNumber} • ${appeal.program ?? "General"}',
                  style: tt.titleMedium?.copyWith(color: cs.onSurface.withAlpha(150)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoBadge(Icons.calendar_month, '${appeal.academicYear} ${appeal.term}', cs),
                    const SizedBox(width: 12),
                    _buildInfoBadge(Icons.grading, 'Status: ${appeal.status}', cs),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStudentNote(AppealModel appeal, ColorScheme cs, TextTheme tt) {
    if (appeal.studentNote == null || appeal.studentNote!.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.secondary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 20, color: cs.secondary),
              const SizedBox(width: 10),
              Text('Student Notes', style: tt.titleSmall?.copyWith(color: cs.secondary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appeal.studentNote!,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface.withAlpha(200)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(AppealItemModel item, ColorScheme cs, TextTheme tt, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              item.courseName,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withAlpha(50)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // BEFORE (READ ONLY)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BEFORE (Read-only)', style: tt.labelLarge?.copyWith(color: cs.onSurface.withAlpha(150), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('Coursework', item.before.coursework, cs),
                      const SizedBox(height: 12),
                      _buildReadOnlyField('Final Exam', item.before.finalScore, cs),
                      const SizedBox(height: 12),
                      _buildReadOnlyField('Total Score', item.before.total, cs, isTotal: true),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                // AFTER (EDITABLE)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AFTER (Proposed Changes)', style: tt.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildEditableField('Coursework', _courseworkControllers[item.id]!, cs, enabled: !isAdmin),
                      const SizedBox(height: 12),
                      _buildEditableField('Final Exam', _finalScoreControllers[item.id]!, cs, enabled: !isAdmin),
                      const SizedBox(height: 12),
                      _buildEditableField('Total Score', _totalControllers[item.id]!, cs, isTotal: true, enabled: !isAdmin),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, double? value, ColorScheme cs, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withAlpha(60),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value?.toString() ?? '—',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? cs.primary : cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, ColorScheme cs, {bool isTotal = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? cs.primary : null,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: enabled ? cs.surface : cs.surfaceContainerHighest.withAlpha(60),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildCommitteeReportSection(ColorScheme cs, TextTheme tt, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Committee Report & Notes', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _committeeReportController,
          enabled: enabled,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: enabled ? 'Enter final review committee report or internal notes...' : 'No notes available.',
            filled: true,
            fillColor: enabled ? cs.surface : cs.surfaceContainerHighest.withAlpha(60),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme cs) {
    if (_isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _submitReview('rejected'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              side: BorderSide(color: cs.error),
              foregroundColor: cs.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close_rounded, size: 20),
                SizedBox(width: 8),
                Text('Reject Appeal', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: FilledButton(
            onPressed: () => _submitReview('approved'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 20),
                SizedBox(width: 8),
                Text('Approve & Update Grades', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
