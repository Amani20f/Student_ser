import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/managed_user_model.dart';
import '../providers/users_provider.dart';
import '../../../core/models/filter_definition.dart';
import '../../../core/widgets/filter_bar.dart';
import '../../../core/providers/back_action_provider.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Listen for filter changes to update global back action
    ref.listen(userFiltersProvider, (_, __) => _updateBackAction(ref, ref));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with Create button
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.manageUsersSubtitle,
                style:
                    tt.bodyMedium?.copyWith(color: cs.onSurface.withAlpha(150)),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showCreateUserDialog(context, ref),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: Text(l10n.createAccount),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 16),

        // Filter Bar
        FilterBar(
          filters: [
            FilterDefinition(
              id: 'role',
              label: l10n.roleLabel,
              type: FilterType.dropdown,
              icon: Icons.badge_outlined,
              options: [
                FilterValue(label: l10n.roleAdmin, value: 'admin'),
                FilterValue(label: l10n.roleStaffAffairs, value: 'student_affairs'),
                FilterValue(label: l10n.roleAccountant, value: 'accountant'),
                FilterValue(label: l10n.roleStudent, value: 'student'),
              ],
            ),
            FilterDefinition(
              id: 'program_id',
              label: l10n.specializationLabel,
              type: FilterType.dropdown,
              icon: Icons.school_outlined,
              options: [
                FilterValue(label: l10n.computerScience, value: 1),
                FilterValue(label: l10n.electricalEngineering, value: 2),
                FilterValue(label: l10n.businessAdministration, value: 3),
              ],
            ),
            FilterDefinition(
              id: 'current_level',
              label: l10n.academicLevelLabel,
              type: FilterType.dropdown,
              icon: Icons.layers_outlined,
              options: [
                FilterValue(label: l10n.levelNumber(1), value: 1),
                FilterValue(label: l10n.levelNumber(2), value: 2),
                FilterValue(label: l10n.levelNumber(3), value: 3),
                FilterValue(label: l10n.levelNumber(4), value: 4),
                FilterValue(label: l10n.levelNumber(5), value: 5),
                FilterValue(label: l10n.levelNumber(6), value: 6),
                FilterValue(label: l10n.levelNumber(7), value: 7),
                FilterValue(label: l10n.levelNumber(8), value: 8),
              ],
            ),
            FilterDefinition(
              id: 'search',
              label: l10n.searchNameCardPlaceholder,
              type: FilterType.text,
              icon: Icons.person_search_outlined,
            ),
          ],
          currentValues: ref.watch(userFiltersProvider),
          onFilterChanged: (id, value) {
            final current = ref.read(userFiltersProvider);
            ref.read(userFiltersProvider.notifier).state = {
              ...current,
              id: value,
            };
          },
          onClearAll: () {
            ref.read(userFiltersProvider.notifier).state = {};
          },
        ),
        const SizedBox(height: 24),

        // Users list
        Expanded(
          child: usersAsync.when(
            loading: () =>
                Center(child: CircularProgressIndicator(color: cs.primary)),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: cs.error, size: 48),
                  const SizedBox(height: 16),
                  Text('${l10n.failedToLoadLogs}: $error',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurface.withAlpha(140))),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(usersProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (users) {
              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off_rounded,
                          color: cs.onSurface.withAlpha(100), size: 64),
                      const SizedBox(height: 16),
                      Text(l10n.noLogsFound,
                          style: tt.titleMedium
                              ?.copyWith(color: cs.onSurface.withAlpha(140))),
                    ],
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.outlineVariant.withAlpha(40)),
                  boxShadow: [
                    BoxShadow(
                        color: cs.shadow.withAlpha(8),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 28,
                        horizontalMargin: 24,
                        columns: [
                          DataColumn(label: Text(l10n.nameLabel)),
                          DataColumn(label: Text(l10n.usernameLabel)),
                          DataColumn(label: Text(l10n.emailLabel)),
                          DataColumn(label: Text(l10n.roleLabel)),
                          DataColumn(label: Text(l10n.actionsColumn)),
                        ],
                        rows: users.asMap().entries.map((entry) {
                          final user = entry.value;
                          return _buildRow(context, ref, user);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms);
            },
          ),
        ),
      ],
    );
  }

  DataRow _buildRow(
      BuildContext context, WidgetRef ref, ManagedUserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final currentUser = ref.read(authProvider).user;
    final currentUserId = currentUser?.id;

    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: cs.primary.withAlpha(30),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: tt.bodySmall?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Text(user.name,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        DataCell(Text(user.username ?? '—',
            style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(150)))),
        DataCell(Text(user.email, style: tt.bodySmall)),
        DataCell(StatusBadge(label: user.roleDisplayName)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Change password
              Tooltip(
                message: l10n.changePassword,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showChangePasswordDialog(context, ref, user),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.key_rounded, color: cs.primary, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              if (user.id != currentUserId)
                Tooltip(
                  message: l10n.deleteUser,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _showDeleteDialog(context, ref, user),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: cs.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          color: cs.error, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Create User Dialog ───────────────────────────────────────────────────
  void _showCreateUserDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'student_affairs';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.person_add_rounded, color: cs.primary, size: 22),
              const SizedBox(width: 10),
              Text(l10n.createNewAccount,
                  style: tt.titleMedium?.copyWith(color: cs.onSurface)),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameCtrl, l10n.fullName, Icons.person_outline, cs, tt),
                const SizedBox(height: 14),
                _field(usernameCtrl, l10n.usernameLabel,
                    Icons.alternate_email_rounded, cs, tt),
                const SizedBox(height: 14),
                _field(emailCtrl, l10n.emailLabel, Icons.email_outlined, cs, tt,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _field(passwordCtrl, l10n.passwordLabel,
                    Icons.lock_outline_rounded, cs, tt,
                    obscure: true),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: l10n.roleLabel,
                    prefixIcon:
                        Icon(Icons.badge_outlined, color: cs.primary, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'student_affairs',
                        child: Text('Student Affairs')),
                    DropdownMenuItem(
                        value: 'accountant', child: Text('Accountant')),
                    DropdownMenuItem(
                        value: 'grade_control', child: Text('Grade Control')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('Administrator')),
                  ],
                  onChanged: (v) =>
                      setState(() => selectedRole = v ?? selectedRole),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  final repo = ref.read(userManagementRepositoryProvider);
                  await repo.createUser(
                    name: nameCtrl.text.trim(),
                    username: usernameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    password: passwordCtrl.text,
                    role: selectedRole,
                  );
                  ref.invalidate(usersProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.accountCreatedSuccess),
                          backgroundColor: cs.primary),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.error(e.toString())),
                          backgroundColor: cs.error),
                    );
                  }
                }
                nameCtrl.dispose();
                usernameCtrl.dispose();
                emailCtrl.dispose();
                passwordCtrl.dispose();
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Change Password Dialog ───────────────────────────────────────────────
  void _showChangePasswordDialog(
      BuildContext context, WidgetRef ref, ManagedUserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.key_rounded, color: cs.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l10n.changePasswordFor(user.name),
                  style: tt.titleMedium?.copyWith(color: cs.onSurface),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: _field(passwordCtrl, l10n.newPassword,
              Icons.lock_outline_rounded, cs, tt,
              obscure: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repo = ref.read(userManagementRepositoryProvider);
                await repo.updatePassword(user.id, passwordCtrl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.passwordUpdatedSuccess),
                        backgroundColor: cs.primary),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.error(e.toString())),
                        backgroundColor: cs.error),
                  );
                }
              }
              passwordCtrl.dispose();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  // ─── Delete Dialog ────────────────────────────────────────────────────────
  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, ManagedUserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: cs.error, size: 22),
            const SizedBox(width: 10),
            Text(l10n.deleteAccount),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: tt.bodyMedium?.copyWith(color: cs.onSurface),
            children: [
              TextSpan(text: l10n.confirmDeleteAccount(user.name)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repo = ref.read(userManagementRepositoryProvider);
                await repo.deleteUser(user.id);
                ref.invalidate(usersProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${user.name} ${l10n.reject}'),
                        backgroundColor: cs.error),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.error(e.toString())),
                        backgroundColor: cs.error),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text(l10n.reject),
          ),
        ],
      ),
    );
  }

  void _updateBackAction(WidgetRef ref, WidgetRef refRead) {
    final filters = refRead.read(userFiltersProvider);

    if (filters.isNotEmpty) {
      refRead.read(backActionProvider.notifier).state = () {
        refRead.read(userFiltersProvider.notifier).state = {};
      };
    } else {
      refRead.read(backActionProvider.notifier).state = null;
    }
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon,
    ColorScheme cs,
    TextTheme tt, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: cs.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
