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
  /// **'No data is currently displayed.\nUse the filters above to search and view results.'**
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

  /// No description provided for @programsLabel.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programsLabel;

  /// No description provided for @studyPlansLabel.
  ///
  /// In en, this message translates to:
  /// **'Study Plans'**
  String get studyPlansLabel;

  /// No description provided for @serviceManagementLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Management'**
  String get serviceManagementLabel;

  /// No description provided for @programsManagement.
  ///
  /// In en, this message translates to:
  /// **'Programs Management'**
  String get programsManagement;

  /// No description provided for @studyPlanManagement.
  ///
  /// In en, this message translates to:
  /// **'Study Plan Management'**
  String get studyPlanManagement;

  /// No description provided for @newProgram.
  ///
  /// In en, this message translates to:
  /// **'New Program'**
  String get newProgram;

  /// No description provided for @editProgram.
  ///
  /// In en, this message translates to:
  /// **'Edit Program'**
  String get editProgram;

  /// No description provided for @programName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get programName;

  /// No description provided for @programCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get programCode;

  /// No description provided for @programFees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get programFees;

  /// No description provided for @programDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (Years)'**
  String get programDuration;

  /// No description provided for @degreeType.
  ///
  /// In en, this message translates to:
  /// **'Degree Type'**
  String get degreeType;

  /// No description provided for @bachelor.
  ///
  /// In en, this message translates to:
  /// **'Bachelor'**
  String get bachelor;

  /// No description provided for @master.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get master;

  /// No description provided for @diploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get diploma;

  /// No description provided for @phd.
  ///
  /// In en, this message translates to:
  /// **'PhD'**
  String get phd;

  /// No description provided for @searchPrograms.
  ///
  /// In en, this message translates to:
  /// **'Search Programs'**
  String get searchPrograms;

  /// No description provided for @academicDetails.
  ///
  /// In en, this message translates to:
  /// **'Academic Details'**
  String get academicDetails;

  /// No description provided for @studyPlanDetails.
  ///
  /// In en, this message translates to:
  /// **'Study Plan Details'**
  String get studyPlanDetails;

  /// No description provided for @prerequisites.
  ///
  /// In en, this message translates to:
  /// **'Prerequisites'**
  String get prerequisites;

  /// No description provided for @collegesBreadcrumb.
  ///
  /// In en, this message translates to:
  /// **'Colleges'**
  String get collegesBreadcrumb;

  /// No description provided for @programsBreadcrumb.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programsBreadcrumb;

  /// No description provided for @studyPlanBreadcrumb.
  ///
  /// In en, this message translates to:
  /// **'Study Plan'**
  String get studyPlanBreadcrumb;

  /// No description provided for @pleaseSelectCollege.
  ///
  /// In en, this message translates to:
  /// **'Please select a college'**
  String get pleaseSelectCollege;

  /// No description provided for @pleaseSelectProgram.
  ///
  /// In en, this message translates to:
  /// **'Please select a program'**
  String get pleaseSelectProgram;

  /// No description provided for @noCoursesCurrently.
  ///
  /// In en, this message translates to:
  /// **'No courses currently'**
  String get noCoursesCurrently;

  /// No description provided for @selectedCollegeText.
  ///
  /// In en, this message translates to:
  /// **'Selected College:'**
  String get selectedCollegeText;

  /// No description provided for @courseName.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get courseName;

  /// No description provided for @creditHours.
  ///
  /// In en, this message translates to:
  /// **'Credit Hours'**
  String get creditHours;

  /// No description provided for @semesterLevel.
  ///
  /// In en, this message translates to:
  /// **'Semester Level'**
  String get semesterLevel;

  /// No description provided for @selectCollegeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select College'**
  String get selectCollegeTitle;

  /// No description provided for @selectProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Program'**
  String get selectProgramTitle;

  /// No description provided for @studyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Plan'**
  String get studyPlanTitle;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @programCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Program Code'**
  String get programCodeLabel;

  /// No description provided for @studyDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get studyDurationLabel;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusRatified.
  ///
  /// In en, this message translates to:
  /// **'Ratified'**
  String get statusRatified;

  /// No description provided for @statusPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get statusPendingPayment;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted / Ready'**
  String get statusSubmitted;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @searchStudentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by Student Name, ID, or Reference'**
  String get searchStudentPlaceholder;

  /// No description provided for @requestTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestTypeLabel;

  /// No description provided for @absenceExcuse.
  ///
  /// In en, this message translates to:
  /// **'Absence Excuse'**
  String get absenceExcuse;

  /// No description provided for @studyPostponement.
  ///
  /// In en, this message translates to:
  /// **'Study Postponement'**
  String get studyPostponement;

  /// No description provided for @reEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Re-enrollment'**
  String get reEnrollment;

  /// No description provided for @gradeAppeal.
  ///
  /// In en, this message translates to:
  /// **'Grade Appeal'**
  String get gradeAppeal;

  /// No description provided for @specializationLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specializationLabel;

  /// No description provided for @computerScience.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get computerScience;

  /// No description provided for @electricalEngineering.
  ///
  /// In en, this message translates to:
  /// **'Electrical Engineering'**
  String get electricalEngineering;

  /// No description provided for @businessAdministration.
  ///
  /// In en, this message translates to:
  /// **'Business Administration'**
  String get businessAdministration;

  /// No description provided for @academicLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Academic Level'**
  String get academicLevelLabel;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level {num}'**
  String levelNumber(int num);

  /// No description provided for @advancedFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filter'**
  String get advancedFilterTooltip;

  /// No description provided for @totalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests: {count}'**
  String totalRequests(int count);

  /// No description provided for @failedToLoadRequestsExt.
  ///
  /// In en, this message translates to:
  /// **'Failed to load requests: {error}'**
  String failedToLoadRequestsExt(String error);

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleStaffAffairs.
  ///
  /// In en, this message translates to:
  /// **'Staff Affairs'**
  String get roleStaffAffairs;

  /// No description provided for @roleAccountant.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get roleAccountant;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @searchNameCardPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search Name/Card'**
  String get searchNameCardPlaceholder;

  /// No description provided for @courseIdPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Course ID'**
  String get courseIdPlaceholder;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @studySchedules.
  ///
  /// In en, this message translates to:
  /// **'Study Schedules'**
  String get studySchedules;

  /// No description provided for @studySchedulesManagement.
  ///
  /// In en, this message translates to:
  /// **'Study Schedules Management'**
  String get studySchedulesManagement;

  /// No description provided for @academicManagement.
  ///
  /// In en, this message translates to:
  /// **'Academic Management'**
  String get academicManagement;

  /// No description provided for @newSchedule.
  ///
  /// In en, this message translates to:
  /// **'New Schedule'**
  String get newSchedule;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// No description provided for @deleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule'**
  String get deleteSchedule;

  /// No description provided for @confirmDeleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this schedule?'**
  String get confirmDeleteSchedule;

  /// No description provided for @scheduleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Schedule deleted successfully'**
  String get scheduleDeleted;

  /// No description provided for @scheduleCreated.
  ///
  /// In en, this message translates to:
  /// **'Schedule created successfully'**
  String get scheduleCreated;

  /// No description provided for @scheduleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Schedule updated successfully'**
  String get scheduleUpdated;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @noSchedulesFound.
  ///
  /// In en, this message translates to:
  /// **'No study schedules found'**
  String get noSchedulesFound;

  /// No description provided for @previewSchedule.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewSchedule;

  /// No description provided for @downloadSchedule.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadSchedule;

  /// No description provided for @academicYear.
  ///
  /// In en, this message translates to:
  /// **'Academic Year'**
  String get academicYear;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @failedToLoadSchedules.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schedules'**
  String get failedToLoadSchedules;

  /// No description provided for @duplicateScheduleError.
  ///
  /// In en, this message translates to:
  /// **'A schedule for this Program, Semester, and Level already exists.'**
  String get duplicateScheduleError;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @uploadNewFile.
  ///
  /// In en, this message translates to:
  /// **'Upload New File (leave empty to keep current)'**
  String get uploadNewFile;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @noStudySchedules.
  ///
  /// In en, this message translates to:
  /// **'No study schedules found'**
  String get noStudySchedules;

  /// No description provided for @viewSchedule.
  ///
  /// In en, this message translates to:
  /// **'View Schedule'**
  String get viewSchedule;

  /// No description provided for @allPrograms.
  ///
  /// In en, this message translates to:
  /// **'All Programs'**
  String get allPrograms;

  /// No description provided for @allSemesters.
  ///
  /// In en, this message translates to:
  /// **'All Semesters'**
  String get allSemesters;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get allLevels;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addStudySchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Study Schedule'**
  String get addStudySchedule;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @semestersManagement.
  ///
  /// In en, this message translates to:
  /// **'Semesters Management'**
  String get semestersManagement;

  /// No description provided for @addSemester.
  ///
  /// In en, this message translates to:
  /// **'Add Semester'**
  String get addSemester;

  /// No description provided for @noSemestersAdded.
  ///
  /// In en, this message translates to:
  /// **'No semesters added yet.'**
  String get noSemestersAdded;

  /// No description provided for @semesterAndYear.
  ///
  /// In en, this message translates to:
  /// **'Semester and Year'**
  String get semesterAndYear;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @examsStart.
  ///
  /// In en, this message translates to:
  /// **'Exams Start'**
  String get examsStart;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteSemester.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?\nNote: You cannot delete a semester if it has registered grades or payments.'**
  String confirmDeleteSemester(String name);

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @addNewSemester.
  ///
  /// In en, this message translates to:
  /// **'Add New Semester'**
  String get addNewSemester;

  /// No description provided for @editSemester.
  ///
  /// In en, this message translates to:
  /// **'Edit Semester'**
  String get editSemester;

  /// No description provided for @startYear.
  ///
  /// In en, this message translates to:
  /// **'Start Year'**
  String get startYear;

  /// No description provided for @endYear.
  ///
  /// In en, this message translates to:
  /// **'End Year'**
  String get endYear;

  /// No description provided for @setAsActiveSemester.
  ///
  /// In en, this message translates to:
  /// **'Set as active (current) semester'**
  String get setAsActiveSemester;

  /// No description provided for @activateSemesterWarning.
  ///
  /// In en, this message translates to:
  /// **'Activating this semester will automatically deactivate all others.'**
  String get activateSemesterWarning;

  /// No description provided for @examsStartDate.
  ///
  /// In en, this message translates to:
  /// **'Exams Start Date'**
  String get examsStartDate;

  /// No description provided for @requireAllDates.
  ///
  /// In en, this message translates to:
  /// **'Please select all dates'**
  String get requireAllDates;

  /// No description provided for @addSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get addSuccess;

  /// No description provided for @editSuccess.
  ///
  /// In en, this message translates to:
  /// **'Edited successfully'**
  String get editSuccess;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @firstTerm.
  ///
  /// In en, this message translates to:
  /// **'First Term'**
  String get firstTerm;

  /// No description provided for @secondTerm.
  ///
  /// In en, this message translates to:
  /// **'Second Term'**
  String get secondTerm;

  /// No description provided for @notificationSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notification sent successfully!'**
  String get notificationSentSuccess;

  /// No description provided for @receivedNotifications.
  ///
  /// In en, this message translates to:
  /// **'Received Notifications'**
  String get receivedNotifications;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get sendNotification;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @allUsers.
  ///
  /// In en, this message translates to:
  /// **'All (Staff & Students)'**
  String get allUsers;

  /// No description provided for @allStaff.
  ///
  /// In en, this message translates to:
  /// **'All Staff'**
  String get allStaff;

  /// No description provided for @roleGradeControl.
  ///
  /// In en, this message translates to:
  /// **'Grade Control'**
  String get roleGradeControl;

  /// No description provided for @broadcastNewNotification.
  ///
  /// In en, this message translates to:
  /// **'Broadcast New Notification'**
  String get broadcastNewNotification;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @enterNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter notification title'**
  String get enterNotificationTitle;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @enterNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter notification message content'**
  String get enterNotificationMessage;

  /// No description provided for @recipientRole.
  ///
  /// In en, this message translates to:
  /// **'Recipient Role'**
  String get recipientRole;

  /// No description provided for @unauthorizedSendNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized to send notifications.'**
  String get unauthorizedSendNotifications;

  /// No description provided for @errorSendingNotification.
  ///
  /// In en, this message translates to:
  /// **'Error sending notification: {error}'**
  String errorSendingNotification(String error);

  /// No description provided for @errorMarkingAsRead.
  ///
  /// In en, this message translates to:
  /// **'Error marking as read: {error}'**
  String errorMarkingAsRead(String error);
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
