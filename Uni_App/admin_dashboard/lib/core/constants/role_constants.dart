class RoleConstants {
  static const String admin = 'admin';
  static const String studentAffairs = 'student_affairs';
  static const String accountant = 'accountant';
  static const String gradeControl = 'grade_control';

  /// Routes accessible by each role.
  static const Map<String, List<String>> roleRoutes = {
    admin: ['/dashboard', '/requests', '/payments', '/grades', '/logs', '/notifications', '/users', '/appeals'],
    studentAffairs: ['/dashboard', '/requests', '/notifications'],
    accountant: ['/dashboard', '/payments', '/notifications'],
    gradeControl: ['/dashboard', '/grades', '/notifications', '/appeals'],
  };

  /// Check if a role can access a given route path.
  static bool canAccess(String role, String path) {
    final allowed = roleRoutes[role];
    if (allowed == null) return false;
    return allowed.contains(path);
  }
}
