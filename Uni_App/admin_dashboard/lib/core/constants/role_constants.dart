class RoleConstants {
  static const String admin = 'admin';
  static const String studentAffairs = 'student_affairs';
  static const String accountant = 'accountant';
  static const String gradeControl = 'grade_control';

  /// Routes accessible by each role.
  static const Map<String, List<String>> roleRoutes = {
    admin: ['/dashboard', '/requests', '/payments', '/grades', '/logs', '/notifications', '/users', '/appeals', '/programs', '/courses', '/semesters', '/pricing', '/study-schedules', '/announcements', '/surveys'],
    studentAffairs: ['/dashboard', '/requests', '/notifications', '/study-schedules', '/surveys', '/announcements'],
    accountant: ['/dashboard', '/payments', '/notifications', '/study-schedules'],
    gradeControl: ['/dashboard', '/grades', '/notifications', '/appeals', '/study-schedules'],
  };

  /// Check if a role can access a given route path.
  static bool canAccess(String role, String path) {
    final allowed = roleRoutes[role];
    if (allowed == null) return false;
    return allowed.contains(path);
  }
}
