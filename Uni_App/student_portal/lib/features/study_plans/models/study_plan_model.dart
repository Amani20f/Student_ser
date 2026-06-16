class StudyPlanModel {
  final String title;
  final String? program;
  final String? fileUrl;
  final DateTime? uploadedAt;

  StudyPlanModel({
    required this.title,
    this.program,
    this.fileUrl,
    this.uploadedAt,
  });

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanModel(
      title: json['title'] ?? 'Study Plan',
      program: json['program'],
      fileUrl: json['file_url'],
      uploadedAt: json['uploaded_at'] != null ? DateTime.parse(json['uploaded_at']) : null,
    );
  }
}
