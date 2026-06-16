class UnifiedRequestModel {
  final int id;
  final String originalType;
  final String requestType;
  final String requestTypeEn;
  final String studentName;
  final String submittedDate;
  final String status;
  final Map<String, dynamic> details;

  UnifiedRequestModel({
    required this.id,
    required this.originalType,
    required this.requestType,
    required this.requestTypeEn,
    required this.studentName,
    required this.submittedDate,
    required this.status,
    required this.details,
  });

  factory UnifiedRequestModel.fromJson(Map<String, dynamic> json) {
    return UnifiedRequestModel(
      id: json['id'] as int,
      originalType: json['original_type'] as String,
      requestType: json['request_type'] as String,
      requestTypeEn: json['request_type_en'] as String,
      studentName: json['student_name'] as String,
      submittedDate: json['submitted_date'] as String,
      status: json['status'] as String,
      details: json['details'] as Map<String, dynamic>,
    );
  }
}
