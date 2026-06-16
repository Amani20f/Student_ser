import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_dashboard/features/admissions/presentation/admissions_page.dart';
import 'package:admin_dashboard/features/admissions/providers/admissions_provider.dart';
import 'package:admin_dashboard/features/admissions/data/application_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:admin_dashboard/l10n/app_localizations.dart';

void main() {
  testWidgets('Test AdmissionsPage UI rendering', (WidgetTester tester) async {
    final mockApps = [
      ApplicationModel(
        id: 1,
        applicationNumber: 'APP-1',
        fullName: 'Test User 1',
        status: 'pending',
      ),
      ApplicationModel(
        id: 2,
        applicationNumber: 'APP-2',
        fullName: 'Test User 2',
        status: 'completed',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          applicationsListProvider.overrideWith((ref) => Future.value(mockApps)),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('ar')],
          locale: Locale('ar'),
          home: Scaffold(body: AdmissionsPage()),
        ),
      ),
    );

    // Wait for FutureProvider to emit data
    await tester.pumpAndSettle();

    print('### TEST FINISHED');
  });
}
