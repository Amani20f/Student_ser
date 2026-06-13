import 'package:equatable/equatable.dart';

class SemesterModel extends Equatable {
  final int id;
  final String academicYear;
  final String term;
  final bool isActive;
  final String startDate;
  final String endDate;
  final String examsStartDate;
  final String? createdAt;
  final String? updatedAt;

  const SemesterModel({
    required this.id,
    required this.academicYear,
    required this.term,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.examsStartDate,
    this.createdAt,
    this.updatedAt,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] as int,
      academicYear: json['academic_year'] as String,
      term: json['term'] as String,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      examsStartDate: json['exams_start_date'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academic_year': academicYear,
      'term': term,
      'is_active': isActive,
      'start_date': startDate,
      'end_date': endDate,
      'exams_start_date': examsStartDate,
    };
  }

  String get termDisplay => term == 'first' ? 'الفصل الأول' : 'الفصل الثاني';
  String get displayLabel => '$termDisplay $academicYear';

  @override
  List<Object?> get props => [
        id,
        academicYear,
        term,
        isActive,
        startDate,
        endDate,
        examsStartDate,
      ];
}
