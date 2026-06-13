class Survey {
  final int id;
  final String title;
  final String googleFormUrl;
  final int? semesterId;
  final bool isActive;
  final bool isRequiredForGrades;
  final DateTime createdAt;

  Survey({
    required this.id,
    required this.title,
    required this.googleFormUrl,
    this.semesterId,
    required this.isActive,
    required this.isRequiredForGrades,
    required this.createdAt,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      googleFormUrl: json['google_form_url'],
      semesterId: json['semester_id'],
      isActive: json['is_active'] ?? false,
      isRequiredForGrades: json['is_required_for_grades'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
