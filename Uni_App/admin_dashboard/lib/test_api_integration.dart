import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admin_dashboard/features/admissions/data/application_model.dart';

Future<void> main() async {
  print('### Testing Login for student affairs...');
  final loginResponse = await http.post(
    Uri.parse('http://127.0.0.1:8000/api/login'),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({'email': 'affairs@university.edu', 'password': 'password'}),
  );

  if (loginResponse.statusCode != 200) {
    print('Login Failed: ${loginResponse.statusCode} - ${loginResponse.body}');
    return;
  }

  final loginData = jsonDecode(loginResponse.body);
  final token = loginData['data']['token'];
  print('### Token obtained: ' + token.substring(0, 10));

  print('### Fetching Applications (1- استدعاء API مباشرة)...');
  final appsResponse = await http.get(
    Uri.parse('http://127.0.0.1:8000/api/admin/applications'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token,
    },
  );

  print('### Response Status: ${appsResponse.statusCode}');
  
  if (appsResponse.statusCode == 200) {
    final responseData = jsonDecode(appsResponse.body);
    
    print('1- Response JSON الكامل: ${appsResponse.body.substring(0, 150)}... (truncated)');
    
    final dataList = responseData['data'] as List<dynamic>;
    print('2- عدد العناصر (response["data"].length): ${dataList.length}');
    
    try {
      final parsedList = dataList.map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
      print('3- عدد العناصر بعد ApplicationModel.fromJson: ${parsedList.length}');
      print('4- عدد العناصر داخل AdmissionsProvider قبل return: ${parsedList.length}');
      print('5- عدد العناصر داخل AdmissionsPage بعد ref.watch: ${parsedList.length}');
      print('6- قيمة apps.length قبل ListView مباشرة: ${parsedList.length}');
    } catch (e, stack) {
      print('### Parsing Error: $e\n$stack');
    }
  } else {
    print('### API Error: ${appsResponse.body}');
  }
}
