class AppealModel {
  final int id;
  final String studentName;
  final String studentNumber;
  final String? program;
  final String academicYear;
  final String term;
  final String status;
  final String? studentNote;
  final String? committeeReport;
  final String? reviewerName;
  final String? reviewedAt;
  final String? accountantName;
  final String? paidAt;
  final String? paymentStatus;
  final DateTime createdAt;
  final List<AppealItemModel> items;

  AppealModel({
    required this.id,
    required this.studentName,
    required this.studentNumber,
    this.program,
    required this.academicYear,
    required this.term,
    required this.status,
    this.studentNote,
    this.committeeReport,
    this.reviewerName,
    this.reviewedAt,
    this.accountantName,
    this.paidAt,
    this.paymentStatus,
    required this.createdAt,
    required this.items,
  });

  factory AppealModel.fromJson(Map<String, dynamic> json) {
    final studentData = json['student'] ?? {};
    final itemsData = json['items'] as List? ?? [];

    final reviewedByData = json['reviewed_by'] ?? {};
    final accountantData = json['accountant'] ?? {};
    final paymentsData = json['payments'] as List? ?? [];
    String? pStatus;
    if (paymentsData.isNotEmpty) {
      pStatus = paymentsData.first['status']?.toString();
    }

    return AppealModel(
      id: json['id'] as int,
      studentName: studentData['name']?.toString() ?? 'Unknown',
      studentNumber: studentData['student_number']?.toString() ?? '—',
      program: studentData['program']?.toString(),
      academicYear: json['academic_year']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      studentNote: json['student_note']?.toString(),
      committeeReport: json['committee_report']?.toString(),
      reviewerName: reviewedByData['name']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      accountantName: accountantData['name']?.toString(),
      paidAt: json['paid_at']?.toString(),
      paymentStatus: pStatus,
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      items: itemsData
          .map((i) => AppealItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AppealItemModel {
  final int id;
  final int courseId;
  final String courseName;
  final double? absencePercentage;
  final GradeSnapshot before;
  final GradeSnapshot after;

  AppealItemModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    this.absencePercentage,
    required this.before,
    required this.after,
  });

  factory AppealItemModel.fromJson(Map<String, dynamic> json) {
    return AppealItemModel(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      courseName: json['course_name']?.toString() ?? 'Unknown Course',
      absencePercentage: json['absence_percentage'] != null
          ? double.tryParse(json['absence_percentage'].toString())
          : null,
      before: GradeSnapshot.fromJson(json['before'] ?? {}),
      after: GradeSnapshot.fromJson(json['after'] ?? {}),
    );
  }
}

class GradeSnapshot {
  final double? coursework;
  final double? finalScore;
  final double? total;

  GradeSnapshot({
    this.coursework,
    this.finalScore,
    this.total,
  });

  factory GradeSnapshot.fromJson(Map<String, dynamic> json) {
    return GradeSnapshot(
      coursework: json['coursework'] != null
          ? double.tryParse(json['coursework'].toString())
          : null,
      finalScore: json['final'] != null
          ? double.tryParse(json['final'].toString())
          : null,
      total: json['total'] != null
          ? double.tryParse(json['total'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'coursework': coursework,
    'final': finalScore,
    'total': total,
  };
}
