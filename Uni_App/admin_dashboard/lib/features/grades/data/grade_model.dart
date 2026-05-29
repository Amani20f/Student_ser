class GradeModel {
  final int id;
  final int? studentId;
  final String? studentName;
  final int? courseId;
  final int? semesterId;
  final String? courseName;
  final String? courseCode;
  final String? academicYear;   // mapped from json['academic_year']
  final String? semesterTerm;   // mapped from json['semester_term']
  final double? first;
  final double? second;
  final double? midterm;
  final double? finalScore;
  final double? total;
  final double? gpa;
  final String? status;
  final String? gradeEstimate;  // mapped from json['grade_estimate']
  final String? updatedAt;

  const GradeModel({
    required this.id,
    this.studentId,
    this.studentName,
    this.courseId,
    this.semesterId,
    this.courseName,
    this.courseCode,
    this.academicYear,
    this.semesterTerm,
    this.first,
    this.second,
    this.midterm,
    this.finalScore,
    this.total,
    this.gpa,
    this.status,
    this.gradeEstimate,
    this.updatedAt,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: int.tryParse(json['id'].toString()) ?? 0,

      // Backend GradeResource returns snake_case keys
      studentId: json['student_id'] != null
          ? int.tryParse(json['student_id'].toString())
          : null,
      studentName: json['student_name']?.toString(),
      courseId: json['course_id'] != null
          ? int.tryParse(json['course_id'].toString())
          : null,
      semesterId: json['semester_id'] != null
          ? int.tryParse(json['semester_id'].toString())
          : null,
      courseName: json['course_name']?.toString(),
      courseCode: json['course_code']?.toString(),
      academicYear: json['academic_year']?.toString(),
      semesterTerm: json['semester_term']?.toString(),

      first: json['first'] != null
          ? double.tryParse(json['first'].toString())
          : null,
      second: json['second'] != null
          ? double.tryParse(json['second'].toString())
          : null,
      midterm: json['midterm'] != null
          ? double.tryParse(json['midterm'].toString())
          : null,
      finalScore: json['final'] != null
          ? double.tryParse(json['final'].toString())
          : null,
      total: json['total'] != null
          ? double.tryParse(json['total'].toString())
          : null,
      gpa: json['gpa'] != null
          ? double.tryParse(json['gpa'].toString())
          : null,
      status: json['status']?.toString(),
      gradeEstimate: json['grade_estimate']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  String displayScore(double? value) => value?.toStringAsFixed(1) ?? '-';

  String get semesterDisplay {
    if (semesterTerm != null && academicYear != null) {
      final termLabel = semesterTerm == 'first' ? 'الفصل الأول' : 'الفصل الثاني';
      return '$termLabel ($academicYear)';
    }
    return '—';
  }
}
