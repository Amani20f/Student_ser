import 'dart:io';
import 'dart:convert';

void main() async {
  print('Starting l10n fix for student_portal...');
  
  final Map<String, String> arNewKeys = {
    "pleaseSelectMajor": "يرجى اختيار التخصص (الرغبة الأكاديمية الأولى)",
    "idDocumentLabel": "إرفاق صورة الهوية الوطنية / الإقامة / الجواز",
    "arabicLettersOnly": "يجب أن يحتوي على أحرف عربية فقط",
    "englishLettersOnly": "يجب أن يحتوي على أحرف إنجليزية فقط",
    "minLengthFive": "يجب ألا يقل عن 5 خانات",
    "invalidMobileNumber": "رقم الجوال غير صحيح (8 إلى 15 رقماً)",
    "useThisNumberForPayment": "يمكنك استخدام هذا الرقم في نموذج سداد الرسوم الخاصة بهذا الطلب.",
    "passwordMinLength": "يجب أن لا تقل كلمة المرور عن 8 خانات",
    "passwordsDoNotMatch": "كلمة المرور غير متطابقة"
  };

  final Map<String, String> enNewKeys = {
    "pleaseSelectMajor": "Please select a major (First Academic Desire)",
    "idDocumentLabel": "Attach National ID / Iqama / Passport",
    "arabicLettersOnly": "Must contain Arabic letters only",
    "englishLettersOnly": "Must contain English letters only",
    "minLengthFive": "Must be at least 5 characters",
    "invalidMobileNumber": "Invalid mobile number (8 to 15 digits)",
    "useThisNumberForPayment": "You can use this number in the fee payment form for this request.",
    "passwordMinLength": "Password must be at least 8 characters",
    "passwordsDoNotMatch": "Passwords do not match"
  };

  Future<void> updateArb(String path, Map<String, String> newKeys) async {
    final file = File(path);
    if (!await file.exists()) return;
    
    final content = await file.readAsString();
    final Map<String, dynamic> json = jsonDecode(content);
    
    for (var key in newKeys.keys) {
      json[key] = newKeys[key];
    }
    
    final encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(json));
    print('Updated \$path');
  }

  await updateArb('lib/l10n/app_ar.arb', arNewKeys);
  await updateArb('lib/l10n/app_en.arb', enNewKeys);

  // File replacements
  final Map<String, List<List<String>>> replacements = {
    'lib/features/student_registration/cubit/registration_cubit.dart': [
      ["'يرجى اختيار التخصص (الرغبة الأكاديمية الأولى)'", "AppLocalizations.current.pleaseSelectMajor"],
    ],
    'lib/features/student_registration/widgets/declaration_step.dart': [
      ["const Text('إرفاق صورة الهوية الوطنية / الإقامة / الجواز')", "Text(l10n.idDocumentLabel)"],
    ],
    'lib/features/student_registration/widgets/personal_info_step.dart': [
      ["'مطلوب'", "l10n.requiredField"],
      ["'يجب أن يحتوي على أحرف عربية فقط'", "l10n.arabicLettersOnly"],
      ["'يجب أن يحتوي على أحرف إنجليزية فقط'", "l10n.englishLettersOnly"],
    ],
    'lib/features/student_registration/widgets/contact_step.dart': [
      ["'يجب ألا يقل عن 5 خانات'", "l10n.minLengthFive"],
      ["'رقم الجوال غير صحيح (8 إلى 15 رقماً)'", "l10n.invalidMobileNumber"],
    ],
    'lib/features/student_registration/widgets/academic_qualifications_step.dart': [
      ["'مطلوب'", "l10n.requiredField"],
      ["'رقم غير صحيح'", "l10n.invalidNumber"],
    ],
    'lib/features/student_registration/widgets/guardian_info_step.dart': [
      ["'رقم الجوال غير صحيح (8 إلى 15 رقماً)'", "l10n.invalidMobileNumber"],
    ],
    'lib/features/requests/widgets/success_dialog.dart': [
      ["const Text('يمكنك استخدام هذا الرقم في نموذج سداد الرسوم الخاصة بهذا الطلب.')", "Text(AppLocalizations.of(context)!.useThisNumberForPayment)"],
      ["const Text('موافق')", "Text(AppLocalizations.of(context)!.ok)"],
    ],
    'lib/features/settings/screens/settings_screen.dart': [
      ["'العربية'", "'العربية'"], // Skip
      ["'مطلوب'", "AppLocalizations.of(context)!.requiredField"],
      ["'يجب أن لا تقل كلمة المرور عن 8 خانات'", "AppLocalizations.of(context)!.passwordMinLength"],
      ["'كلمة المرور غير متطابقة'", "AppLocalizations.of(context)!.passwordsDoNotMatch"],
    ],
  };

  for (var entry in replacements.entries) {
    final file = File(entry.key);
    if (!await file.exists()) continue;
    
    var content = await file.readAsString();
    bool changed = false;
    
    // Auto import app_localizations if missing
    if (!content.contains('app_localizations.dart') && entry.value.any((v) => v[1].contains('AppLocalizations'))) {
      if (content.contains('import')) {
        content = content.replaceFirst('import', "import 'package:university_app/l10n/app_localizations.dart';\nimport");
        changed = true;
      }
    }
    
    for (var rep in entry.value) {
      if (content.contains(rep[0])) {
        content = content.replaceAll(rep[0], rep[1]);
        changed = true;
      }
    }
    
    if (changed) {
      await file.writeAsString(content);
      print('Updated \${entry.key}');
    }
  }
}
