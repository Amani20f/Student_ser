class ApiConstants {
  // ─── Base URL ─────────────────────────────────────────────────────────────
  // • Web / Desktop   : 'http://localhost:8000/api'
  // • Android Emulator: 'http://10.0.2.2:8000/api'
  // • iOS Simulator   : 'http://localhost:8000/api'
  // • Real Device     : 'http://<YOUR_LOCAL_IP>:8000/api'
  static const String baseUrl = 'http://172.16.11.73:8000/api';

  // Auth Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Student Portal Specific
  static const String grades = '/student/grades';
  static const String completeSurvey = '/student/surveys/complete';
  static const String payments = '/student/payments';
  static const String serviceRequests = '/student/service-requests';
  static const String myRequests = '/student/my-requests';
  static const String reEnrollment = '/student/re-enrollment';
  static const String notifications = '/student/notifications';
  static const String requestTypes = '/request-types';

  static String markNotificationRead(int id) =>
      '/student/notifications/$id/read';

  // Appeals (Grievance)
  static const String appeals = '/student/appeals';
  static const String appealsPay = '/student/appeals/pay';
}
