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
  String get courseCode => 'رمز المقرر';

  @override
  String get level => 'المستوى';

  @override
  String get searchGrades => 'بحث عن الدرجات';

  @override
  String get applyFilters => 'تطبيق الفلاتر';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get selectFiltersToSearch => 'اختر فلاتر البحث لعرض النتائج';

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
}
