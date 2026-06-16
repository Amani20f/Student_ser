import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:admin_dashboard/features/admissions/presentation/admissions_page.dart';
import 'package:admin_dashboard/features/admissions/providers/admissions_provider.dart';
import 'package:admin_dashboard/core/network/api_client.dart';
import 'package:admin_dashboard/core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MyHttpOverrides();
  });

  testWidgets('AdmissionsPage integration test to print logs', (WidgetTester tester) async {
    // 1. Get real token from API
    final loginResponse = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': 'admin@university.edu', 'password': 'password'}),
    );
    final token = jsonDecode(loginResponse.body)['data']['token'];
    
    // 2. Setup SharedPreferences
    SharedPreferences.setMockInitialValues({'auth_token': token});
    final prefs = await SharedPreferences.getInstance();

    // 3. Build widget with ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          locale: const Locale('ar'),
          home: const Scaffold(body: AdmissionsPage()),
        ),
      ),
    );

    // 4. Wait for FutureProvider to resolve
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Wait some more if needed
    await tester.pump(const Duration(seconds: 2));

    print('### TEST COMPLETE. Check above logs for the injected print statements.');
  });
}
