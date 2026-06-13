// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق الجامعة';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'أهلاً بك مجدداً!';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get usernameLettersOnly => 'يجب أن يحتوي اسم المستخدم على أحرف فقط';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'دخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ ';

  @override
  String get newStudentRegistration => 'تسجيل طالب جديد';

  @override
  String get verifyReferenceRequest => 'التحقق من طلب مرجعي';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get changePasswordDescription =>
      'الرجاء إدخال كلمة المرور الجديدة أدناه.';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get updatePasswordButton => 'تحديث كلمة المرور';

  @override
  String get passwordChangedSuccess => 'تم تغيير كلمة المرور بنجاح!';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get highSchoolGpa => 'معدل الثانوية العامة (%)';

  @override
  String get selectMajor => 'اختر التخصص';

  @override
  String get uploadDocuments => 'إرفاق شهادة الثانوي';

  @override
  String get uploadReceipt => 'رفع السند';

  @override
  String get uploadPhotos => 'إرفاق الصور';

  @override
  String get submitRegistration => 'إرسال التسجيل';

  @override
  String get registrationSuccessful => 'تم التسجيل بنجاح!';

  @override
  String get applicationReceived =>
      'تم استلام طلبك. يرجى حفظ الرقم المرجعي للاستفسارات المستقبلية.';

  @override
  String get referenceIdLabel => 'الرقم المرجعي';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get needHelp => 'تحتاج مساعدة؟ تواصل مع الدعم الفني: ';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String notifCount(Object count) {
    return '$count';
  }

  @override
  String get announcements => 'الإعلانات';

  @override
  String get mySchedule => 'جدولي الدراسي';

  @override
  String get studentName => 'نورة أحمد';

  @override
  String get studentId => 'الرقم الجامعي: 20241010';

  @override
  String get studentIdLabel => 'الرقم الجامعي';

  @override
  String get majorLabel => 'التخصص';

  @override
  String get gpaLabel => 'المعدل';

  @override
  String get levelLabel => 'المستوى';

  @override
  String get majorValue => 'التخصص';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRequests => 'الطلبات';

  @override
  String get navAnnouncements => 'الإعلانات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get collegeIT => 'كلية تقنية المعلومات';

  @override
  String get collegeEngineering => 'كلية الهندسة';

  @override
  String get collegeBusiness => 'كلية إدارة الأعمال';

  @override
  String get majorCS => 'علوم الحاسب';

  @override
  String get majorIT => 'تقنية المعلومات';

  @override
  String get majorSE => 'هندسة البرمجيات';

  @override
  String get majorCE => 'الهندسة المدنية';

  @override
  String get majorAccounting => 'المحاسبة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get academicInfo => 'المعلومات الأكاديمية';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get lightMode => 'الوضع النهاري';

  @override
  String get language => 'اللغة';

  @override
  String get nationalIdLabel => 'رقم الهوية';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get statusActive => 'نشط';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get stepPersonalInfo => 'المعلومات الشخصية';

  @override
  String get stepEmployment => 'الحالة الوظيفية';

  @override
  String get stepAcademic => 'المؤهلات السابقة';

  @override
  String get stepDesires => 'الرغبات الأكاديمية';

  @override
  String get stepContact => 'الاتصال';

  @override
  String get stepGuardian => 'ولي الأمر';

  @override
  String get stepMarketing => 'استبيان';

  @override
  String get stepDeclaration => 'الإقرار';

  @override
  String get fullNameAr => 'الاسم الرباعي (بالعربي)';

  @override
  String get fullNameEn => 'الاسم الرباعي (بالإنجليزي)';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get nationality => 'الجنسية';

  @override
  String get maritalStatus => 'الحالة الاجتماعية';

  @override
  String get bloodType => 'فصيلة الدم';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get governorate => 'المحافظة';

  @override
  String get district => 'المديرية';

  @override
  String get profilePicture => 'صورة شخصية';

  @override
  String get isEmployed => 'هل تعمل حالياً؟';

  @override
  String get sector => 'القطاع';

  @override
  String get government => 'حكومي';

  @override
  String get private => 'خاص';

  @override
  String get jobTitle => 'المسمى الوظيفي';

  @override
  String get previousQualification => 'المؤهل السابق';

  @override
  String get majorSpecialization => 'التخصص';

  @override
  String get seatNumber => 'رقم الجلوس';

  @override
  String get gradePercentage => 'المعدل / النسبة %';

  @override
  String get graduationYear => 'سنة التخرج';

  @override
  String get graduationLocation => 'مكان التخرج';

  @override
  String get awardingBody => 'الجهة المانحة / المدرسة';

  @override
  String get academicDesire1 => 'الرغبة الأولى';

  @override
  String get academicDesire2 => 'الرغبة الثانية';

  @override
  String get academicDesire3 => 'الرغبة الثالثة';

  @override
  String get college => 'الكلية';

  @override
  String get degreeLevel => 'الدرجة العلمية';

  @override
  String get bachelor => 'بكالوريوس';

  @override
  String get diploma => 'دبلوم';

  @override
  String get identityType => 'نوع الهوية';

  @override
  String get identityNumber => 'رقم الهوية';

  @override
  String get issuePlace => 'مكان الإصدار';

  @override
  String get issueDate => 'تاريخ الإصدار';

  @override
  String get mobileNumber => 'رقم الجوال';

  @override
  String get whatsappNumber => 'رقم الواتساب';

  @override
  String get homeAddress => 'عنوان السكن';

  @override
  String get landline => 'الهاتف الأرضي';

  @override
  String get guardianName => 'اسم ولي الأمر';

  @override
  String get relationship => 'صلة القرابة';

  @override
  String get guardianOccupation => 'وظيفة ولي الأمر';

  @override
  String get marketingQuestion => 'كيف سمعت عنا؟';

  @override
  String get friend => 'صديق';

  @override
  String get relative => 'قريب';

  @override
  String get teacher => 'مدرس';

  @override
  String get universityStudent => 'طالب في الجامعة';

  @override
  String get facebook => 'فيسبوك';

  @override
  String get instagram => 'إنستغرام';

  @override
  String get twitter => 'تويتر';

  @override
  String get radioTv => 'إذاعة / تلفزيون';

  @override
  String get billboards => 'لوحات إعلانية';

  @override
  String get reasonForChoosing => 'سبب اختيارك لنا';

  @override
  String get declarationText =>
      'أقر بأن جميع البيانات المدخلة أعلاه صحيحة وعلى مسؤوليتي الشخصية.';

  @override
  String get signature => 'التوقيع';

  @override
  String get clearSignature => 'مسح التوقيع';

  @override
  String get submit => 'إرسال';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'البريد الإلكتروني غير صالح';

  @override
  String get invalidNumber => 'رقم غير صالح';

  @override
  String get scientific => 'علمي';

  @override
  String get literary => 'أدبي';

  @override
  String get contactInfo => 'معلومات الاتصال';

  @override
  String get identityInfo => 'معلومات الهوية';

  @override
  String get contactDetails => 'تفاصيل الاتصال';

  @override
  String get guardianInfo => 'معلومات ولي الأمر';

  @override
  String get marketingInfo => 'معلومات تسويقية';

  @override
  String get declaration => 'الإقرار';

  @override
  String get single => 'أعزب';

  @override
  String get married => 'متزوج';

  @override
  String get divorced => 'مطلق';

  @override
  String get widowed => 'أرمل';

  @override
  String get verify => 'تحقق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get accountSecurity => 'أمان الحساب';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordLockedMsg => 'لا يمكن تغيير كلمة المرور قبل ٩٠ يوماً';

  @override
  String daysRemaining(Object count) {
    return 'باقي $count يوم';
  }

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get save => 'حفظ';

  @override
  String get warning => 'تنبيه';

  @override
  String get registrationFeeWarning =>
      'لن يتم قبول المعلومات التي أدخلتها إلا عند دفع رسوم التسجيل.';

  @override
  String get ok => 'حسناً';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordDesc =>
      'الرجاء إدخال البريد الإلكتروني أو رقم القيد الخاص بك للتحقق من هويتك.';

  @override
  String get emailOrIdLabel => 'البريد الإلكتروني / رقم القيد';

  @override
  String get verifyIdentityButton => 'تحقق من الهوية';

  @override
  String get identityVerifiedSuccess => 'تم التحقق من هويتك بنجاح!';

  @override
  String get mandatoryPasswordNotice =>
      'ملاحظة: كلمة المرور الجديدة ستكون هى كلمة المرور الدائمة الخاصة بك والتي ستستخدمها لتسجيل الدخول في المرات القادمة. كلمة المرور التي استخدمتها حالياً هي كلمة مرور مؤقتة فقط.';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get clearAllNotifications => 'مسح الكل';

  @override
  String get noNotificationsMsg => 'لا توجد إشعارات جديدة حالياً';

  @override
  String get registrationSuccessDesc =>
      'تم استلام طلبك. يرجى حفظ الرقم المرجعي للاستفسارات المستقبلية.';

  @override
  String get referenceNumberLabel => 'الرقم المرجعي';

  @override
  String get supportMessage =>
      'نحن هنا لمساعدتك! يمكنك التواصل معنا عبر أي من القنوات التالية:';

  @override
  String get phoneNumberLabel => 'رقم الهاتف';

  @override
  String get whatsappLabel => 'واتس آب';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get dummyNotification1Title => 'مرحباً بك في تطبيق الجامعة!';

  @override
  String get dummyNotification1Subtitle => 'انقر هنا لاستكشاف المميزات.';

  @override
  String get dummyNotification2Title => 'تحديث النظام';

  @override
  String get dummyNotification2Subtitle =>
      'تمت إضافة مميزات جديدة إلى عرض الجدول الدراسي.';

  @override
  String get dummyNotification3Title => 'الموعد النهائي للتسجيل';

  @override
  String get dummyNotification3Subtitle => 'يرجى إكمال مستنداتك بحلول الغد.';

  @override
  String get contactUniversity => 'تواصل مع الجامعة';

  @override
  String get major => 'التخصص';

  @override
  String get level => 'المستوى الدراسي';

  @override
  String get semester => 'الفصل الدراسي';

  @override
  String get academicYear => 'العام الجامعي';

  @override
  String get grievanceFormTitle => 'نموذج تظلم';

  @override
  String get studentInfo => 'معلومات الطالب';

  @override
  String get grievanceDetails => 'تفاصيل التظلم';

  @override
  String get grievanceResultsRequest => 'طلب تظلم عن النتائج';

  @override
  String get courseName => 'اسم المقرر';

  @override
  String get addCourse => 'إضافة مقرر';

  @override
  String get remove => 'إزالة';

  @override
  String get additionalInfo => 'معلومات إضافية';

  @override
  String get date => 'التاريخ';

  @override
  String get attachments => 'المرفقات';

  @override
  String get uploadAttachments => 'رفع المرفقات';

  @override
  String get payment => 'الرسوم';

  @override
  String get grievanceFee => 'رسوم التظلم: 10 دولار';

  @override
  String get uploadPaymentReceipt => 'رفع إيصال الدفع';

  @override
  String get submitGrievance => 'إرسال التظلم';

  @override
  String get pleaseFillRequiredFields => 'يرجى تعبئة جميع الحقول المطلوبة';

  @override
  String get success => 'تم بنجاح';

  @override
  String get successMessage =>
      'طلبك قيد المراجعة. ستتلقى رداً عبر البريد الإلكتروني.';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get viewSchedule => 'عرض الجدول';

  @override
  String get noStudySchedules =>
      'لا توجد جداول دراسية متاحة لمستواك وتخصصك الحالي.';

  @override
  String get notes => 'ملاحظات';

  @override
  String get pleaseSelectMajor =>
      'يرجى اختيار التخصص (الرغبة الأكاديمية الأولى)';

  @override
  String get idDocumentLabel => 'إرفاق صورة الهوية الوطنية / الإقامة / الجواز';

  @override
  String get arabicLettersOnly => 'يجب أن يحتوي على أحرف عربية فقط';

  @override
  String get englishLettersOnly => 'يجب أن يحتوي على أحرف إنجليزية فقط';

  @override
  String get minLengthFive => 'يجب ألا يقل عن 5 خانات';

  @override
  String get invalidMobileNumber => 'رقم الجوال غير صحيح (8 إلى 15 رقماً)';

  @override
  String get useThisNumberForPayment =>
      'يمكنك استخدام هذا الرقم في نموذج سداد الرسوم الخاصة بهذا الطلب.';

  @override
  String get passwordMinLength => 'يجب أن لا تقل كلمة المرور عن 8 خانات';

  @override
  String get passwordsDoNotMatch => 'كلمة المرور غير متطابقة';
}
