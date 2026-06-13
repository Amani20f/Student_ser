import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var url = Uri.parse('http://localhost:8000/api/admin/announcements');
  
  // Login to get token first
  var loginRes = await http.post(
    Uri.parse('http://localhost:8000/api/login'),
    body: {'username': 'admin_test_123', 'password': 'password123'},
  );
  var token = jsonDecode(loginRes.body)['access_token'];
  
  var request = http.MultipartRequest('POST', url);
  request.headers['Authorization'] = 'Bearer $token';
  request.headers['Accept'] = 'application/json';
  
  // Simulate provider logic
  var data = {
    'title': 'Test title',
    'content': 'Test content',
    'target_audience': 'all_students',
    'is_active': true,
    'send_notification': false,
  };
  
  var stringData = data.map((key, value) => MapEntry(key, value.toString()));
  request.fields.addAll(stringData);
  
  // Add a fake file
  request.files.add(http.MultipartFile.fromString('image', 'fake image content', filename: 'test.jpg'));
  
  print('Sending request...');
  var streamedRes = await request.send();
  var res = await http.Response.fromStream(streamedRes);
  
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
