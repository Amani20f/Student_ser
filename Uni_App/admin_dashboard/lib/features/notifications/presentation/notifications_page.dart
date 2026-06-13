import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../providers/notifications_provider.dart';
import '../data/notification_model.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetRole = 'all';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      await ref.read(notificationRepositoryProvider).sendNotification(
            title: _titleController.text.trim(),
            message: _messageController.text.trim(),
            targetRole: _targetRole,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationSentSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _titleController.clear();
        _messageController.clear();
        ref.invalidate(notificationsListProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSendingNotification(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(id);
      ref.invalidate(notificationsListProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMarkingAsRead(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurface.withAlpha(140),
            indicatorColor: cs.primary,
            tabs: [
              Tab(
                icon: const Icon(Icons.inbox_rounded),
                text: l10n.receivedNotifications,
              ),
              Tab(
                icon: const Icon(Icons.send_rounded),
                text: l10n.sendNotification,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              children: [
                _buildInboxView(cs, tt, l10n),
                _buildSendNotificationForm(
                    cs, tt, l10n, ref.watch(authProvider).primaryRole),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInboxView(ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return notificationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load notifications: $error', style: tt.bodyMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(notificationsListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (notifications) {
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 64, color: cs.onSurface.withAlpha(100)),
                const SizedBox(height: 16),
                Text(
                  l10n.noNotificationsYet,
                  style: tt.titleMedium
                      ?.copyWith(color: cs.onSurface.withAlpha(140)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification, cs, tt, l10n);
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(
      NotificationModel notification, ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead
              ? cs.outlineVariant.withAlpha(50)
              : cs.primary.withAlpha(80),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      color:
          notification.isRead ? cs.surface : cs.primaryContainer.withAlpha(30),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notification.isRead
                    ? cs.surfaceContainerHighest
                    : cs.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.isRead
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_active_rounded,
                color: notification.isRead
                    ? cs.onSurface.withAlpha(150)
                    : cs.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        notification.createdAt,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurface.withAlpha(120)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSurface.withAlpha(200)),
                  ),
                ],
              ),
            ),
            if (!notification.isRead) ...[
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.mark_email_read_rounded),
                color: cs.primary,
                tooltip: l10n.markAsRead,
                onPressed: () => _markAsRead(notification.id),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildSendNotificationForm(
      ColorScheme cs, TextTheme tt, AppLocalizations l10n, String userRole) {
    List<DropdownMenuItem<String>> dropdownItems = [];
    if (userRole == 'admin') {
      dropdownItems = [
        DropdownMenuItem(
            value: 'all', child: Text(l10n.allUsers)),
        DropdownMenuItem(
            value: 'all_staff', child: Text(l10n.allStaff)),
        DropdownMenuItem(
            value: 'student_affairs',
            child: Text(l10n.roleStaffAffairs)),
        DropdownMenuItem(
            value: 'accountant', child: Text(l10n.roleAccountant)),
        DropdownMenuItem(
            value: 'grade_control', child: Text(l10n.roleGradeControl)),
        DropdownMenuItem(value: 'student', child: Text(l10n.roleStudent)),
      ];
    } else if (userRole == 'student_affairs') {
      dropdownItems = [
        DropdownMenuItem(value: 'admin', child: Text(l10n.roleAdmin)),
        DropdownMenuItem(value: 'student', child: Text(l10n.roleStudent)),
        DropdownMenuItem(
            value: 'accountant', child: Text(l10n.roleAccountant)),
        DropdownMenuItem(
            value: 'grade_control', child: Text(l10n.roleGradeControl)),
      ];
    } else if (userRole == 'accountant' || userRole == 'grade_control') {
      dropdownItems = [
        DropdownMenuItem(value: 'admin', child: Text(l10n.roleAdmin)),
        DropdownMenuItem(
            value: 'student_affairs',
            child: Text(l10n.roleStaffAffairs)),
      ];
    }

    if (dropdownItems.isEmpty) {
      return Center(
          child: Text(l10n.unauthorizedSendNotifications,
              style: tt.titleLarge));
    }

    // Ensure _targetRole is valid for the current dropdown items, otherwise set to the first one
    if (!dropdownItems.any((item) => item.value == _targetRole)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _targetRole = dropdownItems.first.value!);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.broadcastNewNotification,
              style: tt.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.titleLabel,
                hintText: l10n.enterNotificationTitle,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.messageLabel,
                hintText: l10n.enterNotificationMessage,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.message_rounded),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter a message'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue:
                  dropdownItems.any((item) => item.value == _targetRole)
                      ? _targetRole
                      : dropdownItems.first.value,
              decoration: InputDecoration(
                labelText: l10n.recipientRole,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.people_rounded),
              ),
              items: dropdownItems,
              onChanged: (v) =>
                  setState(() => _targetRole = v ?? dropdownItems.first.value!),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSending ? null : _sendNotification,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  l10n.sendNotification,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
