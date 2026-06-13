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
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
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
    );
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
      ];
}
