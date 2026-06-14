import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class RequestsRepository {
  final ApiClient _apiClient;

  RequestsRepository(this._apiClient);

  // ── عذر غياب ──────────────────────────────────────────────────────────────
  /// يرسل طلب تبرير غياب مع المرفقات والمقررات
  Future<Map<String, dynamic>> submitAbsenceExcuse({
    required int requestTypeId,
    required String college,
    required String major,
    required String level,
    required String semester,
    required String academicYear,
    required String reason,
    required List<Map<String, dynamic>>
    courses, // [{course_name, day, absence_date}]
    required List<File> attachments,
  }) async {
    // Translate level to integer (1-8)
    int levelInt = 1;
    if (level.contains('الأول')) {
      levelInt = 1;
    } else if (level.contains('الثاني'))
      levelInt = 2;
    else if (level.contains('الثالث'))
      levelInt = 3;
    else if (level.contains('الرابع'))
      levelInt = 4;
    else if (level.contains('الخامس'))
      levelInt = 5;
    else if (level.contains('السادس'))
      levelInt = 6;
    else if (level.contains('السابع'))
      levelInt = 7;
    else if (level.contains('الثامن'))
      levelInt = 8;
    else {
      levelInt = int.tryParse(level) ?? 1;
    }

    // Translate semester to first or second
    final semesterKey =
        (semester.contains('الأول') || semester.toLowerCase().contains('first'))
        ? 'first'
        : 'second';

    // Day mapping from Arabic to English
    final dayMapping = {
      'السبت': 'Saturday',
      'الأحد': 'Sunday',
      'الإثنين': 'Monday',
      'الثلاثاء': 'Tuesday',
      'الأربعاء': 'Wednesday',
      'الخميس': 'Thursday',
      'الجمعة': 'Friday',
    };

    final fields = <String, String>{
      'request_type_id': requestTypeId.toString(),
      'form_data[college]': college,
      'form_data[specialization]': major,
      'form_data[level]': levelInt.toString(),
      'form_data[semester]': semesterKey,
      'form_data[academic_year]': academicYear,
      'form_data[absence_reason]': reason,
    };

    // إضافة بيانات المقررات كمصفوفة ضمن form_data
    for (int i = 0; i < courses.length; i++) {
      final arabicDay = courses[i]['day']?.toString() ?? '';
      final englishDay = dayMapping[arabicDay] ?? arabicDay;
      fields['form_data[courses][$i][course_name]'] =
          courses[i]['course_name']?.toString() ?? '';
      fields['form_data[courses][$i][day]'] = englishDay;
      fields['form_data[courses][$i][absence_date]'] =
          courses[i]['absence_date']?.toString() ?? '';
    }

    final files = <http.MultipartFile>[];
    for (int i = 0; i < attachments.length; i++) {
      files.add(
        await http.MultipartFile.fromPath(
          'attachments[$i]',
          attachments[i].path,
        ),
      );
    }

    return await _apiClient.postMultipart(
      ApiConstants.serviceRequests,
      fields: fields,
      files: files,
    );
  }

  // ── إيقاف القيد ───────────────────────────────────────────────────────────
  /// يرسل طلب إيقاف قيد مع تفاصيل الفترة والمرفقات
  Future<Map<String, dynamic>> submitStopEnrollment({
    required int requestTypeId,
    required int semesterId,
    required String reason,
    required List<File> attachments,
  }) async {
    final fields = <String, String>{
      'request_type_id': requestTypeId.toString(),
      'form_data[semester]': semesterId.toString(),
      'form_data[reason]': reason,
    };

    final files = <http.MultipartFile>[];
    for (int i = 0; i < attachments.length; i++) {
      files.add(
        await http.MultipartFile.fromPath(
          'attachments[$i]',
          attachments[i].path,
        ),
      );
    }

    return await _apiClient.postMultipart(
      ApiConstants.serviceRequests,
      fields: fields,
      files: files,
    );
  }

  // ── إعادة القيد ───────────────────────────────────────────────────────────
  /// يرسل طلب إعادة القيد مع ملف استمارة الإيقاف وبطاقة الهوية
  Future<Map<String, dynamic>> submitReEnrollment({
    required int requestTypeId,
    required String requestText,
    String? prevStopsCount,
    String? prevSemester,
    File? stopFormFile,
    File? idCardFile,
  }) async {
    final fields = <String, String>{
      'request_type_id': requestTypeId.toString(),
      'description': requestText,
    };

    if (prevStopsCount != null && prevStopsCount.isNotEmpty) {
      fields['form_data[prev_stops_count]'] = prevStopsCount;
    }
    if (prevSemester != null && prevSemester.isNotEmpty) {
      fields['form_data[prev_semester]'] = prevSemester;
    }

    final files = <http.MultipartFile>[];
    if (stopFormFile != null) {
      files.add(
        await http.MultipartFile.fromPath('suspension_form', stopFormFile.path),
      );
    }
    if (idCardFile != null) {
      files.add(
        await http.MultipartFile.fromPath('university_id', idCardFile.path),
      );
    }

    return await _apiClient.postMultipart(
      ApiConstants.reEnrollment,
      fields: fields,
      files: files,
    );
  }

  // ── تظلم درجة ─────────────────────────────────────────────────────────────
  /// يرسل طلب تظلم درجة مع قائمة المقررات وسبب التظلم
  Future<Map<String, dynamic>> submitGrievance({
    required int requestTypeId,
    required String college,
    required String major,
    required String level,
    required String academicYear,
    required String semester,
    required List<String> courseNames,
    required String reason,
  }) async {
    final fields = <String, String>{
      'request_type_id': requestTypeId.toString(),
      'form_data[college]': college,
      'form_data[major]': major,
      'form_data[level]': level,
      'form_data[academic_year]': academicYear,
      'form_data[semester]': semester,
      'form_data[reason]': reason,
    };

    for (int i = 0; i < courseNames.length; i++) {
      fields['form_data[courses][$i]'] = courseNames[i];
    }

    return await _apiClient.postMultipart(
      ApiConstants.serviceRequests,
      fields: fields,
      files: [],
    );
  }

  // ── سداد الرسوم ───────────────────────────────────────────────────────────
  /// يرسل طلب سداد رسوم مع إيصال الدفع
  Future<Map<String, dynamic>> submitPayment({
    required double amount,
    required String purpose,
    required String refNumber,
    required File receiptFile,
  }) async {
    final fields = <String, String>{
      'amount': amount.toString(),
      'purpose': purpose,
      'ref_number': refNumber,
    };

    final files = [
      await http.MultipartFile.fromPath('receipt_image', receiptFile.path),
    ];

    return await _apiClient.postMultipart(
      ApiConstants.payments,
      fields: fields,
      files: files,
    );
  }

  // ── جلب المقررات ────────────────────────────────────────────────────────────
  Future<List<dynamic>> getCourses({int? programId}) async {
    final Map<String, String> queryParams = {};
    if (programId != null) {
      queryParams['program_id'] = programId.toString();
    }
    final response = await _apiClient.get('/courses', queryParams: queryParams);
    return response['data'] ?? [];
  }

  // ── تقديم تظلم جديد ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> submitAppeal({
    required int semesterId,
    required String academicYear,
    required String term,
    required String studentNote,
    required List<int> courseIds,
  }) async {
    final items = courseIds.map((id) => {'course_id': id}).toList();
    final body = {
      'semester_id': semesterId,
      'academic_year': academicYear,
      'term': term,
      'student_note': studentNote,
      'items': items,
    };
    return await _apiClient.post(ApiConstants.appeals, body: body);
  }

  // ── سداد رسوم التظلم ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> submitAppealPayment({
    required int appealId,
    required int semesterId,
    required double amount,
    required File receiptFile,
  }) async {
    final fields = <String, String>{
      'appeal_id': appealId.toString(),
      'semester_id': semesterId.toString(),
      'amount': amount.toString(),
    };

    final files = [
      await http.MultipartFile.fromPath('receipt_image', receiptFile.path),
    ];

    return await _apiClient.postMultipart(
      ApiConstants.appealsPay,
      fields: fields,
      files: files,
    );
  }

  // ── جلب طلباتي ────────────────────────────────────────────────────────────
  Future<List<dynamic>> getMyRequests() async {
    final response = await _apiClient.get(ApiConstants.myRequests);
    return response['data'] ?? [];
  }

  // ── جلب أنواع الطلبات المتاحة ─────────────────────────────────────────────
  Future<List<dynamic>> getActiveRequestTypes() async {
    final response = await _apiClient.get(ApiConstants.requestTypes);
    return response['data'] ?? [];
  }

  // ── جلب الفصول الدراسية ────────────────────────────────────────────────────
  /// Returns all semesters with their dates (start, end, exams, appeals).
  Future<List<dynamic>> getSemesters() async {
    final response = await _apiClient.get(ApiConstants.semesters);
    return response['data'] ?? [];
  }
}
