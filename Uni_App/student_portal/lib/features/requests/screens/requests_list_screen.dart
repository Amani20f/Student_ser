import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/features/auth/cubit/auth_cubit.dart';
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
import 'my_requests_screen.dart';

class RequestsListScreen extends StatefulWidget {
  const RequestsListScreen({super.key});

  @override
  State<RequestsListScreen> createState() => _RequestsListScreenState();
}

class _RequestsListScreenState extends State<RequestsListScreen> {
  int _selectedTab = 0; // 0: Submit New Request, 1: My Requests

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Tab 0: Submit New Request
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'تقديم طلب جديد',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 0
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                ),
              ),
            ),
          ),
          // Tab 1: My Requests
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'طلباتي السابقة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 1
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة الخدمات الطلابية'),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Custom premium tab bar selector
            _buildTabBar(context),
            const SizedBox(height: 10),

            // Tab content
            Expanded(
              child: _selectedTab == 1
                  ? const MyRequestsScreen()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // University Logo
                          Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),

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

                              if (snapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                      const SizedBox(height: 16),
                                      Text(
                                        'حدث خطأ أثناء تحميل الطلبات',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        snapshot.error.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
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

                              final authState = context.watch<AuthCubit>().state;
                              bool isSuspended = false;
                              if (authState is Authenticated) {
                                final user = authState.user;
                                final student = user['student'];
                                if (student != null) {
                                  isSuspended = student['status']?.toString().toLowerCase() == 'suspended';
                                }
                              }

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
                                      final bool isRestricted = isSuspended &&
                                          request.id != '2' &&
                                          request.id != '4' &&
                                          request.id != '6';

                                      return RequestCard(
                                        request: request,
                                        isDisabled: isRestricted,
                                        onTap: () {
                                          if (isRestricted) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('تنبيه'),
                                                content: const Text(
                                                  'عذراً، حسابك موقوف أكاديمياً. يمكنك فقط تقديم طلب إعادة قيد أو سداد الرسوم.',
                                                  style: TextStyle(height: 1.5),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('موافق'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            return;
                                          }

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
          ],
        ),
      ),
    );
  }
}
