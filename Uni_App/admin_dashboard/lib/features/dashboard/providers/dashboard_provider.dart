import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/api_constants.dart';

/// Dashboard stats model for admin view.
class DashboardStats {
  final int pendingPayments;
  final int pendingRequests;
  final int totalStudents;

  const DashboardStats({
    required this.pendingPayments,
    required this.pendingRequests,
    required this.totalStudents,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      pendingPayments: int.tryParse(json['pending_payments'].toString()) ?? 0,
      pendingRequests: int.tryParse(json['pending_requests'].toString()) ?? 0,
      totalStudents: int.tryParse(json['total_students'].toString()) ?? 0,
    );
  }
}

/// Provider that fetches admin dashboard stats.
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiConstants.adminStats);
  return DashboardStats.fromJson(response as Map<String, dynamic>);
});
