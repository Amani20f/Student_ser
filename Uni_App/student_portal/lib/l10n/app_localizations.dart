import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'University App'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'Username must contain only letters'**
  String get usernameLettersOnly;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @newStudentRegistration.
  ///
  /// In en, this message translates to:
  /// **'New Student Registration'**
  String get newStudentRegistration;

  /// No description provided for @verifyReferenceRequest.
  ///
  /// In en, this message translates to:
  /// **'Verify Reference Request'**
  String get verifyReferenceRequest;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter your new password below.'**
  String get changePasswordDescription;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @updatePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePasswordButton;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password Changed Successfully!'**
  String get passwordChangedSuccess;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @highSchoolGpa.
  ///
  /// In en, this message translates to:
  /// **'High School GPA (%)'**
  String get highSchoolGpa;

  /// No description provided for @selectMajor.
  ///
  /// In en, this message translates to:
  /// **'Select Major'**
  String get selectMajor;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Attach High School Certificate'**
  String get uploadDocuments;

  /// No description provided for @uploadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload Receipt'**
  String get uploadReceipt;

  /// No description provided for @uploadPhotos.
  ///
  /// In en, this message translates to:
  /// **'Attach Photos'**
  String get uploadPhotos;

  /// No description provided for @submitRegistration.
  ///
  /// In en, this message translates to:
  /// **'Submit Registration'**
  String get submitRegistration;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful!'**
  String get registrationSuccessful;

  /// No description provided for @applicationReceived.
  ///
  /// In en, this message translates to:
  /// **'Your application has been received. Please save your Reference ID for future inquiries.'**
  String get applicationReceived;

  /// No description provided for @referenceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference ID'**
  String get referenceIdLabel;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help? Contact Technical Support: '**
  String get needHelp;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @notifCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String notifCount(Object count);

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @studentName.
  ///
  /// In en, this message translates to:
  /// **'Nora Ahmed'**
  String get studentName;

  /// No description provided for @studentId.
  ///
  /// In en, this message translates to:
  /// **'ID: 20241010'**
  String get studentId;

  /// No description provided for @studentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentIdLabel;

  /// No description provided for @majorLabel.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get majorLabel;

  /// No description provided for @gpaLabel.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get gpaLabel;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @majorValue.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get majorValue;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get navAnnouncements;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @collegeIT.
  ///
  /// In en, this message translates to:
  /// **'College of IT'**
  String get collegeIT;

  /// No description provided for @collegeEngineering.
  ///
  /// In en, this message translates to:
  /// **'College of Engineering'**
  String get collegeEngineering;

  /// No description provided for @collegeBusiness.
  ///
  /// In en, this message translates to:
  /// **'College of Business'**
  String get collegeBusiness;

  /// No description provided for @majorCS.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get majorCS;

  /// No description provided for @majorIT.
  ///
  /// In en, this message translates to:
  /// **'IT'**
  String get majorIT;

  /// No description provided for @majorSE.
  ///
  /// In en, this message translates to:
  /// **'Software Engineering'**
  String get majorSE;

  /// No description provided for @majorCE.
  ///
  /// In en, this message translates to:
  /// **'Civil Engineering'**
  String get majorCE;

  /// No description provided for @majorAccounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get majorAccounting;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @academicInfo.
  ///
  /// In en, this message translates to:
  /// **'Academic Information'**
  String get academicInfo;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @nationalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalIdLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @stepPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get stepPersonalInfo;

  /// No description provided for @stepEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get stepEmployment;

  /// No description provided for @stepAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get stepAcademic;

  /// No description provided for @stepDesires.
  ///
  /// In en, this message translates to:
  /// **'Desires'**
  String get stepDesires;

  /// No description provided for @stepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get stepContact;

  /// No description provided for @stepGuardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get stepGuardian;

  /// No description provided for @stepMarketing.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get stepMarketing;

  /// No description provided for @stepDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Declaration'**
  String get stepDeclaration;

  /// No description provided for @fullNameAr.
  ///
  /// In en, this message translates to:
  /// **'Full Name (Arabic)'**
  String get fullNameAr;

  /// No description provided for @fullNameEn.
  ///
  /// In en, this message translates to:
  /// **'Full Name (English)'**
  String get fullNameEn;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @maritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalStatus;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @isEmployed.
  ///
  /// In en, this message translates to:
  /// **'Are you currently employed?'**
  String get isEmployed;

  /// No description provided for @sector.
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get sector;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @previousQualification.
  ///
  /// In en, this message translates to:
  /// **'Previous Qualification'**
  String get previousQualification;

  /// No description provided for @majorSpecialization.
  ///
  /// In en, this message translates to:
  /// **'Major/Specialization'**
  String get majorSpecialization;

  /// No description provided for @seatNumber.
  ///
  /// In en, this message translates to:
  /// **'Seat Number'**
  String get seatNumber;

  /// No description provided for @gradePercentage.
  ///
  /// In en, this message translates to:
  /// **'Grade/Percentage %'**
  String get gradePercentage;

  /// No description provided for @graduationYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation Year'**
  String get graduationYear;

  /// No description provided for @graduationLocation.
  ///
  /// In en, this message translates to:
  /// **'Graduation Location'**
  String get graduationLocation;

  /// No description provided for @awardingBody.
  ///
  /// In en, this message translates to:
  /// **'Awarding Body/School'**
  String get awardingBody;

  /// No description provided for @academicDesire1.
  ///
  /// In en, this message translates to:
  /// **'First Choice'**
  String get academicDesire1;

  /// No description provided for @academicDesire2.
  ///
  /// In en, this message translates to:
  /// **'Second Choice'**
  String get academicDesire2;

  /// No description provided for @academicDesire3.
  ///
  /// In en, this message translates to:
  /// **'Third Choice'**
  String get academicDesire3;

  /// No description provided for @college.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get college;

  /// No description provided for @degreeLevel.
  ///
  /// In en, this message translates to:
  /// **'Degree Level'**
  String get degreeLevel;

  /// No description provided for @bachelor.
  ///
  /// In en, this message translates to:
  /// **'Bachelor'**
  String get bachelor;

  /// No description provided for @diploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get diploma;

  /// No description provided for @identityType.
  ///
  /// In en, this message translates to:
  /// **'ID Type'**
  String get identityType;

  /// No description provided for @identityNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get identityNumber;

  /// No description provided for @issuePlace.
  ///
  /// In en, this message translates to:
  /// **'Issue Place'**
  String get issuePlace;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsappNumber;

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get homeAddress;

  /// No description provided for @landline.
  ///
  /// In en, this message translates to:
  /// **'Landline'**
  String get landline;

  /// No description provided for @guardianName.
  ///
  /// In en, this message translates to:
  /// **'Guardian Name'**
  String get guardianName;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @guardianOccupation.
  ///
  /// In en, this message translates to:
  /// **'Guardian Occupation'**
  String get guardianOccupation;

  /// No description provided for @marketingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How did you hear about us?'**
  String get marketingQuestion;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friend;

  /// No description provided for @relative.
  ///
  /// In en, this message translates to:
  /// **'Relative'**
  String get relative;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @universityStudent.
  ///
  /// In en, this message translates to:
  /// **'University Student'**
  String get universityStudent;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get twitter;

  /// No description provided for @radioTv.
  ///
  /// In en, this message translates to:
  /// **'Radio/TV'**
  String get radioTv;

  /// No description provided for @billboards.
  ///
  /// In en, this message translates to:
  /// **'Billboards'**
  String get billboards;

  /// No description provided for @reasonForChoosing.
  ///
  /// In en, this message translates to:
  /// **'Reason for choosing us'**
  String get reasonForChoosing;

  /// No description provided for @declarationText.
  ///
  /// In en, this message translates to:
  /// **'I hereby declare that all the information provided above is true and correct to the best of my knowledge and belief.'**
  String get declarationText;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @clearSignature.
  ///
  /// In en, this message translates to:
  /// **'Clear Signature'**
  String get clearSignature;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalidEmail;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid Number'**
  String get invalidNumber;

  /// No description provided for @scientific.
  ///
  /// In en, this message translates to:
  /// **'Scientific'**
  String get scientific;

  /// No description provided for @literary.
  ///
  /// In en, this message translates to:
  /// **'Literary'**
  String get literary;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @identityInfo.
  ///
  /// In en, this message translates to:
  /// **'Identity Information'**
  String get identityInfo;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @guardianInfo.
  ///
  /// In en, this message translates to:
  /// **'Guardian Information'**
  String get guardianInfo;

  /// No description provided for @marketingInfo.
  ///
  /// In en, this message translates to:
  /// **'Marketing Information'**
  String get marketingInfo;

  /// No description provided for @declaration.
  ///
  /// In en, this message translates to:
  /// **'Declaration'**
  String get declaration;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @married.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get married;

  /// No description provided for @divorced.
  ///
  /// In en, this message translates to:
  /// **'Divorced'**
  String get divorced;

  /// No description provided for @widowed.
  ///
  /// In en, this message translates to:
  /// **'Widowed'**
  String get widowed;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordLockedMsg.
  ///
  /// In en, this message translates to:
  /// **'Cannot change password before 90 days'**
  String get passwordLockedMsg;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} days remaining'**
  String daysRemaining(Object count);

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @registrationFeeWarning.
  ///
  /// In en, this message translates to:
  /// **'The information you entered will not be accepted until the registration fees are paid.'**
  String get registrationFeeWarning;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or university ID to verify your identity.'**
  String get forgotPasswordDesc;

  /// No description provided for @emailOrIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Email / University ID'**
  String get emailOrIdLabel;

  /// No description provided for @verifyIdentityButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Identity'**
  String get verifyIdentityButton;

  /// No description provided for @identityVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Identity verified successfully!'**
  String get identityVerifiedSuccess;

  /// No description provided for @mandatoryPasswordNotice.
  ///
  /// In en, this message translates to:
  /// **'Note: The new password will be your permanent password that you will use to log in next time. The password you used to log in now is only a temporary password.'**
  String get mandatoryPasswordNotice;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllNotifications;

  /// No description provided for @noNotificationsMsg.
  ///
  /// In en, this message translates to:
  /// **'No new notifications at the moment'**
  String get noNotificationsMsg;

  /// No description provided for @registrationSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Your application has been received. Please keep the reference number for future inquiries.'**
  String get registrationSuccessDesc;

  /// No description provided for @referenceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get referenceNumberLabel;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'We are here to help! You can contact us through any of the following channels:'**
  String get supportMessage;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @whatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @dummyNotification1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the University App!'**
  String get dummyNotification1Title;

  /// No description provided for @dummyNotification1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap here to explore features.'**
  String get dummyNotification1Subtitle;

  /// No description provided for @dummyNotification2Title.
  ///
  /// In en, this message translates to:
  /// **'System Update'**
  String get dummyNotification2Title;

  /// No description provided for @dummyNotification2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'New features added to schedule view.'**
  String get dummyNotification2Subtitle;

  /// No description provided for @dummyNotification3Title.
  ///
  /// In en, this message translates to:
  /// **'Registration Deadline'**
  String get dummyNotification3Title;

  /// No description provided for @dummyNotification3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please complete your documents by tomorrow.'**
  String get dummyNotification3Subtitle;

  /// No description provided for @contactUniversity.
  ///
  /// In en, this message translates to:
  /// **'Contact University'**
  String get contactUniversity;

  /// No description provided for @major.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get major;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Academic Level'**
  String get level;

  /// No description provided for @semester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semester;

  /// No description provided for @academicYear.
  ///
  /// In en, this message translates to:
  /// **'Academic Year'**
  String get academicYear;

  /// No description provided for @grievanceFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Grievance Form'**
  String get grievanceFormTitle;

  /// No description provided for @studentInfo.
  ///
  /// In en, this message translates to:
  /// **'Student Information'**
  String get studentInfo;

  /// No description provided for @grievanceDetails.
  ///
  /// In en, this message translates to:
  /// **'Grievance Details'**
  String get grievanceDetails;

  /// No description provided for @grievanceResultsRequest.
  ///
  /// In en, this message translates to:
  /// **'Results Grievance Request'**
  String get grievanceResultsRequest;

  /// No description provided for @courseName.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get courseName;

  /// No description provided for @addCourse.
  ///
  /// In en, this message translates to:
  /// **'Add Course'**
  String get addCourse;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInfo;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @uploadAttachments.
  ///
  /// In en, this message translates to:
  /// **'Upload Attachments'**
  String get uploadAttachments;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get payment;

  /// No description provided for @grievanceFee.
  ///
  /// In en, this message translates to:
  /// **'Grievance Fee: 10 USD'**
  String get grievanceFee;

  /// No description provided for @uploadPaymentReceipt.
  ///
  /// In en, this message translates to:
  /// **'Upload Payment Receipt'**
  String get uploadPaymentReceipt;

  /// No description provided for @submitGrievance.
  ///
  /// In en, this message translates to:
  /// **'Submit Grievance'**
  String get submitGrievance;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillRequiredFields;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @successMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request is under review. You will receive a reply via email.'**
  String get successMessage;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @viewSchedule.
  ///
  /// In en, this message translates to:
  /// **'View Schedule'**
  String get viewSchedule;

  /// No description provided for @noStudySchedules.
  ///
  /// In en, this message translates to:
  /// **'No study schedules available for your current level and program.'**
  String get noStudySchedules;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @pleaseSelectMajor.
  ///
  /// In en, this message translates to:
  /// **'Please select a major (First Academic Desire)'**
  String get pleaseSelectMajor;

  /// No description provided for @idDocumentLabel.
  ///
  /// In en, this message translates to:
  /// **'Attach National ID / Iqama / Passport'**
  String get idDocumentLabel;

  /// No description provided for @arabicLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'Must contain Arabic letters only'**
  String get arabicLettersOnly;

  /// No description provided for @englishLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'Must contain English letters only'**
  String get englishLettersOnly;

  /// No description provided for @minLengthFive.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 5 characters'**
  String get minLengthFive;

  /// No description provided for @invalidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid mobile number (8 to 15 digits)'**
  String get invalidMobileNumber;

  /// No description provided for @useThisNumberForPayment.
  ///
  /// In en, this message translates to:
  /// **'You can use this number in the fee payment form for this request.'**
  String get useThisNumberForPayment;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @preliminaryRegistrationNote.
  ///
  /// In en, this message translates to:
  /// **'This is a preliminary registration and does not constitute final admission. Applicants must attend, submit all required original documents, and complete university admission procedures.'**
  String get preliminaryRegistrationNote;

  /// No description provided for @registrationSuccessAlternativeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your application has been successfully received. You can track your application status later using the National ID, Iqama, or Passport number used for registration.'**
  String get registrationSuccessAlternativeDesc;

  /// No description provided for @uploadIdentityDocument.
  ///
  /// In en, this message translates to:
  /// **'Attach National ID / Passport'**
  String get uploadIdentityDocument;

  /// No description provided for @paymentReceiptLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get paymentReceiptLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
