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
  String get verifyReferenceRequest => 'التحقق من الطلب';

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
      'هذا التسجيل مبدئي فقط ولا يعتبر قبولاً نهائياً في الجامعة. يجب على المتقدم الحضور شخصياً إلى الجامعة وتقديم جميع الوثائق والمستندات الرسمية المطلوبة واستكمال إجراءات القبول. لن يتم اعتماد الطلب إلا بعد مراجعة الوثائق وسداد الرسوم المطلوبة.';

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
  String get idDocumentLabel => 'إرفاق السند (إيصال السداد)';

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

  @override
  String get preliminaryRegistrationNote =>
      'هذا التسجيل مبدئي فقط ولا يعتبر قبولاً نهائياً، ويجب على المتقدم الحضور وتسليم جميع الوثائق الأصلية المطلوبة واستكمال إجراءات القبول لدى الجامعة.';

  @override
  String get registrationSuccessAlternativeDesc =>
      'تم استلام طلبك بنجاح. يمكنك متابعة حالة الطلب لاحقاً باستخدام رقم الهوية الوطنية أو الإقامة أو الجواز الذي تم التسجيل به.';

  @override
  String get uploadIdentityDocument => 'إرفاق الهوية الوطنية / الجواز';

  @override
  String get paymentReceiptLabel => 'سند الرسوم';

  @override
  String get navSurveys => 'الاستبيانات';

  @override
  String studentIdWithNumber(Object id) {
    return 'الرقم الجامعي: $id';
  }

  @override
  String get relatedRequestNotFound => 'الطلب المرتبط غير موجود أو تم حذفه.';

  @override
  String get errorLoadingRequestDetails =>
      'خطأ أثناء تحميل تفاصيل الطلب. يرجى المحاولة لاحقاً.';

  @override
  String get errorGeneric => 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.';

  @override
  String get errorClearNotifications =>
      'فشل مسح الإشعارات. يرجى المحاولة لاحقاً.';

  @override
  String get errorPhotoUpdate => 'فشل تحديث الصورة. يرجى المحاولة لاحقاً.';

  @override
  String get errorPhoneUpdate => 'فشل تحديث رقم الهاتف. يرجى المحاولة لاحقاً.';

  @override
  String get photoUpdatedSuccess => 'تم تحديث الصورة بنجاح';

  @override
  String get phoneUpdatedSuccess => 'تم تحديث رقم الهاتف بنجاح';

  @override
  String get editPhoneNumber => 'تعديل رقم الهاتف';

  @override
  String get pickFromGallery => 'اختيار من المعرض';

  @override
  String get dateOfBirthLabel => 'تاريخ الميلاد';

  @override
  String get genderLabel => 'الجنس';

  @override
  String get maleLabel => 'ذكر';

  @override
  String get femaleLabel => 'أنثى';

  @override
  String get nationalityLabel => 'الجنسية';

  @override
  String get studentNumberLabel => 'الرقم الجامعي';

  @override
  String get completedHours => 'الساعات المنجزة';

  @override
  String get remainingHours => 'الساعات المتبقية';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get passwordChangedSuccessMsg => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get statusSuspended => 'موقوف';

  @override
  String get statusGraduated => 'خريج';

  @override
  String get gradesAndResults => 'الدرجات والنتائج';

  @override
  String academicIdLabel(String id) {
    return 'الرقم الأكاديمي: $id';
  }

  @override
  String get cumulativeGpa => 'المعدل التراكمي';

  @override
  String get semesterGpa => 'المعدل الفصلي';

  @override
  String get semesterHoursLabel => 'ساعات معتمدة';

  @override
  String get academicSemester => 'الفصل الدراسي الأكاديمي';

  @override
  String get noSemestersRegistered => 'لا توجد فصول دراسية مسجلة';

  @override
  String get noGradesForSemester => 'لا توجد درجات متوفرة لهذا الفصل';

  @override
  String get pleaseSelectSemester => 'يرجى اختيار الفصل الدراسي لعرض الدرجات';

  @override
  String get courseNameCol => 'اسم المقرر';

  @override
  String get courseworkCol => 'الأعمال الفصلية';

  @override
  String get midtermCol => 'امتحان نصفي';

  @override
  String get finalExamCol => 'الدور الأول';

  @override
  String get controlGradeCol => 'درجة الكنترول';

  @override
  String get mercyGradeCol => 'درجة الرأفة';

  @override
  String get firstRoundStatusCol => 'حالة دور أول';

  @override
  String get retakeCol => 'الدور الثاني';

  @override
  String get retakeStatusCol => 'حالة الدور الثاني';

  @override
  String get retakeYearCol => 'سنة الإعادة';

  @override
  String get gpaCol => 'المعدل';

  @override
  String get gradeCol => 'التقدير';

  @override
  String get passedStatus => 'ناجح';

  @override
  String get failedStatus => 'راسب';

  @override
  String get incompleteStatus => 'غير مكتمل';

  @override
  String get surveyOpened => 'تم فتح الاستبيان';

  @override
  String get openSurvey => 'فتح الاستبيان';

  @override
  String get viewGrades => 'عرض الدرجات';

  @override
  String get pleaseCompleteSurveyFirst =>
      'يرجى فتح الاستبيان وتعبئته أولاً لتفعيل زر عرض الدرجات';

  @override
  String get surveyCompletedSuccess => 'تم تعبئة الاستبيان بنجاح — هذه درجاتك';

  @override
  String get failedToOpenSurveyLink => 'تعذر فتح رابط الاستبيان';

  @override
  String get errorLoadingGrades =>
      'خطأ في تحميل الدرجات. يرجى المحاولة لاحقاً.';

  @override
  String get surveysTitle => 'الاستبيانات';

  @override
  String get noOptionalSurveys => 'لا توجد استبيانات اختيارية في الوقت الحالي';

  @override
  String get noTitle => 'بدون عنوان';

  @override
  String get surveyViewed => 'تم الاطلاع';

  @override
  String get surveyNew => 'جديد';

  @override
  String get openSurveyBtn => 'فتح الاستبيان';

  @override
  String get errorLoadingSurveys =>
      'خطأ في تحميل الاستبيانات. يرجى المحاولة لاحقاً.';

  @override
  String get failedToOpenLink => 'تعذر فتح الرابط. الرجاء المحاولة مرة أخرى.';

  @override
  String get errorOpeningSurvey => 'حدث خطأ أثناء فتح الاستبيان';

  @override
  String get surveyRecordedSuccess => 'تم تسجيل الاستبيان بنجاح';

  @override
  String get requestDetails => 'تفاصيل الطلب';

  @override
  String get referenceNumberShort => 'الرقم المرجعي';

  @override
  String get requestType => 'نوع الطلب';

  @override
  String get requestStatus => 'حالة الطلب';

  @override
  String get paymentStatusLabel => 'حالة السداد';

  @override
  String get requestDetailsAndForm => 'تفاصيل ونموذج الطلب';

  @override
  String get rejectionReason => 'سبب الرفض';

  @override
  String get staffResponse => 'رد الموظف / اللجنة';

  @override
  String attachedFiles(Object count) {
    return 'المرفقات المرفقة ($count)';
  }

  @override
  String get failedToOpenAttachment => 'تعذر فتح المرفق';

  @override
  String get errorOpeningFile => 'خطأ أثناء فتح الملف. يرجى المحاولة لاحقاً.';

  @override
  String get payNow => 'سداد الرسوم الآن';

  @override
  String get statusApproved => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusPending => 'قيد المراجعة';

  @override
  String get statusRatified => 'معتمد مالياً';

  @override
  String get statusUnderReview => 'تحت الدراسة';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get paymentPaid => 'مدفوع';

  @override
  String get paymentPendingVerification => 'قيد التحقق';

  @override
  String get paymentRejected => 'مرفوض الدفع';

  @override
  String get paymentUnpaid => 'غير مدفوع';

  @override
  String get submitNewRequest => 'تقديم طلب جديد';

  @override
  String get myPreviousRequests => 'طلباتي السابقة';

  @override
  String get studentServicesPortal => 'بوابة الخدمات الطلابية';

  @override
  String get submitNewRequestTitle => 'تقديم طلب جديد';

  @override
  String get officialFormsSystem => 'نظام إدارة النماذج الرسمية للطلاب';

  @override
  String get errorLoadingRequests =>
      'حدث خطأ أثناء تحميل الطلبات. يرجى المحاولة لاحقاً.';

  @override
  String get failedToLoadRequests => 'فشل تحميل الطلبات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noPreviousRequests => 'لا توجد طلبات سابقة';

  @override
  String get noRequestsSubmitted => 'لم تقم بتقديم أي طلبات حتى الآن.';

  @override
  String get serviceRequest => 'طلب خدمة';

  @override
  String get submissionDate => 'تاريخ التقديم';

  @override
  String get lastUpdate => 'آخر تحديث';

  @override
  String get errorSubmission => 'فشل الإرسال. يرجى المحاولة لاحقاً.';

  @override
  String get errorLoadingAcademicData =>
      'فشل تحميل البيانات الأكاديمية. يرجى المحاولة لاحقاً.';

  @override
  String get totalGradeCol => 'الدرجة النهائية';

  @override
  String get announcementsTitle => 'الإعلانات';

  @override
  String get noAnnouncements => 'لا توجد إعلانات حالياً';

  @override
  String get couldNotLoadImage => 'تعذر تحميل الصورة';

  @override
  String get retryBtn => 'إعادة المحاولة';

  @override
  String get requestDetailsTitle => 'تفاصيل الطلب';

  @override
  String get submissionDateLabel => 'تاريخ التقديم:';

  @override
  String get lastUpdateLabel => 'آخر تحديث:';

  @override
  String get requestDescriptionTitle => 'تفاصيل الطلب والنموذج';

  @override
  String attachedFilesCount(int count) {
    return 'الملفات المرفقة ($count)';
  }

  @override
  String couldNotOpenAttachment(String path) {
    return 'تعذر فتح المرفق: $path';
  }

  @override
  String errorOpeningFileMsg(String error) {
    return 'خطأ أثناء فتح الملف: $error';
  }

  @override
  String get payFeesNow => 'سداد الرسوم الآن';

  @override
  String get requestTypeLabel => 'نوع الطلب';

  @override
  String get requestStatusLabel => 'حالة الطلب';

  @override
  String get rejectionReasonLabel => 'سبب الرفض';

  @override
  String get staffResponseLabel => 'رد الموظف / اللجنة';
}
