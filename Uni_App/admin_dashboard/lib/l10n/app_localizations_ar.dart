// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'جامعة العرب';

  @override
  String get dashboardLabel => 'لوحة التحكم';

  @override
  String get uniAdmin => 'إدارة الجامعة';

  @override
  String get dashboardSubtitle => 'لوحة التحكم';

  @override
  String get loginTitle => 'جامعة العرب';

  @override
  String get loginSubtitle => 'نظام الخدمات الجامعية';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get pendingPayments => 'دفعات قيد الانتظار';

  @override
  String get pendingRequests => 'طلبات قيد الانتظار';

  @override
  String get totalStudents => 'إجمالي الطلاب';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String welcomeTitle(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String loggedInAs(String role) {
    return 'أنت مسجل الدخول كـ $role.';
  }

  @override
  String get sidebarNavHelp =>
      'استخدم الشريط الجانبي للتنقل إلى الأقسام المتاحة لك.';

  @override
  String get serviceRequests => 'طلبات الخدمة';

  @override
  String get paymentVerification => 'التحقق من المدفوعات';

  @override
  String get gradeManagement => 'إدارة الدرجات';

  @override
  String get activityLogs => 'سجل الأنشطة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get requests => 'الطلبات';

  @override
  String get payments => 'المدفوعات';

  @override
  String get grades => 'الدرجات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get failedToLoadStats => 'فشل تحميل الإحصائيات';

  @override
  String get failedToLoadRequests => 'فشل تحميل الطلبات';

  @override
  String get failedToLoadPayments => 'فشل تحميل المدفوعات';

  @override
  String get failedToLoadGrades => 'فشل تحميل الدرجات';

  @override
  String get failedToLoadLogs => 'فشل تحميل السجلات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noPendingRequests => 'لا توجد طلبات معلقة';

  @override
  String get noPendingPayments => 'لا توجد دفعات معلقة';

  @override
  String get noGradesFound => 'لا توجد درجات لهذا الفصل';

  @override
  String get noLogsFound => 'لا توجد سجلات';

  @override
  String get studentColumn => 'الطالب';

  @override
  String get amountColumn => 'المبلغ';

  @override
  String get semesterColumn => 'الفصل';

  @override
  String get statusColumn => 'الحالة';

  @override
  String get receiptColumn => 'الإيصال';

  @override
  String get actionsColumn => 'الإجراءات';

  @override
  String get courseColumn => 'المقرر';

  @override
  String get firstColumn => 'أول';

  @override
  String get secondColumn => 'ثانٍ';

  @override
  String get midtermColumn => 'منتصف';

  @override
  String get finalColumn => 'نهائي';

  @override
  String get totalColumn => 'المجموع';

  @override
  String get gpaColumn => 'المعدل';

  @override
  String get updatedColumn => 'تاريخ التحديث';

  @override
  String get userColumn => 'المستخدم';

  @override
  String get actionColumn => 'الإجراء';

  @override
  String get modelColumn => 'النموذج';

  @override
  String get oldValuesColumn => 'القيم القديمة';

  @override
  String get newValuesColumn => 'القيم الجديدة';

  @override
  String get dateColumn => 'التاريخ';

  @override
  String get viewAttachment => 'عرض المرفق';

  @override
  String get hideActions => 'إخفاء الإجراءات';

  @override
  String get takeAction => 'اتخاذ إجراء';

  @override
  String get adminNotesLabel => 'ملاحظات المشرف (مطلوبة للرفض)';

  @override
  String get enterAdminNotes => 'أدخل ملاحظات المشرف...';

  @override
  String get adminNotesRequired => 'ملاحظات المشرف مطلوبة للرفض';

  @override
  String get reject => 'رفض';

  @override
  String get approve => 'قبول';

  @override
  String get verify => 'تحقق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get view => 'عرض';

  @override
  String get receiptPreview => 'معاينة الإيصال';

  @override
  String get failedToLoadReceipt => 'فشل تحميل الإيصال';

  @override
  String get rejectPayment => 'رفض الدفعة';

  @override
  String get reasonForRejection => 'سبب الرفض';

  @override
  String get enterReason => 'أدخل السبب...';

  @override
  String get requestApproved => 'تمت الموافقة على الطلب';

  @override
  String get requestRejected => 'تم رفض الطلب';

  @override
  String get paymentVerifiedSuccess => 'تم التحقق من الدفعة بنجاح';

  @override
  String get paymentRejected => 'تم رفض الدفعة';

  @override
  String get gradeUpdatedSuccess => 'تم تحديث الدرجة بنجاح';

  @override
  String get semester => 'الفصل الدراسي';

  @override
  String get selectSemester => 'اختر الفصل';

  @override
  String get selectSemesterToView => 'اختر فصلاً لعرض الدرجات';

  @override
  String get editGrade => 'تعديل الدرجة';

  @override
  String editGradeTitle(String course) {
    return 'تعديل الدرجة — $course';
  }

  @override
  String get filterByAction => 'تصفية حسب الإجراء:';

  @override
  String get allActions => 'جميع الإجراءات';

  @override
  String entriesCount(int count) {
    return '$count سجل';
  }

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsNotAvailable => 'إشعارات الموظفين غير متاحة حالياً.';

  @override
  String get notificationsFuture =>
      'هذه الصفحة جاهزة للتكامل المستقبلي مع الخادم.';

  @override
  String error(String message) {
    return 'خطأ: $message';
  }

  @override
  String get notApplicable => 'غير متاح';

  @override
  String get system => 'النظام';

  @override
  String get unknownStudent => 'طالب غير معروف';

  @override
  String get general => 'عام';

  @override
  String get toggleTheme => 'تبديل المظهر';

  @override
  String get purposeColumn => 'الغرض';

  @override
  String get timePeriod => 'الفترة الزمنية';

  @override
  String get allTime => 'كل الأوقات';

  @override
  String get last24h => 'آخر 24 ساعة';

  @override
  String get last2days => 'آخر يومين';

  @override
  String get lastWeek => 'آخر أسبوع';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get lastYear => 'العام الماضي';

  @override
  String get olderThanYear => 'أقدم من عام';

  @override
  String get studentCard => 'رقم بطاقة الطالب';

  @override
  String get courseCode => 'رمز المادة';

  @override
  String get level => 'المستوى';

  @override
  String get searchGrades => 'بحث عن الدرجات';

  @override
  String get applyFilters => 'تطبيق الفلاتر';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get selectFiltersToSearch =>
      'لا توجد بيانات معروضة حالياً.\nاستخدم الفلاتر أعلاه للبحث وعرض النتائج.';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get language => 'اللغة';

  @override
  String get manageUsersSubtitle =>
      'إدارة جميع مستخدمي النظام - إنشاء حسابات الموظفين، تحديث كلمات المرور، أو حذف المستخدمين.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get usernameLabel => 'اسم المستخدم';

  @override
  String get roleLabel => 'الدور';

  @override
  String get createNewAccount => 'إنشاء حساب جديد';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String changePasswordFor(String name) {
    return 'تغيير كلمة المرور: $name';
  }

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String confirmDeleteAccount(String name) {
    return 'هل أنت متأكد أنك تريد حذف $name؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get passwordUpdatedSuccess => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get accountCreatedSuccess => 'تم إنشاء الحساب بنجاح';

  @override
  String get deleteUser => 'حذف المستخدم';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get gradeAppeals => 'تظلمات الدرجات';

  @override
  String get appealDetails => 'تفاصيل التظلم';

  @override
  String get underReviewAppeals => 'التظلمات قيد المراجعة';

  @override
  String get studentNote => 'ملاحظة الطالب';

  @override
  String get committeeReport => 'تقرير اللجنة';

  @override
  String get beforeGrades => 'قبل (للقراءة فقط)';

  @override
  String get afterGrades => 'بعد (مقترح)';

  @override
  String get approveAppeal => 'قبول التظلم';

  @override
  String get rejectAppeal => 'رفض التظلم';

  @override
  String get appealApproved => 'تم قبول التظلم بنجاح';

  @override
  String get appealRejected => 'تم رفض التظلم بنجاح';

  @override
  String get failedToLoadAppeals => 'فشل في تحميل التظلمات';

  @override
  String get noAppealsUnderReview => 'لا توجد تظلمات قيد المراجعة حالياً';

  @override
  String get confirmApproveAppeal =>
      'هل أنت متأكد من الموافقة على هذا التظلم وتحديث درجات الطالب؟';

  @override
  String get confirmRejectAppeal => 'هل أنت متأكد من رفض هذا التظلم؟';

  @override
  String get confirmApprovePayment => 'هل أنت متأكد من توثيق هذه الدفعة؟';

  @override
  String get confirmRejectPayment => 'هل أنت متأكد من رفض إيصال الدفع هذا؟';

  @override
  String get verificationNotes => 'ملاحظات التوثيق';

  @override
  String get programsLabel => 'البرامج';

  @override
  String get studyPlansLabel => 'الخطط الدراسية';

  @override
  String get serviceManagementLabel => 'إدارة الخدمات';

  @override
  String get programsManagement => 'إدارة البرامج';

  @override
  String get studyPlanManagement => 'إدارة الخطط الدراسية';

  @override
  String get newProgram => 'برنامج جديد';

  @override
  String get editProgram => 'تعديل البرنامج';

  @override
  String get programName => 'الاسم';

  @override
  String get programCode => 'الرمز';

  @override
  String get programFees => 'الرسوم';

  @override
  String get programDuration => 'المدة (سنوات)';

  @override
  String get degreeType => 'الدرجة العلمية';

  @override
  String get bachelor => 'بكالوريوس';

  @override
  String get master => 'ماجستير';

  @override
  String get diploma => 'دبلوم';

  @override
  String get phd => 'دكتوراه';

  @override
  String get searchPrograms => 'البحث عن تخصص';

  @override
  String get academicDetails => 'التفاصيل الأكاديمية';

  @override
  String get studyPlanDetails => 'تفاصيل الخطة الدراسية';

  @override
  String get prerequisites => 'المتطلبات السابقة';

  @override
  String get collegesBreadcrumb => 'الكليات';

  @override
  String get programsBreadcrumb => 'التخصصات';

  @override
  String get studyPlanBreadcrumb => 'الخطة الدراسية';

  @override
  String get pleaseSelectCollege => 'الرجاء اختيار كلية';

  @override
  String get pleaseSelectProgram => 'الرجاء اختيار تخصص';

  @override
  String get noCoursesCurrently => 'لا توجد مواد حالياً';

  @override
  String get selectedCollegeText => 'الكلية المختارة:';

  @override
  String get courseName => 'اسم المادة';

  @override
  String get creditHours => 'عدد الساعات';

  @override
  String get semesterLevel => 'المستوى الدراسي';

  @override
  String get selectCollegeTitle => 'اختيار الكلية';

  @override
  String get selectProgramTitle => 'اختيار التخصص';

  @override
  String get studyPlanTitle => 'الخطة الدراسية';

  @override
  String get years => 'سنوات';

  @override
  String get programCodeLabel => 'رمز التخصص';

  @override
  String get studyDurationLabel => 'مدة الدراسة';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusRatified => 'مصادق عليه';

  @override
  String get statusPendingPayment => 'بانتظار السداد';

  @override
  String get statusPaid => 'تم السداد';

  @override
  String get statusUnderReview => 'قيد المراجعة';

  @override
  String get statusApproved => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusVerified => 'تم التأكيد';

  @override
  String get statusSubmitted => 'تم التقديم';

  @override
  String get statusCompleted => 'مكتمل / مقبول';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusInactive => 'غير نشط';

  @override
  String get statusUnknown => 'غير معروف';

  @override
  String get searchStudentPlaceholder =>
      'البحث باسم الطالب أو الرقم الجامعي أو الرقم المرجعي';

  @override
  String get requestTypeLabel => 'نوع الطلب';

  @override
  String get absenceExcuse => 'عذر غياب';

  @override
  String get studyPostponement => 'تأجيل دراسة';

  @override
  String get reEnrollment => 'إعادة قيد';

  @override
  String get gradeAppeal => 'تظلم درجات';

  @override
  String get specializationLabel => 'التخصص';

  @override
  String get computerScience => 'علوم الحاسب';

  @override
  String get electricalEngineering => 'هندسة كهربائية';

  @override
  String get businessAdministration => 'إدارة أعمال';

  @override
  String get academicLevelLabel => 'المستوى الدراسي';

  @override
  String levelNumber(int num) {
    return 'المستوى $num';
  }

  @override
  String get advancedFilterTooltip => 'تصفية متقدمة';

  @override
  String totalRequests(int count) {
    return 'إجمالي الطلبات: $count';
  }

  @override
  String failedToLoadRequestsExt(String error) {
    return 'فشل تحميل الطلبات: $error';
  }

  @override
  String get roleAdmin => 'مشرف';

  @override
  String get roleStaffAffairs => 'شؤون الموظفين';

  @override
  String get roleAccountant => 'محاسب';

  @override
  String get roleStudent => 'طالب';

  @override
  String get searchNameCardPlaceholder => 'البحث بالاسم/البطاقة';

  @override
  String get courseIdPlaceholder => 'رمز المقرر';

  @override
  String get passed => 'ناجح';

  @override
  String get failed => 'راسب';

  @override
  String get studySchedules => 'الجداول الدراسية';

  @override
  String get studySchedulesManagement => 'إدارة الجداول الدراسية';

  @override
  String get academicManagement => 'الإدارة الأكاديمية';

  @override
  String get newSchedule => 'جدول جديد';

  @override
  String get editSchedule => 'تعديل الجدول';

  @override
  String get deleteSchedule => 'حذف الجدول';

  @override
  String get confirmDeleteSchedule => 'هل أنت متأكد من حذف هذا الجدول؟';

  @override
  String get scheduleDeleted => 'تم حذف الجدول بنجاح';

  @override
  String get scheduleCreated => 'تم إنشاء الجدول بنجاح';

  @override
  String get scheduleUpdated => 'تم تحديث الجدول بنجاح';

  @override
  String get selectFile => 'اختر ملف';

  @override
  String get noFileSelected => 'لم يتم اختيار ملف';

  @override
  String get noSchedulesFound => 'لم يتم العثور على جداول دراسية';

  @override
  String get previewSchedule => 'معاينة';

  @override
  String get downloadSchedule => 'تحميل';

  @override
  String get academicYear => 'العام الجامعي';

  @override
  String get fileName => 'اسم الملف';

  @override
  String get failedToLoadSchedules => 'فشل في تحميل الجداول';

  @override
  String get duplicateScheduleError =>
      'يوجد جدول مسجل مسبقاً لهذا التخصص، الفصل والمستوى.';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get notes => 'ملاحظات';

  @override
  String get uploadNewFile => 'رفع ملف جديد (اتركه فارغاً للاحتفاظ بالحالي)';

  @override
  String get actions => 'إجراءات';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get noStudySchedules => 'لا توجد جداول دراسية';

  @override
  String get viewSchedule => 'عرض الجدول';

  @override
  String get allPrograms => 'جميع التخصصات';

  @override
  String get allSemesters => 'جميع الفصول';

  @override
  String get allLevels => 'جميع المستويات';

  @override
  String get delete => 'حذف';

  @override
  String get addStudySchedule => 'إضافة جدول دراسي';

  @override
  String get preview => 'معاينة';

  @override
  String get failedToLoadImage => 'فشل في تحميل الصورة';

  @override
  String get semestersManagement => 'إدارة الفصول الدراسية';

  @override
  String get addSemester => 'إضافة فصل';

  @override
  String get noSemestersAdded => 'لا توجد فصول دراسية مضافة حتى الآن.';

  @override
  String get semesterAndYear => 'الفصل والسنة';

  @override
  String get status => 'الحالة';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get examsStart => 'بداية الاختبارات';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get edit => 'تعديل';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String confirmDeleteSemester(String name) {
    return 'هل أنت متأكد من رغبتك في حذف $name؟\nملاحظة: لا يمكن حذف الفصل إذا كان مرتبطاً بدرجات أو مدفوعات مسجلة.';
  }

  @override
  String get deleteSuccess => 'تم الحذف بنجاح';

  @override
  String get deleteFailed => 'فشل الحذف';

  @override
  String get addNewSemester => 'إضافة فصل دراسي جديد';

  @override
  String get editSemester => 'تعديل الفصل الدراسي';

  @override
  String get startYear => 'سنة البداية';

  @override
  String get endYear => 'سنة النهاية';

  @override
  String get setAsActiveSemester => 'تعيين كفصل نشط (حالي)';

  @override
  String get activateSemesterWarning =>
      'تفعيل هذا الفصل سيعطل باقي الفصول تلقائياً.';

  @override
  String get examsStartDate => 'تاريخ بداية الاختبارات';

  @override
  String get requireAllDates => 'الرجاء تحديد جميع التواريخ';

  @override
  String get addSuccess => 'تمت الإضافة بنجاح';

  @override
  String get editSuccess => 'تم التعديل بنجاح';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get firstTerm => 'الفصل الأول';

  @override
  String get secondTerm => 'الفصل الثاني';

  @override
  String get notificationSentSuccess => 'تم إرسال الإشعار بنجاح!';

  @override
  String get receivedNotifications => 'الإشعارات الواردة';

  @override
  String get sendNotification => 'إرسال إشعار';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات بعد.';

  @override
  String get markAsRead => 'تعيين كمقروء';

  @override
  String get allUsers => 'الجميع (موظفين وطلاب)';

  @override
  String get allStaff => 'جميع الموظفين';

  @override
  String get roleGradeControl => 'رصد الدرجات';

  @override
  String get broadcastNewNotification => 'إرسال إشعار جديد';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get enterNotificationTitle => 'أدخل عنوان الإشعار';

  @override
  String get messageLabel => 'نص الرسالة';

  @override
  String get enterNotificationMessage => 'أدخل محتوى رسالة الإشعار';

  @override
  String get recipientRole => 'الدور المستهدف';

  @override
  String get unauthorizedSendNotifications => 'غير مصرح لك بإرسال إشعارات.';

  @override
  String errorSendingNotification(String error) {
    return 'خطأ في إرسال الإشعار: $error';
  }

  @override
  String errorMarkingAsRead(String error) {
    return 'خطأ في التعيين كمقروء: $error';
  }
}
