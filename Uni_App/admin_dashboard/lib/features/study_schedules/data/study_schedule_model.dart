class StudyScheduleModel {
  final int id;
  final int programId;
  final String? programName;
  final int semesterId;
  final String? academicYear;
  final String? term;
  final int level;
  final String? scheduleImageUrl;
  final String? notes;

  StudyScheduleModel({
    required this.id,
    required this.programId,
    this.programName,
    required this.semesterId,
    this.academicYear,
    this.term,
    required this.level,
    this.scheduleImageUrl,
    this.notes,
  });

  factory StudyScheduleModel.fromJson(Map<String, dynamic> json) {
    return StudyScheduleModel(
      id: json['id'] as int,
      programId: json['program_id'] as int,
      programName: json['program_name']?.toString(),
      semesterId: json['semester_id'] as int,
      academicYear: json['academic_year']?.toString(),
      term: json['term']?.toString(),
      level: json['level'] as int,
      scheduleImageUrl: json['schedule_image_url']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}

class SemesterModel {
  final int id;
  final String name;
  final String year;
  final bool isCurrent;

  SemesterModel({
    required this.id,
    required this.name,
    required this.year,
    required this.isCurrent,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}
