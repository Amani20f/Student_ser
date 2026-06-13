class CollegeModel {
  final int id;
  final String name;
  final String code;
  final List<CollegeDepartmentModel> departments;

  CollegeModel({
    required this.id,
    required this.name,
    required this.code,
    required this.departments,
  });

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    final List deptsJson = json['departments'] ?? [];
    return CollegeModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      departments: deptsJson.map((e) => CollegeDepartmentModel.fromJson(e)).toList(),
    );
  }

  // Get a flat list of programs under this college
  List<CollegeProgramModel> get programs {
    final list = <CollegeProgramModel>[];
    for (final dept in departments) {
      list.addAll(dept.programs);
    }
    return list;
  }
}

class CollegeDepartmentModel {
  final int id;
  final String name;
  final String code;
  final List<CollegeProgramModel> programs;

  CollegeDepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.programs,
  });

  factory CollegeDepartmentModel.fromJson(Map<String, dynamic> json) {
    final List progsJson = json['programs'] ?? [];
    return CollegeDepartmentModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      programs: progsJson.map((e) => CollegeProgramModel.fromJson(e)).toList(),
    );
  }
}

class CollegeProgramModel {
  final int id;
  final String name;
  final String code;
  final int durationYears;
  final double fees;
  final String degreeType;

  CollegeProgramModel({
    required this.id,
    required this.name,
    required this.code,
    required this.durationYears,
    required this.fees,
    required this.degreeType,
  });

  factory CollegeProgramModel.fromJson(Map<String, dynamic> json) {
    return CollegeProgramModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      durationYears: json['duration_years'] ?? 4,
      fees: json['fees'] != null ? double.tryParse(json['fees'].toString()) ?? 0.0 : 0.0,
      degreeType: json['degree_type'] ?? 'bachelor',
    );
  }
}
