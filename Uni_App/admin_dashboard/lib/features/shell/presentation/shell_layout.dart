import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../../core/constants/role_constants.dart';
import '../../../core/providers/back_action_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

final lastRouteProvider = StateProvider<String>((ref) => '');

class ShellLayout extends ConsumerWidget {
  final Widget child;
  final String currentPath;

  const ShellLayout({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState.primaryRole;
    final navItems = _getNavItems(context, role);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Reset custom back action when the route changes (e.g. via sidebar)
    final lastPath = ref.read(lastRouteProvider);
    if (lastPath != currentPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(lastRouteProvider.notifier).state = currentPath;
        ref.read(backActionProvider.notifier).state = null;
      });
    }

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──
          Container(
            width: 270,
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                right: BorderSide(
                  color: cs.outlineVariant.withAlpha(60),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Brand header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: cs.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.uniAdmin,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!.dashboardSubtitle,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withAlpha(140),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
                Divider(height: 1, color: cs.outlineVariant.withAlpha(40)),
                const SizedBox(height: 12),

                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final isActive = currentPath == item.path;
                      return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: ListTile(
                                dense: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                tileColor: isActive
                                    ? cs.primary.withAlpha(25)
                                    : Colors.transparent,
                                leading: Icon(
                                  item.icon,
                                  color: isActive
                                      ? cs.primary
                                      : cs.onSurface.withAlpha(140),
                                  size: 22,
                                ),
                                title: Text(
                                  item.label,
                                  style: tt.bodyMedium?.copyWith(
                                    color: isActive
                                        ? cs.primary
                                        : cs.onSurface.withAlpha(180),
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                onTap: () {
                                  if (currentPath != item.path) {
                                    context.go(item.path);
                                  }
                                },
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (80 * index).ms)
                          .slideX(begin: -0.1, end: 0, duration: 300.ms);
                    },
                  ),
                ),

                // User info at bottom
                Divider(height: 1, color: cs.outlineVariant.withAlpha(40)),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: cs.primary.withAlpha(30),
                        child: Text(
                          (authState.user?.name ?? 'U')[0].toUpperCase(),
                          style: tt.titleSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.user?.name ?? '',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              authState.user?.roleDisplayName ?? '',
                              style: tt.bodySmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              ],
            ),
          ),

          // ── Main Content ──
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: cs.outlineVariant.withAlpha(40),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (currentPath != '/dashboard')
                        IconButton(
                          onPressed: () {
                            final customAction = ref.read(backActionProvider);
                            if (customAction != null) {
                              customAction();
                              return;
                            }

                            if (Navigator.of(context).canPop()) {
                              context.pop();
                            } else {
                              if (currentPath.startsWith('/appeals/')) {
                                context.go('/appeals');
                              } else {
                                context.go('/dashboard');
                              }
                            }
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip: 'Back',
                          color: cs.primary,
                        ),
                      if (currentPath != '/dashboard') const SizedBox(width: 8),
                      Text(
                        _getPageTitle(context, currentPath),
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: cs.onSurface,
                        ),
                      ),
                      const Spacer(),
                      // Language toggle
                      Tooltip(
                        message: ref.watch(localeProvider).languageCode == 'en' ? 'Switch to Arabic' : 'Switch to English',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            final current = ref.read(localeProvider);
                            ref.read(localeProvider.notifier).state =
                                current.languageCode == 'en'
                                    ? const Locale('ar')
                                    : const Locale('en');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: cs.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ref.watch(localeProvider).languageCode == 'en' ? 'ع' : 'EN',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Theme toggle
                      IconButton(
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).toggle();
                        },
                        icon: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: cs.onSurface.withAlpha(160),
                        ),
                        tooltip: AppLocalizations.of(context)!.toggleTheme,
                      ),
                      const SizedBox(width: 8),
                      // Notifications
                      IconButton(
                        onPressed: () => context.go('/notifications'),
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: cs.onSurface.withAlpha(160),
                        ),
                        tooltip: AppLocalizations.of(context)!.notifications,
                      ),
                      const SizedBox(width: 12),
                      // User badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: cs.primary.withAlpha(40),
                              child: Text(
                                (authState.user?.name ?? 'U')[0].toUpperCase(),
                                style: tt.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              authState.user?.roleDisplayName ?? '',
                              style: tt.bodySmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => _showLogoutDialog(context, ref),
                        icon: Icon(
                          Icons.logout_rounded,
                          color: cs.onSurface.withAlpha(140),
                        ),
                        tooltip: AppLocalizations.of(context)!.logout,
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_NavItem> _getNavItems(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context)!;
    final allItems = [
      _NavItem('/dashboard', l10n.dashboardLabel, Icons.dashboard_rounded),
      _NavItem('/requests', l10n.requests, Icons.assignment_rounded),
      _NavItem('/payments', l10n.payments, Icons.payment_rounded),
      _NavItem('/grades', l10n.grades, Icons.grade_rounded),
      _NavItem('/logs', l10n.activityLogs, Icons.history_rounded),
      _NavItem('/notifications', l10n.notifications, Icons.notifications_rounded),
      _NavItem('/users', l10n.userManagement, Icons.manage_accounts_rounded),
      _NavItem('/appeals', 'Grade Appeals', Icons.grading_rounded),
    ];

    return allItems
        .where((item) => RoleConstants.canAccess(role, item.path))
        .toList();
  }

  String _getPageTitle(BuildContext context, String path) {
    final l10n = AppLocalizations.of(context)!;
    switch (path) {
      case '/dashboard':
        return l10n.dashboardLabel;
      case '/requests':
        return l10n.serviceRequests;
      case '/payments':
        return l10n.paymentVerification;
      case '/grades':
        return l10n.gradeManagement;
      case '/logs':
        return l10n.activityLogs;
      case '/notifications':
        return l10n.notifications;
      case '/users':
        return l10n.userManagement;
      case '/appeals':
        return 'Grade Appeals';
      default:
        if (path.startsWith('/appeals/')) return 'Appeal Details';
        return 'Al-Arab University';
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Confirm Logout',
          style: tt.titleMedium?.copyWith(color: cs.onSurface),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: tt.bodyMedium?.copyWith(color: cs.onSurface),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path;
  final String label;
  final IconData icon;

  const _NavItem(this.path, this.label, this.icon);
}
