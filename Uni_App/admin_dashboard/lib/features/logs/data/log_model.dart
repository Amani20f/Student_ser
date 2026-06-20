class LogModel {
  final int id;
  final String? causer;
  final String? causerRole;
  final String? action;
  final String? subjectType;
  final int? subjectId;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? createdAt;

  const LogModel({
    required this.id,
    this.causer,
    this.causerRole,
    this.action,
    this.subjectType,
    this.subjectId,
    this.oldValues,
    this.newValues,
    this.createdAt,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      causer: json['causer']?.toString(),
      causerRole: json['causerRole']?.toString(),
      action: json['action']?.toString(),
      subjectType: json['subjectType']?.toString(),
      subjectId: json['subjectId'] != null
          ? int.tryParse(json['subjectId'].toString())
          : null,
      oldValues: json['oldValues'] is Map<String, dynamic>
          ? json['oldValues'] as Map<String, dynamic>
          : null,
      newValues: json['newValues'] is Map<String, dynamic>
          ? json['newValues'] as Map<String, dynamic>
          : null,
      createdAt: json['createdAt']?.toString(),
    );
  }

  String get oldValuesDisplay => oldValues != null ? oldValues.toString() : '-';

  String get newValuesDisplay => newValues != null ? newValues.toString() : '-';

  String getDescription(bool isAr) {
    final causerDisplay = causer != null ? '$causer (${causerRole ?? (isAr ? "نظام" : "System")})' : (isAr ? 'النظام' : 'System');
    final sId = subjectId != null ? '#$subjectId' : '';
    switch (action) {
      case 'login':
        return isAr ? 'قام $causerDisplay بتسجيل الدخول' : '$causerDisplay logged in';
      case 'logout':
        return isAr ? 'قام $causerDisplay بتسجيل الخروج' : '$causerDisplay logged out';
      case 'user_created':
        final name = newValues?['name'] ?? '';
        return isAr ? 'قام $causerDisplay بإنشاء حساب المستخدم $name' : '$causerDisplay created user $name';
      case 'user_deleted':
        final name = oldValues?['name'] ?? '';
        return isAr ? 'قام $causerDisplay بحذف حساب المستخدم $name' : '$causerDisplay deleted user $name';
      case 'request_created':
        return isAr ? 'قام $causerDisplay بتقديم طلب جديد $sId' : '$causerDisplay submitted a new request $sId';
      case 'request_approved':
        return isAr ? 'قام $causerDisplay بالموافقة على الطلب $sId' : '$causerDisplay approved request $sId';
      case 'request_rejected':
        return isAr ? 'قام $causerDisplay برفض الطلب $sId' : '$causerDisplay rejected request $sId';
      case 'payment_verified':
        return isAr ? 'قام $causerDisplay بالتحقق من دفعة الطلب $sId' : '$causerDisplay verified payment for request $sId';
      case 'payment_rejected':
        return isAr ? 'قام $causerDisplay برفض دفعة الطلب $sId' : '$causerDisplay rejected payment for request $sId';
      case 'grade_updated':
        return isAr ? 'قام $causerDisplay بتعديل الدرجة $sId' : '$causerDisplay updated grade $sId';
      case 'payment_created':
        return isAr ? 'قام $causerDisplay بتقديم إيصال الدفع $sId' : '$causerDisplay submitted payment receipt $sId';
      case 'grade_created':
        return isAr ? 'قام $causerDisplay بإدخال الدرجة $sId' : '$causerDisplay entered grade $sId';
      default:
        return isAr 
          ? 'قام $causerDisplay بـ $action على $subjectType $sId' 
          : '$causerDisplay performed $action on $subjectType $sId';
    }
  }
}
