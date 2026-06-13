class ApiConstants {
  // ─── Base URL ─────────────────────────────────────────────────────────────
  // • Web / Desktop   : 'http://localhost:8000/api'
  // • Android Emulator: 'http://10.0.2.2:8000/api'
  // • Real Device     : 'http://<YOUR_LOCAL_IP>:8000/api'
  static const String baseUrl = 'http://127.0.0.1:8000/api';

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

  // ─── Admin — Programs, Courses, Pricing ───────────────────────────────────
  static const String adminPrograms = '/admin/programs';
  static String adminProgramById(int id) => '/admin/programs/$id';
  static String adminProgramRestore(int id) => '/admin/programs/$id/restore';

  static const String adminCourses = '/admin/courses';
  static String adminCourseById(int id) => '/admin/courses/$id';
  static String adminCourseRestore(int id) => '/admin/courses/$id/restore';

  static const String adminRequestTypes = '/admin/request-types';
  static String adminRequestTypeById(int id) => '/admin/request-types/$id';

  // ─── Semesters & Study Schedules ──────────────────────────────────────────
  static const String semesters = '/semesters';
  static const String staffStudySchedules = '/staff/study-schedules';
  static String staffStudyScheduleById(int id) => '/staff/study-schedules/$id';

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
  static const String staffUsers = '/staff/users';
  static String staffMarkNotificationRead(int id) =>
      '/staff/notifications/$id/read';

  // ─── Admissions ───────────────────────────────────────────────────────────
  static const String adminApplications = '/admin/applications';
  static String adminApplicationApprove(int id) => '/admin/applications/$id/approve';
  static String adminApplicationReject(int id) => '/admin/applications/$id/reject';

  // ─── Grades Import ────────────────────────────────────────────────────────
  static const String staffGradesImportTemplate = '/staff/grades/import/template';
  static const String staffGradesImportPreview = '/staff/grades/import/preview';
  static const String staffGradesImportValidate = '/staff/grades/import/validate';
  static const String staffGradesImportStore = '/staff/grades/import/store';

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
