class Announcement {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String targetAudience;
  final int? targetCollegeId;
  final int? targetProgramId;
  final bool isActive;
  final String? publishedAt;
  final String? expiresAt;
  final String? createdAt;
  final String? updatedAt;

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
    this.createdAt,
    this.updatedAt,
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
      isActive: json['is_active'] ?? true,
      publishedAt: json['published_at'],
      expiresAt: json['expires_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
