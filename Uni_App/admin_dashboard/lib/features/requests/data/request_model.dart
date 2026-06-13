class RequestModel {
  final int id;
  final int? studentId;
  final String? studentName;
  final String? studentNumber;
  final String? programName;
  final String? level;
  final String? requestType;
  final String? requestTypeSlug;
  final String? description;
  final Map<String, dynamic>? attachment;
  final String? status;
  final String? processedBy;
  final String? responseMessage;
  final String? adminNotes;
  final Map<String, dynamic>? formData;
  final Map<String, dynamic>? absenceExcuse;
  final String? createdAt;
  final String? updatedAt;

  const RequestModel({
    required this.id,
    this.studentId,
    this.studentName,
    this.studentNumber,
    this.programName,
    this.level,
    this.requestType,
    this.requestTypeSlug,
    this.description,
    this.attachment,
    this.status,
    this.processedBy,
    this.responseMessage,
    this.adminNotes,
    this.formData,
    this.absenceExcuse,
    this.createdAt,
    this.updatedAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'];

    // attachment can be a String path, a Map<String,String>, a List, or null
    Map<String, dynamic>? parsedAttachment;
    final rawAttachment = json['attachment'];
    if (rawAttachment is Map) {
      parsedAttachment = Map<String, dynamic>.from(rawAttachment);
    } else if (rawAttachment is String && rawAttachment.isNotEmpty) {
      parsedAttachment = {'file_0': rawAttachment};
    } else if (rawAttachment is List) {
      parsedAttachment = {for (var i = 0; i < rawAttachment.length; i++) 'file_$i': rawAttachment[i].toString()};
    }

    // form_data may be a Map or null
    Map<String, dynamic>? parsedFormData;
    final rawFormData = json['form_data'];
    if (rawFormData is Map<String, dynamic>) {
      parsedFormData = rawFormData;
    } else if (rawFormData is Map) {
      parsedFormData = Map<String, dynamic>.from(rawFormData);
    }

    return RequestModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      studentId: student?['id'] != null
          ? int.tryParse(student['id'].toString())
          : null,
      studentName: student?['name']?.toString(),
      studentNumber: student?['student_number']?.toString(),
      programName: student?['program_name']?.toString() ?? student?['program']?['name']?.toString(),
      level: student?['current_level']?.toString() ?? student?['level']?.toString(),
      requestType: json['request_type']?.toString(),
      requestTypeSlug: json['request_type_slug']?.toString(),
      description: json['description']?.toString(),
      attachment: parsedAttachment,
      status: json['status']?.toString().toLowerCase(),
      processedBy: json['processed_by']?.toString(),
      responseMessage: json['response_message']?.toString(),
      adminNotes: json['admin_notes']?.toString(),
      formData: parsedFormData,
      absenceExcuse: json['absence_excuse'] != null
          ? Map<String, dynamic>.from(json['absence_excuse'])
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
