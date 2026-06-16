import 'package:equatable/equatable.dart';

class ApplicationModel extends Equatable {
  final int id;
  final String applicationNumber;
  final String fullName;
  final String? nationalIdNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? phoneNumber;
  final String? emailAddress;
  final String? address;
  final String? status;
  final String? desiredProgram;
  final String? department;
  final String? college;
  final String? submittedAt;
  final String? rejectionReason;
  
  // Document URLs
  final String? identityDocumentUrl;
  final String? qualificationDocumentUrl;
  final String? personalPhotoUrl;

  final bool hasIdentityDoc;
  final bool hasQualification;
  final bool hasPhoto;

  // Academic preferences fields
  final int? firstChoiceProgramId;
  final String? firstChoiceProgramName;
  final String? firstChoiceProgramDept;
  final String? firstChoiceProgramCollege;

  final int? secondChoiceProgramId;
  final String? secondChoiceProgramName;
  final String? secondChoiceProgramDept;
  final String? secondChoiceProgramCollege;

  final int? thirdChoiceProgramId;
  final String? thirdChoiceProgramName;
  final String? thirdChoiceProgramDept;
  final String? thirdChoiceProgramCollege;

  final int? approvedProgramId;
  final String? approvedProgramName;

  const ApplicationModel({
    required this.id,
    required this.applicationNumber,
    required this.fullName,
    this.nationalIdNumber,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.phoneNumber,
    this.emailAddress,
    this.address,
    this.status,
    this.desiredProgram,
    this.department,
    this.college,
    this.submittedAt,
    this.rejectionReason,
    this.identityDocumentUrl,
    this.qualificationDocumentUrl,
    this.personalPhotoUrl,
    this.hasIdentityDoc = false,
    this.hasQualification = false,
    this.hasPhoto = false,
    this.firstChoiceProgramId,
    this.firstChoiceProgramName,
    this.firstChoiceProgramDept,
    this.firstChoiceProgramCollege,
    this.secondChoiceProgramId,
    this.secondChoiceProgramName,
    this.secondChoiceProgramDept,
    this.secondChoiceProgramCollege,
    this.thirdChoiceProgramId,
    this.thirdChoiceProgramName,
    this.thirdChoiceProgramDept,
    this.thirdChoiceProgramCollege,
    this.approvedProgramId,
    this.approvedProgramName,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    print('### [Log] ApplicationModel.fromJson parsing application_number: ${json['application_number']}');
    try {
      int? firstChoiceProgramId;
      String? firstChoiceProgramName;
      String? firstChoiceProgramDept;
      String? firstChoiceProgramCollege;

      if (json['first_choice_program'] is Map) {
        final fcp = json['first_choice_program'] as Map<String, dynamic>;
        firstChoiceProgramId = fcp['id'] as int?;
        firstChoiceProgramName = fcp['name'];
        firstChoiceProgramDept = fcp['department'];
        firstChoiceProgramCollege = fcp['college'];
      } else if (json['first_choice_program'] is String) {
        firstChoiceProgramName = json['first_choice_program'];
      }

      int? secondChoiceProgramId;
      String? secondChoiceProgramName;
      String? secondChoiceProgramDept;
      String? secondChoiceProgramCollege;

      if (json['second_choice_program'] is Map) {
        final scp = json['second_choice_program'] as Map<String, dynamic>;
        secondChoiceProgramId = scp['id'] as int?;
        secondChoiceProgramName = scp['name'];
        secondChoiceProgramDept = scp['department'];
        secondChoiceProgramCollege = scp['college'];
      } else if (json['second_choice_program'] is String) {
        secondChoiceProgramName = json['second_choice_program'];
      }

      int? thirdChoiceProgramId;
      String? thirdChoiceProgramName;
      String? thirdChoiceProgramDept;
      String? thirdChoiceProgramCollege;

      if (json['third_choice_program'] is Map) {
        final tcp = json['third_choice_program'] as Map<String, dynamic>;
        thirdChoiceProgramId = tcp['id'] as int?;
        thirdChoiceProgramName = tcp['name'];
        thirdChoiceProgramDept = tcp['department'];
        thirdChoiceProgramCollege = tcp['college'];
      } else if (json['third_choice_program'] is String) {
        thirdChoiceProgramName = json['third_choice_program'];
      }

      int? approvedProgramId;
      String? approvedProgramName;

      if (json['approved_program'] is Map) {
        final ap = json['approved_program'] as Map<String, dynamic>;
        approvedProgramId = ap['id'] as int?;
        approvedProgramName = ap['name'];
      } else if (json['approved_program'] is String) {
        approvedProgramName = json['approved_program'];
      }

      final model = ApplicationModel(
        id: json['id'] as int,
        applicationNumber: json['application_number'] ?? '',
        fullName: json['full_name'] ?? '',
        nationalIdNumber: json['national_id_number'],
        dateOfBirth: json['date_of_birth'],
        gender: json['gender'],
        nationality: json['nationality'],
        phoneNumber: json['phone_number'],
        emailAddress: json['email_address'],
        address: json['address'],
        status: json['status'],
        desiredProgram: json['desired_program'],
        department: json['department'],
        college: json['college'],
        submittedAt: json['submitted_at'],
        rejectionReason: json['rejection_reason'],
        identityDocumentUrl: json['identity_document_url'],
        qualificationDocumentUrl: json['qualification_document_url'],
        personalPhotoUrl: json['personal_photo_url'],
        hasIdentityDoc: json['has_identity_doc'] ?? false,
        hasQualification: json['has_qualification'] ?? false,
        hasPhoto: json['has_photo'] ?? false,
        firstChoiceProgramId: firstChoiceProgramId,
        firstChoiceProgramName: firstChoiceProgramName,
        firstChoiceProgramDept: firstChoiceProgramDept,
        firstChoiceProgramCollege: firstChoiceProgramCollege,
        secondChoiceProgramId: secondChoiceProgramId,
        secondChoiceProgramName: secondChoiceProgramName,
        secondChoiceProgramDept: secondChoiceProgramDept,
        secondChoiceProgramCollege: secondChoiceProgramCollege,
        thirdChoiceProgramId: thirdChoiceProgramId,
        thirdChoiceProgramName: thirdChoiceProgramName,
        thirdChoiceProgramDept: thirdChoiceProgramDept,
        thirdChoiceProgramCollege: thirdChoiceProgramCollege,
        approvedProgramId: approvedProgramId,
        approvedProgramName: approvedProgramName,
      );
      print('### [Log] ApplicationModel.fromJson SUCCESS for id: ${model.id}');
      return model;
    } catch (e) {
      print('### [Log] ApplicationModel.fromJson ERROR for json: $json \nError: $e');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [
        id,
        applicationNumber,
        fullName,
        nationalIdNumber,
        dateOfBirth,
        gender,
        nationality,
        phoneNumber,
        emailAddress,
        address,
        status,
        desiredProgram,
        department,
        college,
        submittedAt,
        rejectionReason,
        identityDocumentUrl,
        qualificationDocumentUrl,
        personalPhotoUrl,
        hasIdentityDoc,
        hasQualification,
        hasPhoto,
        firstChoiceProgramId,
        firstChoiceProgramName,
        firstChoiceProgramDept,
        firstChoiceProgramCollege,
        secondChoiceProgramId,
        secondChoiceProgramName,
        secondChoiceProgramDept,
        secondChoiceProgramCollege,
        thirdChoiceProgramId,
        thirdChoiceProgramName,
        thirdChoiceProgramDept,
        thirdChoiceProgramCollege,
        approvedProgramId,
        approvedProgramName,
      ];
}
