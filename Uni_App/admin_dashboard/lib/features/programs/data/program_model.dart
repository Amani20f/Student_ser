class ProgramModel {
  final int id;
  final int departmentId;
  final String name;
  final String code;
  final int durationYears;
  final String degreeType;
  final double fees;
  final String? departmentName;
  final String? collegeName;
  final String? deletedAt;

  ProgramModel({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.code,
    required this.durationYears,
    required this.degreeType,
    required this.fees,
    this.departmentName,
    this.collegeName,
    this.deletedAt,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'],
      departmentId: json['department_id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      durationYears: json['duration_years'] ?? 4,
      degreeType: json['degree_type'] ?? 'bachelor',
      fees: json['fees'] != null ? double.tryParse(json['fees'].toString()) ?? 0.0 : 0.0,
      departmentName: json['department']?['name'] ?? json['department'], // Fallback if flattened
      collegeName: json['department']?['college']?['name'] ?? json['college'],
      deletedAt: json['deleted_at'],
    );
  }

  bool get isArchived => deletedAt != null;
}
