class ApiConstants {
  // ─── Base URL ─────────────────────────────────────────────────────────────
  // • Web / Desktop   : 'http://localhost:8000/api'
  // • Android Emulator: 'http://10.0.2.2:8000/api'
  // • Real Device     : 'http://<YOUR_LOCAL_IP>:8000/api'
  static const String baseUrl = 'http://localhost:8000/api';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String logout = '/logout';

  // ─── Admin — Stats & Logs ─────────────────────────────────────────────────
  static const String adminStats = '/admin/stats';
  static const String adminLogs = '/admin/logs';

  // ─── Admin — User Management ──────────────────────────────────────────────
  static const String adminUsers = '/admin/users';
  static String adminUserById(int id) => '/admin/users/$id';
  static String adminUserPassword(int id) => '/admin/users/$id/password';

  // ─── Staff — Service Requests ─────────────────────────────────────────────
  static const String staffRequests = '/staff/requests';
  static String staffServiceRequestStatus(int id) =>
      '/staff/service-requests/$id/status';

  // ─── Staff — Payments ─────────────────────────────────────────────────────
  static const String staffPayments = '/staff/payments';
  static String staffPaymentVerify(int id) => '/staff/payments/$id/verify';
  static String staffPaymentReject(int id) => '/staff/payments/$id/reject';

  // ─── Staff — Grades ───────────────────────────────────────────────────────
  static const String staffGrades = '/staff/grades';
  static String staffGradeUpdate(int id) => '/staff/grades/$id';

  // ─── Staff — Grade Appeals ────────────────────────────────────────────────
  static const String staffAppeals = '/staff/appeals';
  static const String staffAppealsUnderReview = '/staff/appeals/under-review';
  static String staffAppealDetails(int id) => '/staff/appeals/$id';
  static String staffAppealReview(int id) => '/staff/appeals/$id/review';

  // ─── Staff — Notifications ────────────────────────────────────────────────
  static const String staffNotifications = '/staff/notifications';
  static String staffMarkNotificationRead(int id) =>
      '/staff/notifications/$id/read';

  // ─── Admin — Logs with filters ────────────────────────────────────────────
  static String adminLogsFiltered({String? action, DateTime? from, DateTime? to}) {
    final params = <String, String>{};
    if (action != null && action.isNotEmpty) params['action'] = action;
    if (from != null) params['from'] = '${from.year}-${from.month.toString().padLeft(2,'0')}-${from.day.toString().padLeft(2,'0')}';
    if (to != null) params['to'] = '${to.year}-${to.month.toString().padLeft(2,'0')}-${to.day.toString().padLeft(2,'0')}';
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    return '/admin/logs${query.isNotEmpty ? '?$query' : ''}';
  }
}
