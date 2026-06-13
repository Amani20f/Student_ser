import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/status_helper.dart';
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

          if (isAdmin) {
            return _buildAdminAuditView(appeal, cs, tt);
          } else {
            return _buildGradeControlView(appeal, cs, tt);
          }
        },
      ),
    );
  }

  // ==========================================
  // ADMIN AUDIT VIEW (READ ONLY, ARABIC)
  // ==========================================

  Widget _buildAdminAuditView(AppealModel appeal, ColorScheme cs, TextTheme tt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminHeader(appeal, cs, tt),
          const SizedBox(height: 24),
          _buildStudentNoteAdmin(appeal, cs, tt),
          const SizedBox(height: 24),
          ...appeal.items.map((item) => _buildAdminComparisonCard(item, cs, tt)),
          const SizedBox(height: 32),
          _buildCommitteeReportAdmin(appeal, cs, tt),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildAdminHeader(AppealModel appeal, ColorScheme cs, TextTheme tt) {
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
                  'الرقم الجامعي: ${appeal.studentNumber} • ${appeal.program ?? "عام"}',
                  style: tt.titleMedium?.copyWith(color: cs.onSurface.withAlpha(150)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildInfoBadge(Icons.calendar_month, '${appeal.academicYear} ${appeal.term}', cs),
                    if (appeal.paymentStatus != null)
                      _buildInfoBadge(Icons.payment, 'حالة الدفع: ${StatusHelper.localize(context, appeal.paymentStatus!)}', cs),
                    _buildInfoBadge(Icons.grading, 'حالة التظلم: ${StatusHelper.localize(context, appeal.status)}', cs),
                  ],
                ),
                if (appeal.reviewerName != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildInfoBadge(Icons.person, 'المُراجع: ${appeal.reviewerName}', cs),
                      if (appeal.reviewedAt != null)
                        _buildInfoBadge(Icons.access_time, 'تاريخ المراجعة: ${appeal.reviewedAt!.split(" ")[0]}', cs),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminComparisonCard(AppealItemModel item, ColorScheme cs, TextTheme tt) {
    bool notReviewed = item.after.coursework == null && item.after.finalScore == null && item.after.total == null;
    
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الدرجة الحالية (قبل التظلم)', style: tt.labelLarge?.copyWith(color: cs.onSurface.withAlpha(150), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildReadOnlyFieldAdmin('أعمال السنة', item.before.coursework, cs),
                      const SizedBox(height: 12),
                      _buildReadOnlyFieldAdmin('الاختبار النهائي', item.before.finalScore, cs),
                      const SizedBox(height: 12),
                      _buildReadOnlyFieldAdmin('المجموع', item.before.total, cs, isTotal: true),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الدرجة المعدلة (بعد التظلم)', style: tt.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildReadOnlyFieldAdmin('أعمال السنة', item.after.coursework, cs),
                      const SizedBox(height: 12),
                      _buildReadOnlyFieldAdmin('الاختبار النهائي', item.after.finalScore, cs),
                      const SizedBox(height: 12),
                      _buildReadOnlyFieldAdmin('المجموع', item.after.total, cs, isTotal: true),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الفرق', style: tt.labelLarge?.copyWith(color: Colors.orange, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (notReviewed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('لم تتم المراجعة بعد', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        )
                      else ...[
                        _buildDifferenceField(item.before.coursework, item.after.coursework, cs),
                        const SizedBox(height: 12),
                        _buildDifferenceField(item.before.finalScore, item.after.finalScore, cs),
                        const SizedBox(height: 12),
                        _buildDifferenceField(item.before.total, item.after.total, cs, isTotal: true),
                      ],
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

  Widget _buildDifferenceField(double? before, double? after, ColorScheme cs, {bool isTotal = false}) {
    if (before == null || after == null) {
      return _buildReadOnlyFieldAdmin('', null, cs);
    }
    double diff = after - before;
    String sign = diff > 0 ? '+' : '';
    Color color = diff > 0 ? Colors.green : (diff < 0 ? Colors.red : cs.onSurface);
    
    return Container(
      width: double.infinity,
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        '$sign$diff',
        style: TextStyle(
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildReadOnlyFieldAdmin(String label, double? value, ColorScheme cs, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
        ],
        Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildStudentNoteAdmin(AppealModel appeal, ColorScheme cs, TextTheme tt) {
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
              Text('ملاحظات الطالب', style: tt.titleSmall?.copyWith(color: cs.secondary, fontWeight: FontWeight.bold)),
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

  Widget _buildCommitteeReportAdmin(AppealModel appeal, ColorScheme cs, TextTheme tt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.tertiary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, size: 20, color: cs.tertiary),
              const SizedBox(width: 10),
              Text('تقرير لجنة المراجعة', style: tt.titleSmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appeal.committeeReport == null || appeal.committeeReport!.isEmpty
                ? 'لا يوجد تقرير متاح حتى الآن.'
                : appeal.committeeReport!,
            style: tt.bodyMedium?.copyWith(
              color: appeal.committeeReport == null || appeal.committeeReport!.isEmpty
                  ? cs.onSurface.withAlpha(100)
                  : cs.onSurface.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GRADE CONTROL VIEW (EDITABLE, ENGLISH)
  // ==========================================

  Widget _buildGradeControlView(AppealModel appeal, ColorScheme cs, TextTheme tt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(appeal, cs, tt),
          const SizedBox(height: 24),
          _buildStudentNote(appeal, cs, tt),
          const SizedBox(height: 24),
          ...appeal.items.map((item) => _buildItemCard(item, cs, tt)),
          const SizedBox(height: 32),
          _buildCommitteeReportSection(cs, tt),
          const SizedBox(height: 40),
          _buildActionButtons(cs),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
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
                    _buildInfoBadge(Icons.grading, 'Status: ${StatusHelper.localize(context, appeal.status)}', cs),
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

  Widget _buildItemCard(AppealItemModel item, ColorScheme cs, TextTheme tt) {
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
                      _buildEditableField('Coursework', _courseworkControllers[item.id]!, cs),
                      const SizedBox(height: 12),
                      _buildEditableField('Final Exam', _finalScoreControllers[item.id]!, cs),
                      const SizedBox(height: 12),
                      _buildEditableField('Total Score', _totalControllers[item.id]!, cs, isTotal: true),
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

  Widget _buildEditableField(String label, TextEditingController controller, ColorScheme cs, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? cs.primary : null,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: cs.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildCommitteeReportSection(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Committee Report & Notes', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _committeeReportController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter final review committee report or internal notes...',
            filled: true,
            fillColor: cs.surface,
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
