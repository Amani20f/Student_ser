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
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Al-Arab University'**
  String get appTitle;

  /// No description provided for @dashboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardLabel;

  /// No description provided for @uniAdmin.
  ///
  /// In en, this message translates to:
  /// **'Uni Admin'**
  String get uniAdmin;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Al-Arab University'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'University Service Ecosystem'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @pendingPayments.
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @totalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudents;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeTitle(String name);

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'You are logged in as {role}.'**
  String loggedInAs(String role);

  /// No description provided for @sidebarNavHelp.
  ///
  /// In en, this message translates to:
  /// **'Use the sidebar to navigate to your assigned features.'**
  String get sidebarNavHelp;

  /// No description provided for @serviceRequests.
  ///
  /// In en, this message translates to:
  /// **'Service Requests'**
  String get serviceRequests;

  /// No description provided for @paymentVerification.
  ///
  /// In en, this message translates to:
  /// **'Payment Verification'**
  String get paymentVerification;

  /// No description provided for @gradeManagement.
  ///
  /// In en, this message translates to:
  /// **'Grade Management'**
  String get gradeManagement;

  /// No description provided for @activityLogs.
  ///
  /// In en, this message translates to:
  /// **'Activity Logs'**
  String get activityLogs;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @grades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get grades;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @failedToLoadStats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stats'**
  String get failedToLoadStats;

  /// No description provided for @failedToLoadRequests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load requests'**
  String get failedToLoadRequests;

  /// No description provided for @failedToLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payments'**
  String get failedToLoadPayments;

  /// No description provided for @failedToLoadGrades.
  ///
  /// In en, this message translates to:
  /// **'Failed to load grades'**
  String get failedToLoadGrades;

  /// No description provided for @failedToLoadLogs.
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs'**
  String get failedToLoadLogs;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @noPendingPayments.
  ///
  /// In en, this message translates to:
  /// **'No pending payments'**
  String get noPendingPayments;

  /// No description provided for @noGradesFound.
  ///
  /// In en, this message translates to:
  /// **'No grades found for this semester'**
  String get noGradesFound;

  /// No description provided for @noLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No logs found'**
  String get noLogsFound;

  /// No description provided for @studentColumn.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get studentColumn;

  /// No description provided for @amountColumn.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountColumn;

  /// No description provided for @semesterColumn.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semesterColumn;

  /// No description provided for @statusColumn.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusColumn;

  /// No description provided for @receiptColumn.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptColumn;

  /// No description provided for @actionsColumn.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsColumn;

  /// No description provided for @courseColumn.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get courseColumn;

  /// No description provided for @firstColumn.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get firstColumn;

  /// No description provided for @secondColumn.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get secondColumn;

  /// No description provided for @midtermColumn.
  ///
  /// In en, this message translates to:
  /// **'Midterm'**
  String get midtermColumn;

  /// No description provided for @finalColumn.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get finalColumn;

  /// No description provided for @totalColumn.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalColumn;

  /// No description provided for @gpaColumn.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get gpaColumn;

  /// No description provided for @updatedColumn.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedColumn;

  /// No description provided for @userColumn.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userColumn;

  /// No description provided for @actionColumn.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get actionColumn;

  /// No description provided for @modelColumn.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelColumn;

  /// No description provided for @oldValuesColumn.
  ///
  /// In en, this message translates to:
  /// **'Old Values'**
  String get oldValuesColumn;

  /// No description provided for @newValuesColumn.
  ///
  /// In en, this message translates to:
  /// **'New Values'**
  String get newValuesColumn;

  /// No description provided for @dateColumn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateColumn;

  /// No description provided for @viewAttachment.
  ///
  /// In en, this message translates to:
  /// **'View Attachment'**
  String get viewAttachment;

  /// No description provided for @hideActions.
  ///
  /// In en, this message translates to:
  /// **'Hide Actions'**
  String get hideActions;

  /// No description provided for @takeAction.
  ///
  /// In en, this message translates to:
  /// **'Take Action'**
  String get takeAction;

  /// No description provided for @adminNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Notes (Required for rejection)'**
  String get adminNotesLabel;

  /// No description provided for @enterAdminNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter admin notes...'**
  String get enterAdminNotes;

  /// No description provided for @adminNotesRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin notes are required for rejection'**
  String get adminNotesRequired;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @receiptPreview.
  ///
  /// In en, this message translates to:
  /// **'Receipt Preview'**
  String get receiptPreview;

  /// No description provided for @failedToLoadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Failed to load receipt'**
  String get failedToLoadReceipt;

  /// No description provided for @rejectPayment.
  ///
  /// In en, this message translates to:
  /// **'Reject Payment'**
  String get rejectPayment;

  /// No description provided for @reasonForRejection.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get reasonForRejection;

  /// No description provided for @enterReason.
  ///
  /// In en, this message translates to:
  /// **'Enter reason...'**
  String get enterReason;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved'**
  String get requestApproved;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get requestRejected;

  /// No description provided for @paymentVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment verified successfully'**
  String get paymentVerifiedSuccess;

  /// No description provided for @paymentRejected.
  ///
  /// In en, this message translates to:
  /// **'Payment rejected'**
  String get paymentRejected;

  /// No description provided for @gradeUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Grade updated successfully'**
  String get gradeUpdatedSuccess;

  /// No description provided for @semester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semester;

  /// No description provided for @selectSemester.
  ///
  /// In en, this message translates to:
  /// **'Select semester'**
  String get selectSemester;

  /// No description provided for @selectSemesterToView.
  ///
  /// In en, this message translates to:
  /// **'Select a semester to view grades'**
  String get selectSemesterToView;

  /// No description provided for @editGrade.
  ///
  /// In en, this message translates to:
  /// **'Edit Grade'**
  String get editGrade;

  /// No description provided for @editGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Grade — {course}'**
  String editGradeTitle(String course);

  /// No description provided for @filterByAction.
  ///
  /// In en, this message translates to:
  /// **'Filter by action:'**
  String get filterByAction;

  /// No description provided for @allActions.
  ///
  /// In en, this message translates to:
  /// **'All actions'**
  String get allActions;

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String entriesCount(int count);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Staff notifications are not yet available.'**
  String get notificationsNotAvailable;

  /// No description provided for @notificationsFuture.
  ///
  /// In en, this message translates to:
  /// **'This page is ready for future backend integration.\nOnce the staff notification endpoint is implemented, notifications will appear here.'**
  String get notificationsFuture;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// No description provided for @notApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notApplicable;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @unknownStudent.
  ///
  /// In en, this message translates to:
  /// **'Unknown Student'**
  String get unknownStudent;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleTheme;

  /// No description provided for @purposeColumn.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purposeColumn;

  /// No description provided for @timePeriod.
  ///
  /// In en, this message translates to:
  /// **'Time Period'**
  String get timePeriod;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @last24h.
  ///
  /// In en, this message translates to:
  /// **'Last 24 Hours'**
  String get last24h;

  /// No description provided for @last2days.
  ///
  /// In en, this message translates to:
  /// **'Last 2 Days'**
  String get last2days;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// No description provided for @olderThanYear.
  ///
  /// In en, this message translates to:
  /// **'Older than a year'**
  String get olderThanYear;

  /// No description provided for @studentCard.
  ///
  /// In en, this message translates to:
  /// **'Student Card No.'**
  String get studentCard;

  /// No description provided for @courseCode.
  ///
  /// In en, this message translates to:
  /// **'Course Code'**
  String get courseCode;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @searchGrades.
  ///
  /// In en, this message translates to:
  /// **'Search Grades'**
  String get searchGrades;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @selectFiltersToSearch.
  ///
  /// In en, this message translates to:
  /// **'Select filters and press Search to view results'**
  String get selectFiltersToSearch;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @manageUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage all system users — create staff accounts, update passwords, or remove users.'**
  String get manageUsersSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordFor.
  ///
  /// In en, this message translates to:
  /// **'Change Password: {name}'**
  String changePasswordFor(String name);

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This action cannot be undone.'**
  String confirmDeleteAccount(String name);

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccess;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccess;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @gradeAppeals.
  ///
  /// In en, this message translates to:
  /// **'Grade Appeals'**
  String get gradeAppeals;

  /// No description provided for @appealDetails.
  ///
  /// In en, this message translates to:
  /// **'Appeal Details'**
  String get appealDetails;

  /// No description provided for @underReviewAppeals.
  ///
  /// In en, this message translates to:
  /// **'Under Review Appeals'**
  String get underReviewAppeals;

  /// No description provided for @studentNote.
  ///
  /// In en, this message translates to:
  /// **'Student Note'**
  String get studentNote;

  /// No description provided for @committeeReport.
  ///
  /// In en, this message translates to:
  /// **'Committee Report'**
  String get committeeReport;

  /// No description provided for @beforeGrades.
  ///
  /// In en, this message translates to:
  /// **'BEFORE (Read-only)'**
  String get beforeGrades;

  /// No description provided for @afterGrades.
  ///
  /// In en, this message translates to:
  /// **'AFTER (Proposed)'**
  String get afterGrades;

  /// No description provided for @approveAppeal.
  ///
  /// In en, this message translates to:
  /// **'Approve Appeal'**
  String get approveAppeal;

  /// No description provided for @rejectAppeal.
  ///
  /// In en, this message translates to:
  /// **'Reject Appeal'**
  String get rejectAppeal;

  /// No description provided for @appealApproved.
  ///
  /// In en, this message translates to:
  /// **'Appeal approved successfully'**
  String get appealApproved;

  /// No description provided for @appealRejected.
  ///
  /// In en, this message translates to:
  /// **'Appeal rejected successfully'**
  String get appealRejected;

  /// No description provided for @failedToLoadAppeals.
  ///
  /// In en, this message translates to:
  /// **'Failed to load appeals'**
  String get failedToLoadAppeals;

  /// No description provided for @noAppealsUnderReview.
  ///
  /// In en, this message translates to:
  /// **'No appeals are currently under review'**
  String get noAppealsUnderReview;

  /// No description provided for @confirmApproveAppeal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this appeal and update the student\'s grades?'**
  String get confirmApproveAppeal;

  /// No description provided for @confirmRejectAppeal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this appeal?'**
  String get confirmRejectAppeal;

  /// No description provided for @confirmApprovePayment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to verify this payment?'**
  String get confirmApprovePayment;

  /// No description provided for @confirmRejectPayment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this payment receipt?'**
  String get confirmRejectPayment;

  /// No description provided for @verificationNotes.
  ///
  /// In en, this message translates to:
  /// **'Verification Notes'**
  String get verificationNotes;
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
      'that was used.');
}
