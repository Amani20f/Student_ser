import 'package:equatable/equatable.dart';

enum Gender { male, female }

enum Sector { government, private }

enum DegreeLevel { bachelor, diploma }

class AcademicDesire extends Equatable {
  final String? college;
  final String? major;
  final DegreeLevel? degreeLevel;

  const AcademicDesire({this.college, this.major, this.degreeLevel});

  AcademicDesire copyWith({
    String? college,
    String? major,
    DegreeLevel? degreeLevel,
  }) {
    return AcademicDesire(
      college: college ?? this.college,
      major: major ?? this.major,
      degreeLevel: degreeLevel ?? this.degreeLevel,
    );
  }

  @override
  List<Object?> get props => [college, major, degreeLevel];
}

class RegistrationData extends Equatable {
  // 1. Basic Personal Information
  final String fullNameAr;
  final String fullNameEn;
  final Gender? gender;
  final String nationality;
  final String maritalStatus;
  final String bloodType;
  final DateTime? dateOfBirth;
  final String governorate;
  final String district;
  final String? profilePicturePath;
  final String? certificatePath;

  // 2. Employment Status
  final bool isEmployed;
  final Sector? sector;
  final String? jobTitle;

  // 3. Previous Academic Qualifications
  final String? previousMajor;
  final String? seatNumber;
  final double? gradePercentage;
  final String? graduationYear;
  final String? graduationLocation;
  final String? awardingBody;

  // 4. Academic Desires (3 Choices)
  final List<AcademicDesire> academicDesires;

  // 5. Identity & Contact Information
  final String? identityType;
  final String? identityNumber;
  final String? issuePlace;
  final DateTime? issueDate;
  final String? mobileNumber;
  final String? whatsappNumber;
  final String? email;
  final String? homeAddress;
  final String? landline;

  // 6. Guardian Information
  final String? guardianName;
  final String? guardianRelationship;
  final String? guardianOccupation;
  final String? guardianMobile;
  final String? guardianLandline;

  // 7. Marketing & Survey
  final String? marketingChannel;
  final String? reasonForChoosing;

  // 8. Declaration & Confirmation
  final bool declarationChecked;
  final String? signaturePath;
  final String? receiptPath;

  const RegistrationData({
    this.fullNameAr = '',
    this.fullNameEn = '',
    this.gender,
    this.nationality = '',
    this.maritalStatus = '',
    this.bloodType = '',
    this.dateOfBirth,
    this.governorate = '',
    this.district = '',
    this.profilePicturePath,
    this.certificatePath,
    this.isEmployed = false,
    this.sector,
    this.jobTitle,
    this.previousMajor,
    this.seatNumber,
    this.gradePercentage,
    this.graduationYear,
    this.graduationLocation,
    this.awardingBody,
    this.academicDesires = const [
      AcademicDesire(),
      AcademicDesire(),
      AcademicDesire(),
    ],
    this.identityType,
    this.identityNumber,
    this.issuePlace,
    this.issueDate,
    this.mobileNumber,
    this.whatsappNumber,
    this.email,
    this.homeAddress,
    this.landline,
    this.guardianName,
    this.guardianRelationship,
    this.guardianOccupation,
    this.guardianMobile,
    this.guardianLandline,
    this.marketingChannel,
    this.reasonForChoosing,
    this.declarationChecked = false,
    this.signaturePath,
    this.receiptPath,
  });

  RegistrationData copyWith({
    String? fullNameAr,
    String? fullNameEn,
    Gender? gender,
    String? nationality,
    String? maritalStatus,
    String? bloodType,
    DateTime? dateOfBirth,
    String? governorate,
    String? district,
    String? profilePicturePath,
    String? certificatePath,
    bool? isEmployed,
    Sector? sector,
    String? jobTitle,
    String? previousMajor,
    String? seatNumber,
    double? gradePercentage,
    String? graduationYear,
    String? graduationLocation,
    String? awardingBody,
    List<AcademicDesire>? academicDesires,
    String? identityType,
    String? identityNumber,
    String? issuePlace,
    DateTime? issueDate,
    String? mobileNumber,
    String? whatsappNumber,
    String? email,
    String? homeAddress,
    String? landline,
    String? guardianName,
    String? guardianRelationship,
    String? guardianOccupation,
    String? guardianMobile,
    String? guardianLandline,
    String? marketingChannel,
    String? reasonForChoosing,
    bool? declarationChecked,
    String? signaturePath,
    String? receiptPath,
  }) {
    return RegistrationData(
      fullNameAr: fullNameAr ?? this.fullNameAr,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      bloodType: bloodType ?? this.bloodType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      certificatePath: certificatePath ?? this.certificatePath,
      isEmployed: isEmployed ?? this.isEmployed,
      sector: sector ?? this.sector,
      jobTitle: jobTitle ?? this.jobTitle,
      previousMajor: previousMajor ?? this.previousMajor,
      seatNumber: seatNumber ?? this.seatNumber,
      gradePercentage: gradePercentage ?? this.gradePercentage,
      graduationYear: graduationYear ?? this.graduationYear,
      graduationLocation: graduationLocation ?? this.graduationLocation,
      awardingBody: awardingBody ?? this.awardingBody,
      academicDesires: academicDesires ?? this.academicDesires,
      identityType: identityType ?? this.identityType,
      identityNumber: identityNumber ?? this.identityNumber,
      issuePlace: issuePlace ?? this.issuePlace,
      issueDate: issueDate ?? this.issueDate,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      homeAddress: homeAddress ?? this.homeAddress,
      landline: landline ?? this.landline,
      guardianName: guardianName ?? this.guardianName,
      guardianRelationship: guardianRelationship ?? this.guardianRelationship,
      guardianOccupation: guardianOccupation ?? this.guardianOccupation,
      guardianMobile: guardianMobile ?? this.guardianMobile,
      guardianLandline: guardianLandline ?? this.guardianLandline,
      marketingChannel: marketingChannel ?? this.marketingChannel,
      reasonForChoosing: reasonForChoosing ?? this.reasonForChoosing,
      declarationChecked: declarationChecked ?? this.declarationChecked,
      signaturePath: signaturePath ?? this.signaturePath,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }

  @override
  List<Object?> get props => [
    fullNameAr,
    fullNameEn,
    gender,
    nationality,
    maritalStatus,
    bloodType,
    dateOfBirth,
    governorate,
    district,
    profilePicturePath,
    certificatePath,
    isEmployed,
    sector,
    jobTitle,
    previousMajor,
    seatNumber,
    gradePercentage,
    graduationYear,
    graduationLocation,
    awardingBody,
    academicDesires,
    identityType,
    identityNumber,
    issuePlace,
    issueDate,
    mobileNumber,
    whatsappNumber,
    email,
    homeAddress,
    landline,
    guardianName,
    guardianRelationship,
    guardianOccupation,
    guardianMobile,
    guardianLandline,
    marketingChannel,
    reasonForChoosing,
    declarationChecked,
    signaturePath,
    receiptPath,
  ];
}
