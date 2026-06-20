import 'dart:convert';
import 'package:admin_dashboard/features/admissions/data/application_model.dart';

void main() {
  final jsonString = '''
  {
      "id": 2,
      "application_number": "APP-2026-2553F9",
      "full_name": "اتا (hhhh)",
      "email_address": "hhhh@gm.vu",
      "phone_number": "+966987654321",
      "gender": "female",
      "nationality": "y",
      "date_of_birth": "2026-06-08",
      "status": "pending",
      "desired_program": "إدارة الأعمال",
      "department": "قسم إدارة الأعمال",
      "college": "كلية إدارة الأعمال",
      "submitted_at": "2026-06-14 17:20:02",
      "has_identity_doc": true,
      "has_qualification": true,
      "has_photo": true
  }
  ''';

  final jsonMap = jsonDecode(jsonString);
  try {
    final model = ApplicationModel.fromJson(jsonMap);
    print('Success: \${model.applicationNumber}');
  } catch (e) {
    print('Error: \$e\\n\$stack');
  }
}
