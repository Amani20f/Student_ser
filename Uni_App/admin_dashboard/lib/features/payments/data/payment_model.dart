class PaymentModel {
  final int id;
  final int? studentId;
  final String? studentName;
  final int? semesterId;
  final String? semesterAcademicYear;
  final String? semesterTerm;
  final double amount;
  final String? purpose;
  final String? receiptImage;
  final String? status;
  final int? appealId;
  final int? requestId;
  final String? createdAt;
  final String? updatedAt;

  const PaymentModel({
    required this.id,
    this.studentId,
    this.studentName,
    this.semesterId,
    this.semesterAcademicYear,
    this.semesterTerm,
    required this.amount,
    this.purpose,
    this.receiptImage,
    this.status,
    this.appealId,
    this.requestId,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'];
    final semester = json['semester'];

    return PaymentModel(
      id: int.tryParse(json['id'].toString()) ?? 0,

      studentId: student?['id'] != null
          ? int.tryParse(student['id'].toString())
          : null,

      studentName: student?['name']?.toString(),

      semesterId: semester?['id'] != null
          ? int.tryParse(semester['id'].toString())
          : (json['semester_id'] != null ? int.tryParse(json['semester_id'].toString()) : null),

      semesterAcademicYear: semester?['academic_year']?.toString(),

      semesterTerm: semester?['term']?.toString(),

      amount: double.tryParse(json['amount'].toString()) ?? 0.0,

      purpose: json['purpose']?.toString(),

      receiptImage: json['receipt_image']?.toString(),

      status: json['status']?.toString().toLowerCase(),
      
      appealId: json['appeal_id'] != null
          ? int.tryParse(json['appeal_id'].toString())
          : null,
      
      requestId: json['request_id'] != null
          ? int.tryParse(json['request_id'].toString())
          : null,

      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  String get semesterDisplay {
    if (semesterAcademicYear != null) {
      final termStr = semesterTerm != null
          ? (semesterTerm == 'first' ? 'الفصل الأول' : 'الفصل الثاني')
          : '';
      return '$termStr ($semesterAcademicYear)';
    }
    return 'N/A';
  }
}
