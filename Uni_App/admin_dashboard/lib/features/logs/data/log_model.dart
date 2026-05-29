class LogModel {
  final int id;
  final String? causer;
  final String? action;
  final String? subjectType;
  final int? subjectId;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? createdAt;

  const LogModel({
    required this.id,
    this.causer,
    this.action,
    this.subjectType,
    this.subjectId,
    this.oldValues,
    this.newValues,
    this.createdAt,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      causer: json['causer']?.toString(),
      action: json['action']?.toString(),
      subjectType: json['subjectType']?.toString(),
      subjectId: json['subjectId'] != null
          ? int.tryParse(json['subjectId'].toString())
          : null,
      oldValues: json['oldValues'] is Map<String, dynamic>
          ? json['oldValues'] as Map<String, dynamic>
          : null,
      newValues: json['newValues'] is Map<String, dynamic>
          ? json['newValues'] as Map<String, dynamic>
          : null,
      createdAt: json['createdAt']?.toString(),
    );
  }

  String get oldValuesDisplay => oldValues != null ? oldValues.toString() : '-';

  String get newValuesDisplay => newValues != null ? newValues.toString() : '-';
}
