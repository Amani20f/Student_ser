class Announcement {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String targetAudience;
  final int? targetCollegeId;
  final int? targetProgramId;
  final bool isActive;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? targetCollegeName;
  final String? targetProgramName;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.targetAudience,
    this.targetCollegeId,
    this.targetProgramId,
    required this.isActive,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.targetCollegeName,
    this.targetProgramName,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      targetAudience: json['target_audience'],
      targetCollegeId: json['target_college_id'],
      targetProgramId: json['target_program_id'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      targetCollegeName: json['target_college']?['name'],
      targetProgramName: json['target_program']?['name'],
    );
  }

  String get targetAudienceLabel {
    switch (targetAudience) {
      case 'all_students':
        return 'جميع الطلاب';
      case 'specific_college':
        return 'كلية محددة: ${targetCollegeName ?? ''}';
      case 'specific_program':
        return 'تخصص محدد: ${targetProgramName ?? ''}';
      case 'staff':
        return 'الموظفين وأعضاء هيئة التدريس';
      default:
        return targetAudience;
    }
  }
}
