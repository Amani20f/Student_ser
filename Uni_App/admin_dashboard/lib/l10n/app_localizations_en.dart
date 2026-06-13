// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Al-Arab University';

  @override
  String get dashboardLabel => 'Dashboard';

  @override
  String get uniAdmin => 'Uni Admin';

  @override
  String get dashboardSubtitle => 'Dashboard';

  @override
  String get loginTitle => 'Al-Arab University';

  @override
  String get loginSubtitle => 'University Service Ecosystem';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get overview => 'Overview';

  @override
  String get pendingPayments => 'Pending Payments';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get totalStudents => 'Total Students';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String welcomeTitle(String name) {
    return 'Welcome, $name!';
  }

  @override
  String loggedInAs(String role) {
    return 'You are logged in as $role.';
  }

  @override
  String get sidebarNavHelp =>
      'Use the sidebar to navigate to your assigned features.';

  @override
  String get serviceRequests => 'Service Requests';

  @override
  String get paymentVerification => 'Payment Verification';

  @override
  String get gradeManagement => 'Grade Management';

  @override
  String get activityLogs => 'Activity Logs';

  @override
  String get notifications => 'Notifications';

  @override
  String get requests => 'Requests';

  @override
  String get payments => 'Payments';

  @override
  String get grades => 'Grades';

  @override
  String get logout => 'Logout';

  @override
  String get failedToLoadStats => 'Failed to load stats';

  @override
  String get failedToLoadRequests => 'Failed to load requests';

  @override
  String get failedToLoadPayments => 'Failed to load payments';

  @override
  String get failedToLoadGrades => 'Failed to load grades';

  @override
  String get failedToLoadLogs => 'Failed to load logs';

  @override
  String get retry => 'Retry';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get noPendingPayments => 'No pending payments';

  @override
  String get noGradesFound => 'No grades found for this semester';

  @override
  String get noLogsFound => 'No logs found';

  @override
  String get studentColumn => 'Student';

  @override
  String get amountColumn => 'Amount';

  @override
  String get semesterColumn => 'Semester';

  @override
  String get statusColumn => 'Status';

  @override
  String get receiptColumn => 'Receipt';

  @override
  String get actionsColumn => 'Actions';

  @override
  String get courseColumn => 'Course';

  @override
  String get firstColumn => 'First';

  @override
  String get secondColumn => 'Second';

  @override
  String get midtermColumn => 'Midterm';

  @override
  String get finalColumn => 'Final';

  @override
  String get totalColumn => 'Total';

  @override
  String get gpaColumn => 'GPA';

  @override
  String get updatedColumn => 'Updated';

  @override
  String get userColumn => 'User';

  @override
  String get actionColumn => 'Action';

  @override
  String get modelColumn => 'Model';

  @override
  String get oldValuesColumn => 'Old Values';

  @override
  String get newValuesColumn => 'New Values';

  @override
  String get dateColumn => 'Date';

  @override
  String get viewAttachment => 'View Attachment';

  @override
  String get hideActions => 'Hide Actions';

  @override
  String get takeAction => 'Take Action';

  @override
  String get adminNotesLabel => 'Admin Notes (Required for rejection)';

  @override
  String get enterAdminNotes => 'Enter admin notes...';

  @override
  String get adminNotesRequired => 'Admin notes are required for rejection';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get verify => 'Verify';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get view => 'View';

  @override
  String get receiptPreview => 'Receipt Preview';

  @override
  String get failedToLoadReceipt => 'Failed to load receipt';

  @override
  String get rejectPayment => 'Reject Payment';

  @override
  String get reasonForRejection => 'Reason for rejection';

  @override
  String get enterReason => 'Enter reason...';

  @override
  String get requestApproved => 'Request approved';

  @override
  String get requestRejected => 'Request rejected';

  @override
  String get paymentVerifiedSuccess => 'Payment verified successfully';

  @override
  String get paymentRejected => 'Payment rejected';

  @override
  String get gradeUpdatedSuccess => 'Grade updated successfully';

  @override
  String get semester => 'Semester';

  @override
  String get selectSemester => 'Select semester';

  @override
  String get selectSemesterToView => 'Select a semester to view grades';

  @override
  String get editGrade => 'Edit Grade';

  @override
  String editGradeTitle(String course) {
    return 'Edit Grade — $course';
  }

  @override
  String get filterByAction => 'Filter by action:';

  @override
  String get allActions => 'All actions';

  @override
  String entriesCount(int count) {
    return '$count entries';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsNotAvailable =>
      'Staff notifications are not yet available.';

  @override
  String get notificationsFuture =>
      'This page is ready for future backend integration.\nOnce the staff notification endpoint is implemented, notifications will appear here.';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get notApplicable => 'N/A';

  @override
  String get system => 'System';

  @override
  String get unknownStudent => 'Unknown Student';

  @override
  String get general => 'General';

  @override
  String get toggleTheme => 'Toggle Theme';

  @override
  String get purposeColumn => 'Purpose';

  @override
  String get timePeriod => 'Time Period';

  @override
  String get allTime => 'All Time';

  @override
  String get last24h => 'Last 24 Hours';

  @override
  String get last2days => 'Last 2 Days';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get lastYear => 'Last Year';

  @override
  String get olderThanYear => 'Older than a year';

  @override
  String get studentCard => 'Student Card No.';

  @override
  String get courseCode => 'Course Code';

  @override
  String get level => 'Level';

  @override
  String get searchGrades => 'Search Grades';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get selectFiltersToSearch =>
      'No data is currently displayed.\nUse the filters above to search and view results.';

  @override
  String get userManagement => 'User Management';

  @override
  String get language => 'Language';

  @override
  String get manageUsersSubtitle =>
      'Manage all system users — create staff accounts, update passwords, or remove users.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get nameLabel => 'Name';

  @override
  String get usernameLabel => 'Username';

  @override
  String get roleLabel => 'Role';

  @override
  String get createNewAccount => 'Create New Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get changePassword => 'Change Password';

  @override
  String changePasswordFor(String name) {
    return 'Change Password: $name';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String confirmDeleteAccount(String name) {
    return 'Are you sure you want to delete $name? This action cannot be undone.';
  }

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully';

  @override
  String get accountCreatedSuccess => 'Account created successfully';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get newPassword => 'New Password';

  @override
  String get gradeAppeals => 'Grade Appeals';

  @override
  String get appealDetails => 'Appeal Details';

  @override
  String get underReviewAppeals => 'Under Review Appeals';

  @override
  String get studentNote => 'Student Note';

  @override
  String get committeeReport => 'Committee Report';

  @override
  String get beforeGrades => 'BEFORE (Read-only)';

  @override
  String get afterGrades => 'AFTER (Proposed)';

  @override
  String get approveAppeal => 'Approve Appeal';

  @override
  String get rejectAppeal => 'Reject Appeal';

  @override
  String get appealApproved => 'Appeal approved successfully';

  @override
  String get appealRejected => 'Appeal rejected successfully';

  @override
  String get failedToLoadAppeals => 'Failed to load appeals';

  @override
  String get noAppealsUnderReview => 'No appeals are currently under review';

  @override
  String get confirmApproveAppeal =>
      'Are you sure you want to approve this appeal and update the student\'s grades?';

  @override
  String get confirmRejectAppeal =>
      'Are you sure you want to reject this appeal?';

  @override
  String get confirmApprovePayment =>
      'Are you sure you want to verify this payment?';

  @override
  String get confirmRejectPayment =>
      'Are you sure you want to reject this payment receipt?';

  @override
  String get verificationNotes => 'Verification Notes';

  @override
  String get programsLabel => 'Programs';

  @override
  String get studyPlansLabel => 'Study Plans';

  @override
  String get serviceManagementLabel => 'Service Management';

  @override
  String get programsManagement => 'Programs Management';

  @override
  String get studyPlanManagement => 'Study Plan Management';

  @override
  String get newProgram => 'New Program';

  @override
  String get editProgram => 'Edit Program';

  @override
  String get programName => 'Name';

  @override
  String get programCode => 'Code';

  @override
  String get programFees => 'Fees';

  @override
  String get programDuration => 'Duration (Years)';

  @override
  String get degreeType => 'Degree Type';

  @override
  String get bachelor => 'Bachelor';

  @override
  String get master => 'Master';

  @override
  String get diploma => 'Diploma';

  @override
  String get phd => 'PhD';

  @override
  String get searchPrograms => 'Search Programs';

  @override
  String get academicDetails => 'Academic Details';

  @override
  String get studyPlanDetails => 'Study Plan Details';

  @override
  String get prerequisites => 'Prerequisites';

  @override
  String get collegesBreadcrumb => 'Colleges';

  @override
  String get programsBreadcrumb => 'Programs';

  @override
  String get studyPlanBreadcrumb => 'Study Plan';

  @override
  String get pleaseSelectCollege => 'Please select a college';

  @override
  String get pleaseSelectProgram => 'Please select a program';

  @override
  String get noCoursesCurrently => 'No courses currently';

  @override
  String get selectedCollegeText => 'Selected College:';

  @override
  String get courseName => 'Course Name';

  @override
  String get creditHours => 'Credit Hours';

  @override
  String get semesterLevel => 'Semester Level';

  @override
  String get selectCollegeTitle => 'Select College';

  @override
  String get selectProgramTitle => 'Select Program';

  @override
  String get studyPlanTitle => 'Study Plan';

  @override
  String get years => 'Years';

  @override
  String get programCodeLabel => 'Program Code';

  @override
  String get studyDurationLabel => 'Duration';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusRatified => 'Ratified';

  @override
  String get statusPendingPayment => 'Pending Payment';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusUnderReview => 'Under Review';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusSubmitted => 'Submitted / Ready';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get searchStudentPlaceholder =>
      'Search by Student Name, ID, or Reference';

  @override
  String get requestTypeLabel => 'Request Type';

  @override
  String get absenceExcuse => 'Absence Excuse';

  @override
  String get studyPostponement => 'Study Postponement';

  @override
  String get reEnrollment => 'Re-enrollment';

  @override
  String get gradeAppeal => 'Grade Appeal';

  @override
  String get specializationLabel => 'Specialization';

  @override
  String get computerScience => 'Computer Science';

  @override
  String get electricalEngineering => 'Electrical Engineering';

  @override
  String get businessAdministration => 'Business Administration';

  @override
  String get academicLevelLabel => 'Academic Level';

  @override
  String levelNumber(int num) {
    return 'Level $num';
  }

  @override
  String get advancedFilterTooltip => 'Advanced Filter';

  @override
  String totalRequests(int count) {
    return 'Total Requests: $count';
  }

  @override
  String failedToLoadRequestsExt(String error) {
    return 'Failed to load requests: $error';
  }

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleStaffAffairs => 'Staff Affairs';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get roleStudent => 'Student';

  @override
  String get searchNameCardPlaceholder => 'Search Name/Card';

  @override
  String get courseIdPlaceholder => 'Course ID';

  @override
  String get passed => 'Passed';

  @override
  String get failed => 'Failed';

  @override
  String get studySchedules => 'Study Schedules';

  @override
  String get studySchedulesManagement => 'Study Schedules Management';

  @override
  String get academicManagement => 'Academic Management';

  @override
  String get newSchedule => 'New Schedule';

  @override
  String get editSchedule => 'Edit Schedule';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String get confirmDeleteSchedule =>
      'Are you sure you want to delete this schedule?';

  @override
  String get scheduleDeleted => 'Schedule deleted successfully';

  @override
  String get scheduleCreated => 'Schedule created successfully';

  @override
  String get scheduleUpdated => 'Schedule updated successfully';

  @override
  String get selectFile => 'Select File';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get noSchedulesFound => 'No study schedules found';

  @override
  String get previewSchedule => 'Preview';

  @override
  String get downloadSchedule => 'Download';

  @override
  String get academicYear => 'Academic Year';

  @override
  String get fileName => 'File Name';

  @override
  String get failedToLoadSchedules => 'Failed to load schedules';

  @override
  String get duplicateScheduleError =>
      'A schedule for this Program, Semester, and Level already exists.';

  @override
  String get requiredField => 'This field is required';

  @override
  String get notes => 'Notes';

  @override
  String get uploadNewFile => 'Upload New File (leave empty to keep current)';

  @override
  String get actions => 'Actions';

  @override
  String get viewDetails => 'View Details';

  @override
  String get noStudySchedules => 'No study schedules found';

  @override
  String get viewSchedule => 'View Schedule';

  @override
  String get allPrograms => 'All Programs';

  @override
  String get allSemesters => 'All Semesters';

  @override
  String get allLevels => 'All Levels';

  @override
  String get delete => 'Delete';

  @override
  String get addStudySchedule => 'Add Study Schedule';

  @override
  String get preview => 'Preview';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get semestersManagement => 'Semesters Management';

  @override
  String get addSemester => 'Add Semester';

  @override
  String get noSemestersAdded => 'No semesters added yet.';

  @override
  String get semesterAndYear => 'Semester and Year';

  @override
  String get status => 'Status';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get examsStart => 'Exams Start';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get edit => 'Edit';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteSemester(String name) {
    return 'Are you sure you want to delete $name?\nNote: You cannot delete a semester if it has registered grades or payments.';
  }

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get addNewSemester => 'Add New Semester';

  @override
  String get editSemester => 'Edit Semester';

  @override
  String get startYear => 'Start Year';

  @override
  String get endYear => 'End Year';

  @override
  String get setAsActiveSemester => 'Set as active (current) semester';

  @override
  String get activateSemesterWarning =>
      'Activating this semester will automatically deactivate all others.';

  @override
  String get examsStartDate => 'Exams Start Date';

  @override
  String get requireAllDates => 'Please select all dates';

  @override
  String get addSuccess => 'Added successfully';

  @override
  String get editSuccess => 'Edited successfully';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get selectDate => 'Select Date';

  @override
  String get firstTerm => 'First Term';

  @override
  String get secondTerm => 'Second Term';

  @override
  String get notificationSentSuccess => 'Notification sent successfully!';

  @override
  String get receivedNotifications => 'Received Notifications';

  @override
  String get sendNotification => 'Send Notification';

  @override
  String get noNotificationsYet => 'No notifications yet.';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get allUsers => 'All (Staff & Students)';

  @override
  String get allStaff => 'All Staff';

  @override
  String get roleGradeControl => 'Grade Control';

  @override
  String get broadcastNewNotification => 'Broadcast New Notification';

  @override
  String get titleLabel => 'Title';

  @override
  String get enterNotificationTitle => 'Enter notification title';

  @override
  String get messageLabel => 'Message';

  @override
  String get enterNotificationMessage => 'Enter notification message content';

  @override
  String get recipientRole => 'Recipient Role';

  @override
  String get unauthorizedSendNotifications =>
      'Unauthorized to send notifications.';

  @override
  String errorSendingNotification(String error) {
    return 'Error sending notification: $error';
  }

  @override
  String errorMarkingAsRead(String error) {
    return 'Error marking as read: $error';
  }
}
