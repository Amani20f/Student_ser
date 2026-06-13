class CourseModel {
  final int id;
  final int programId;
  final String courseCode;
  final String courseName;
  final int creditHours;
  final int semesterLevel;
  final int orderIndex;
  final String? description;
  final String? deletedAt;
  final List<CourseModel> prerequisites;

  CourseModel({
    required this.id,
    required this.programId,
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.semesterLevel,
    required this.orderIndex,
    this.description,
    this.deletedAt,
    this.prerequisites = const [],
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      programId: json['program_id'],
      courseCode: json['course_code'] ?? '',
      courseName: json['course_name'] ?? '',
      creditHours: json['credit_hours'] ?? 3,
      semesterLevel: json['semester_level'] ?? 1,
      orderIndex: json['order_index'] ?? 0,
      description: json['description'],
      deletedAt: json['deleted_at'],
      prerequisites: (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => CourseModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  bool get isArchived => deletedAt != null;
}
