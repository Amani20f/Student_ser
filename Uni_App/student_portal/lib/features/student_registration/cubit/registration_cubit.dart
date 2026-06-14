
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:university_app/core/network/api_client.dart';
import '../models/registration_data.dart';

part 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit() : super(const RegistrationState());

  void updateData(RegistrationData newData) {
    emit(state.copyWith(data: newData));
  }

  void nextStep() {
    if (state.currentStep < 6) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void jumpToStep(int step) {
    if (step >= 0 && step <= 6) {
      emit(state.copyWith(currentStep: step));
    }
  }

  Future<void> submitRegistration() async {
    emit(state.copyWith(status: RegistrationStatus.submitting));
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiClient = ApiClient(prefs);
      final data = state.data;

      if (data.academicDesires.isEmpty || data.academicDesires.first.major == null) {
        emit(state.copyWith(
          status: RegistrationStatus.failure,
          errorMessage: 'يرجى اختيار التخصص (الرغبة الأكاديمية الأولى)',
        ));
        return;
      }

      if (data.profilePicturePath == null ||
          data.identityDocumentPath == null ||
          data.certificatePath == null ||
          data.receiptPath == null) {
        emit(state.copyWith(
          status: RegistrationStatus.failure,
          errorMessage: 'يجب إرفاق جميع المستندات المطلوبة (الصورة الشخصية، الهوية، الشهادة، وسند الرسوم)',
        ));
        return;
      }

      // Map RegistrationData to API fields
      final fields = <String, String>{
        'full_name'          : '${data.fullNameAr} (${data.fullNameEn})'.trim(),
        'national_id_number' : data.identityNumber ?? '',
        'date_of_birth'      : data.dateOfBirth != null
            ? '${data.dateOfBirth!.year}-${data.dateOfBirth!.month.toString().padLeft(2, '0')}-${data.dateOfBirth!.day.toString().padLeft(2, '0')}'
            : '',
        'gender'             : data.gender == Gender.male ? 'male' : 'female',
        'nationality'        : data.nationality,
        'phone_number'       : data.mobileNumber != null ? '${data.mobileCountryCode}${data.mobileNumber}' : '',
        'email_address'      : data.email ?? '',
        'address'            : data.homeAddress ?? '',
        'desired_program_id' : data.academicDesires.first.major!.id.toString(),
        'desired_academic_level' : '1',
        // Extra data stored in form_responses (JSON)
        'form_responses'     : _buildFormResponsesJson(data),
      };

      final files = <http.MultipartFile>[];
      if (data.profilePicturePath != null) {
        final file = File(data.profilePicturePath!);
        if (await file.exists()) {
          files.add(await http.MultipartFile.fromPath('personal_photo', file.path));
        }
      }
      if (data.identityDocumentPath != null) {
        final file = File(data.identityDocumentPath!);
        if (await file.exists()) {
          files.add(await http.MultipartFile.fromPath('identity_document', file.path));
        }
      }
      if (data.certificatePath != null) {
        final file = File(data.certificatePath!);
        if (await file.exists()) {
          files.add(await http.MultipartFile.fromPath('qualification_document', file.path));
        }
      }
      if (data.receiptPath != null) {
        final file = File(data.receiptPath!);
        if (await file.exists()) {
          files.add(await http.MultipartFile.fromPath('payment_receipt', file.path));
        }
      }

      final response = await apiClient.postMultipart('/apply', fields: fields, files: files);

      emit(state.copyWith(
        status: RegistrationStatus.success,
        applicationNumber: response['application_number'],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RegistrationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  String _buildFormResponsesJson(RegistrationData data) {
    final Map<String, dynamic> extra = {
      'full_name_ar'         : data.fullNameAr,
      'full_name_en'         : data.fullNameEn,
      'marital_status'       : data.maritalStatus,
      'blood_type'           : data.bloodType,
      'governorate'          : data.governorate,
      'district'             : data.district,
      'is_employed'          : data.isEmployed,
      'job_title'            : data.jobTitle,
      'previous_major'       : data.previousMajor,
      'seat_number'          : data.seatNumber,
      'grade_percentage'     : data.gradePercentage,
      'graduation_year'      : data.graduationYear,
      'graduation_location'  : data.graduationLocation,
      'academic_desires'     : data.academicDesires.map((d) => {
        'college'     : d.college?.name,
        'major'       : d.major?.name,
        'degree_level': d.degreeLevel?.name,
      }).toList(),
      'whatsapp_number'      : data.whatsappNumber != null ? '${data.whatsappCountryCode}${data.whatsappNumber}' : null,
      'landline'             : data.landline,
      'guardian_name'        : data.guardianName,
      'guardian_relationship': data.guardianRelationship,
      'guardian_mobile'      : data.guardianMobile,
      'marketing_channel'    : data.marketingChannel,
      'reason_for_choosing'  : data.reasonForChoosing,
    };
    // Serialize as JSON string using dart:convert
    return jsonEncode(extra);
  }
}
