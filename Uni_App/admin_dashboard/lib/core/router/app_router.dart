import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/role_constants.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/shell/presentation/shell_layout.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/requests/presentation/requests_page.dart';
import '../../features/payments/presentation/payments_page.dart';
import '../../features/grades/presentation/grades_page.dart';
import '../../features/logs/presentation/logs_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/users/presentation/users_page.dart';
import '../../features/appeals/presentation/appeals_page.dart';
import '../../features/appeals/presentation/appeal_details_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // Not logged in → go to login
      if (!isLoggedIn && !isLoginRoute) return '/login';

      // Logged in but on login page → go to dashboard
      if (isLoggedIn && isLoginRoute) return '/dashboard';

      // Role-based route guard
      if (isLoggedIn && !isLoginRoute) {
        final role = authState.primaryRole;
        final path = state.matchedLocation;
        // Allow dynamic routes for appeals
        final checkPath = path.startsWith('/appeals/') ? '/appeals' : path;
        if (!RoleConstants.canAccess(role, checkPath)) {
          return '/dashboard';
        }
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) {
          return ShellLayout(currentPath: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/requests',
            builder: (context, state) => const RequestsPage(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentsPage(),
          ),
          GoRoute(
            path: '/grades',
            builder: (context, state) => const GradesPage(),
          ),
          GoRoute(path: '/logs', builder: (context, state) => const LogsPage()),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/appeals',
            builder: (context, state) => const AppealsPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return AppealDetailsPage(appealId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Refresh listenable that notifies GoRouter when auth state changes.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authProvider, (prev, next) {
      notifyListeners();
    });
  }
}
