import 'package:equatable/equatable.dart';
import '../../../core/network/api_client.dart';

/// Represents a College with its departments and programs.
class CollegeModel extends Equatable {
  final int id;
  final String name;
  final String code;
  final List<DepartmentModel> departments;

  const CollegeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.departments,
  });

  factory CollegeModel.fromJson(Map<String, dynamic> json) => CollegeModel(
        id: json['id'],
        name: json['name'],
        code: json['code'] ?? '',
        departments: (json['departments'] as List? ?? [])
            .map((d) => DepartmentModel.fromJson(d))
            .toList(),
      );

  @override
  List<Object?> get props => [id, name, code, departments];
}

class DepartmentModel extends Equatable {
  final int id;
  final String name;
  final String code;
  final List<ProgramModel> programs;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.programs,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) => DepartmentModel(
        id: json['id'],
        name: json['name'],
        code: json['code'] ?? '',
        programs: (json['programs'] as List? ?? [])
            .map((p) => ProgramModel.fromJson(p))
            .toList(),
      );

  @override
  List<Object?> get props => [id, name, code, programs];
}

class ProgramModel extends Equatable {
  final int id;
  final String name;
  final String code;
  final String? college;
  final String? department;

  const ProgramModel({
    required this.id,
    required this.name,
    required this.code,
    this.college,
    this.department,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) => ProgramModel(
        id: json['id'],
        name: json['name'],
        code: json['code'] ?? '',
        college: json['college'],
        department: json['department'],
      );

  @override
  List<Object?> get props => [id, name, code, college, department];
}

/// Repository for fetching academic structure data (colleges, programs).
class AcademicRepository {
  final ApiClient _apiClient;

  // Simple in-memory cache
  List<CollegeModel>? _cachedColleges;
  List<ProgramModel>? _cachedPrograms;

  AcademicRepository(this._apiClient);

  /// Fetch all colleges with departments and programs.
  Future<List<CollegeModel>> getColleges({bool forceRefresh = false}) async {
    if (_cachedColleges != null && !forceRefresh) return _cachedColleges!;

    final response = await _apiClient.get('/colleges');
    final data = response['data'] as List;
    _cachedColleges = data.map((c) => CollegeModel.fromJson(c)).toList();
    return _cachedColleges!;
  }

  /// Fetch a flat list of all programs.
  Future<List<ProgramModel>> getPrograms({bool forceRefresh = false}) async {
    if (_cachedPrograms != null && !forceRefresh) return _cachedPrograms!;

    final response = await _apiClient.get('/programs');
    final data = response['data'] as List;
    _cachedPrograms = data.map((p) => ProgramModel.fromJson(p)).toList();
    return _cachedPrograms!;
  }

  /// Get programs for a specific college by college name.
  Future<List<ProgramModel>> getProgramsForCollege(String collegeName) async {
    final programs = await getPrograms();
    return programs.where((p) => p.college == collegeName).toList();
  }

  void clearCache() {
    _cachedColleges = null;
    _cachedPrograms = null;
  }
}
