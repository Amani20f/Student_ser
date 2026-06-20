class RoleConstants {
  static const String admin = 'admin';
  static const String studentAffairs = 'student_affairs';
  static const String accountant = 'accountant';
  static const String gradeControl = 'grade_control';

  /// Routes accessible by each role.
  static const Map<String, List<String>> roleRoutes = {
    admin: ['/dashboard', '/requests', '/payments', '/grades', '/grades/import', '/logs', '/notifications', '/users', '/appeals', '/programs', '/courses', '/semesters', '/pricing'],
    studentAffairs: ['/dashboard', '/requests', '/notifications', '/study-schedules', '/study-plans', '/surveys', '/announcements'],
    accountant: ['/dashboard', '/payments', '/notifications'],
    gradeControl: ['/dashboard', '/grades', '/grades/import', '/notifications', '/appeals'],
  };

  /// Check if a role can access a given route path.
  static bool canAccess(String role, String path) {
    final allowed = roleRoutes[role];
    if (allowed == null) return false;
    return allowed.contains(path);
  }
}
