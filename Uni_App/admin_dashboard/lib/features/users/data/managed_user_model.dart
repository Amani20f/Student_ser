class ManagedUserModel {
  final int id;
  final String name;
  final String? username;
  final String email;
  final String role;
  final List<String> roles;

  const ManagedUserModel({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    required this.role,
    required this.roles,
  });

  String get primaryRole => roles.isNotEmpty ? roles.first : role;

  String get roleDisplayName {
    switch (primaryRole) {
      case 'admin':
        return 'Administrator';
      case 'student_affairs':
        return 'Student Affairs';
      case 'accountant':
        return 'Accountant';
      case 'grade_control':
        return 'Grade Control';
      case 'student':
        return 'Student';
      default:
        return primaryRole;
    }
  }

  factory ManagedUserModel.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    List<String> parsedRoles = [];
    if (rawRoles is List) {
      parsedRoles = rawRoles.map((e) => e.toString()).toList();
    }

    return ManagedUserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      roles: parsedRoles,
    );
  }
}
