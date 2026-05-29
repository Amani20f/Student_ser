import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';
import '../../../core/widgets/stat_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.primaryRole == 'admin';

    if (!isAdmin) {
      return _buildWelcomeView(context, authState);
    }

    return _buildAdminView(context, ref);
  }

  Widget _buildAdminView(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return statsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: cs.primary)),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadStats,
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withAlpha(140),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(dashboardStatsProvider),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (stats) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  l10n.overview,
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: cs.onSurface,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 4
                    : constraints.maxWidth > 700
                    ? 3
                    : 2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: constraints.maxWidth < 600 ? 1.2 : 1.5,
                  children: [
                    StatCard(
                      label: l10n.pendingPayments,
                      value: stats.pendingPayments.toString(),
                      icon: Icons.payment_rounded,
                      animationIndex: 0,
                    ),
                    StatCard(
                      label: l10n.pendingRequests,
                      value: stats.pendingRequests.toString(),
                      icon: Icons.assignment_rounded,
                      animationIndex: 1,
                    ),
                    StatCard(
                      label: l10n.totalStudents,
                      value: stats.totalStudents.toString(),
                      icon: Icons.people_rounded,
                      animationIndex: 2,
                    ),
                    StatCard(
                      label: l10n.totalRevenue,
                      value: '\$${stats.totalRevenue.toStringAsFixed(0)}',
                      icon: Icons.trending_up_rounded,
                      animationIndex: 3,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView(BuildContext context, AuthState authState) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child:
          Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.outlineVariant.withAlpha(40)),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withAlpha(10),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: cs.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.waving_hand_rounded,
                        color: cs.primary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.welcomeTitle(authState.user?.name ?? 'User'),
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.loggedInAs(
                        authState.user?.roleDisplayName ?? 'Staff',
                      ),
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurface.withAlpha(160),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.sidebarNavHelp,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.05, end: 0, duration: 500.ms),
    );
  }
}
