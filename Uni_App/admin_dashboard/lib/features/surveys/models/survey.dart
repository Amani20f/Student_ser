class Survey {
  final int id;
  final String title;
  final String? description;
  final String googleFormUrl;
  final int? semesterId;
  final bool isActive;
  final bool isRequiredForGrades;
  final String targetAudience;
  final int? targetCollegeId;
  final int? targetProgramId;
  final int? targetLevel;
  final String? targetCollegeName;
  final String? targetProgramName;
  final DateTime createdAt;

  Survey({
    required this.id,
    required this.title,
    this.description,
    required this.googleFormUrl,
    this.semesterId,
    required this.isActive,
    required this.isRequiredForGrades,
    required this.targetAudience,
    this.targetCollegeId,
    this.targetProgramId,
    this.targetLevel,
    this.targetCollegeName,
    this.targetProgramName,
    required this.createdAt,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      googleFormUrl: json['google_form_url']?.toString() ?? '',
      semesterId: json['semester_id'] != null ? int.tryParse(json['semester_id'].toString()) : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == 'true' || json['is_active'] == '1',
      isRequiredForGrades: json['is_required_for_grades'] == 1 || json['is_required_for_grades'] == true || json['is_required_for_grades'] == 'true' || json['is_required_for_grades'] == '1',
      targetAudience: json['target_audience']?.toString() ?? 'all_students',
      targetCollegeId: json['target_college_id'] != null ? int.tryParse(json['target_college_id'].toString()) : null,
      targetProgramId: json['target_program_id'] != null ? int.tryParse(json['target_program_id'].toString()) : null,
      targetLevel: json['target_level'] != null ? int.tryParse(json['target_level'].toString()) : null,
      targetCollegeName: json['target_college'] is Map ? json['target_college']['name']?.toString() : null,
      targetProgramName: json['target_program'] is Map ? json['target_program']['name']?.toString() : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}
