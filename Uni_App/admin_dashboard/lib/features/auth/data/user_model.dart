class UserModel {
  final int id;
  final String name;
  final String? username;
  final String email;
  final String role;
  final List<String> roles;
  final List<String> permissions;

  const UserModel({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    required this.role,
    required this.roles,
    required this.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'role': role,
    'roles': roles,
    'permissions': permissions,
  };

  /// Returns the primary role for display purposes.
  String get primaryRole => roles.isNotEmpty ? roles.first : role;

  /// Pretty display name for the role.
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
      default:
        return primaryRole;
    }
  }
}
