import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'http://127.0.0.1:8000/api/apply';

  Future<void> testUpload(String name, String ext, List<int> bytes, Map<String, String> fields) async {
    print('--- Testing $name ---');
    
    // Create temp files
    final f1 = File('id.$ext')..writeAsBytesSync(bytes);
    final f2 = File('qual.$ext')..writeAsBytesSync(bytes);
    final f3 = File('photo.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01]);

    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);
    
    request.files.add(await http.MultipartFile.fromPath('identity_document', f1.path));
    request.files.add(await http.MultipartFile.fromPath('qualification_document', f2.path));
    request.files.add(await http.MultipartFile.fromPath('personal_photo', f3.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    
    print('Status: ${response.statusCode}');
    print('Body: $responseData');
  }

  final pdfBytes = "%PDF-1.4\\n1 0 obj\\n<<\\n/Type /Catalog\\n/Pages 2 0 R\\n>>\\nendobj\\ntrailer\\n<<\\n/Root 1 0 R\\n>>\\n%%EOF".codeUnits;
  final jpgBytes = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01];
  final pngBytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

  final baseFields = {
    'full_name': 'Test User',
    'gender': 'male', 'nationality': 'SA', 'date_of_birth': '2000-01-01',
    'phone_number': '0500000000', 'desired_program_id': '2', 'desired_academic_level': '1'
  };

  await testUpload('PDF Upload', 'pdf', pdfBytes, {...baseFields, 'national_id_number': '1000000010', 'email_address': 'pdf10@test.com'});
  await testUpload('JPG Upload', 'jpg', jpgBytes, {...baseFields, 'national_id_number': '1000000011', 'email_address': 'jpg11@test.com'});
  await testUpload('PNG Upload', 'png', pngBytes, {...baseFields, 'national_id_number': '1000000012', 'email_address': 'png12@test.com'});
  
  await testUpload('Duplicate National ID', 'jpg', jpgBytes, {...baseFields, 'national_id_number': '1000000011', 'email_address': 'dup_id@test.com'});
  await testUpload('Duplicate Email', 'jpg', jpgBytes, {...baseFields, 'national_id_number': '1000000013', 'email_address': 'jpg11@test.com'});
  
  final missingMajorFields = Map<String, String>.from(baseFields);
  missingMajorFields.remove('desired_program_id');
  await testUpload('Missing Major', 'jpg', jpgBytes, {...missingMajorFields, 'national_id_number': '1000000014', 'email_address': 'major@test.com'});
}
