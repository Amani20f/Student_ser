class StudyPlanModel {
  final int id;
  final int programId;
  final String? programName;
  final String title;
  final String? fileUrl;
  final String? uploadedBy;
  final DateTime? uploadedAt;

  StudyPlanModel({
    required this.id,
    required this.programId,
    this.programName,
    required this.title,
    this.fileUrl,
    this.uploadedBy,
    this.uploadedAt,
  });

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanModel(
      id: json['id'] as int,
      programId: json['program_id'] as int,
      programName: json['program_name'] as String?,
      title: json['title'] as String,
      fileUrl: json['file_url'] as String?,
      uploadedBy: json['uploaded_by'] as String?,
      uploadedAt: json['uploaded_at'] != null ? DateTime.parse(json['uploaded_at'] as String) : null,
    );
  }
}
