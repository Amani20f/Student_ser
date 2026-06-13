import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:university_app/features/requests/data/requests_repository.dart';
import 'package:university_app/features/requests/models/request_model.dart';
import 'package:university_app/features/requests/widgets/request_card.dart';
import 'package:university_app/features/requests/screens/request_detail_screen.dart';
import 'package:university_app/features/requests/screens/forms/stop_enrollment_form.dart';
import 'package:university_app/features/requests/screens/forms/re_enrollment_form.dart';
import 'package:university_app/features/requests/screens/forms/excused_absence_form.dart';
import 'package:university_app/features/requests/screens/forms/grievance_form.dart';
import 'package:university_app/features/requests/screens/forms/payment_form.dart';
import 'package:university_app/features/requests/screens/grades_screen.dart';
import 'package:university_app/core/widgets/gradient_background.dart';

class RequestsListScreen extends StatelessWidget {
  const RequestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة الطلبات'),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // University Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      'تقديم طلب جديد',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'نظام إدارة النماذج الرسمية للطلاب',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<dynamic>>(
                future: context.read<RequestsRepository>().getActiveRequestTypes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    );
                  }

                  final activeTypesList = snapshot.data ?? [];
                  final activeDbIds = activeTypesList.map((e) => e['id'].toString()).toSet();

                  final visibleRequests = mockRequestTypes.where((req) {
                    if (req.id == '1') return activeDbIds.contains('2'); // Stop Enrollment
                    if (req.id == '2') return activeDbIds.contains('3'); // Re Enrollment
                    if (req.id == '3') return activeDbIds.contains('4'); // Grievance
                    if (req.id == '5') return activeDbIds.contains('1'); // Absence
                    if (req.id == '4' || req.id == '6') return true; // Always show grades & payment
                    return true;
                  }).toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount;
                      if (constraints.maxWidth > 1000) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth > 700) {
                        crossAxisCount = 2;
                      } else {
                        crossAxisCount = 1;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(40, 8, 40, 48),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 1.25,
                        ),
                        itemCount: visibleRequests.length,
                        itemBuilder: (context, index) {
                          final request = visibleRequests[index];
                          return RequestCard(
                            request: request,
                            onTap: () {
                              if (request.id == '1') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StopEnrollmentScreen(),
                                  ),
                                );
                              } else if (request.id == '2') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ReEnrollmentScreen(),
                                  ),
                                );
                              } else if (request.id == '3') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GrievanceFormScreen(),
                                  ),
                                );
                              } else if (request.id == '5') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ExcusedAbsenceScreen(),
                                  ),
                                );
                              } else if (request.id == '6') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PaymentFormScreen(),
                                  ),
                                );
                              } else if (request.id == '4') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GradesScreen(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RequestDetailScreen(request: request),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
