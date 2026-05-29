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
    required List<Map<String, dynamic>> courses, // [{course_name, day, absence_date}]
    required List<File> attachments,
  }) async {
    final fields = <String, String>{
      'request_type_id': requestTypeId.toString(),
      'form_data[college]': college,
      'form_data[major]': major,
      'form_data[level]': level,
      'form_data[semester]': semester,
      'form_data[academic_year]': academicYear,
      'form_data[absence_reason]': reason,
    };

    // إضافة بيانات المقررات كمصفوفة ضمن form_data
    for (int i = 0; i < courses.length; i++) {
      fields['form_data[courses][$i][course_name]'] = courses[i]['course_name']?.toString() ?? '';
      fields['form_data[courses][$i][day]'] = courses[i]['day']?.toString() ?? '';
      fields['form_data[courses][$i][absence_date]'] = courses[i]['absence_date']?.toString() ?? '';
    }

    final files = <http.MultipartFile>[];
    for (int i = 0; i < attachments.length; i++) {
      files.add(await http.MultipartFile.fromPath('attachments[$i]', attachments[i].path));
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
    required String yearStart,
    required String semesterTo,
    required String yearEnd,
    required String reason,
    required List<File> attachments,
  }) async {
    final fields = <String, String>{
      'request_type_id': requestTypeId.toString(),
      'form_data[year_start]': yearStart,
      'form_data[semester_to]': semesterTo,
      'form_data[year_end]': yearEnd,
      'form_data[reason]': reason,
    };

    final files = <http.MultipartFile>[];
    for (int i = 0; i < attachments.length; i++) {
      files.add(await http.MultipartFile.fromPath('attachments[$i]', attachments[i].path));
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
    required String prevStopsCount,
    required String prevSemester,
    required String requestText,
    File? stopFormFile,
    File? idCardFile,
  }) async {
    final fields = <String, String>{
      'request_type_id': requestTypeId.toString(),
      'form_data[prev_stops_count]': prevStopsCount,
      'form_data[prev_semester]': prevSemester,
      'form_data[request_text]': requestText,
    };

    final files = <http.MultipartFile>[];
    if (stopFormFile != null) {
      files.add(await http.MultipartFile.fromPath('stop_form', stopFormFile.path));
    }
    if (idCardFile != null) {
      files.add(await http.MultipartFile.fromPath('id_card', idCardFile.path));
    }

    return await _apiClient.postMultipart(
      ApiConstants.serviceRequests,
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

  // ── جلب طلباتي ────────────────────────────────────────────────────────────
  Future<List<dynamic>> getMyRequests() async {
    final response = await _apiClient.get(ApiConstants.myRequests);
    return response['data'] ?? [];
  }
}
