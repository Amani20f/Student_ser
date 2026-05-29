import 'package:flutter/material.dart';

class RequestType {
  final String id;
  final String title;
  final String description;
  final String formUrl;
  final String iconPath;
  final Color? accentColor;
  final bool isGradesRequest;
  final IconData icon;

  RequestType({
    required this.id,
    required this.title,
    required this.description,
    required this.formUrl,
    this.iconPath = '',
    this.accentColor,
    this.isGradesRequest = false,
    this.icon = Icons.description_outlined,
  });
}

// Mock Data
final List<RequestType> mockRequestTypes = [
  RequestType(
    id: '1',
    title: 'طلب إيقاف قيد',
    description:
        'يستخدم هذا النموذج لطلب إيقاف القيد الأكاديمي لمساعدة الطالب في ظروفه الخاصة.',
    formUrl: 'https://example.com/forms/enrollment_suspension.pdf',
    accentColor: const Color(0xFF001F3F),
    icon: Icons.pause_circle_outline_rounded,
  ),
  RequestType(
    id: '2',
    title: 'طلب إعادة قيد',
    description:
        'يستخدم هذا النموذج لطلب استئناف الدراسة بعد فترة إيقاف أو انقطاع.',
    formUrl: 'https://example.com/forms/re_enrollment.pdf',
    accentColor: const Color(0xFFC5A070),
    icon: Icons.refresh_rounded,
  ),
  RequestType(
    id: '3',
    title: 'طلب رفع تظلم',
    description:
        'يستخدم هذا النموذج لتقديم اعتراض رسمي على نتيجة أكاديمية أو قرار.',
    formUrl: 'https://example.com/forms/grievance.pdf',
    accentColor: const Color(0xFF455A64),
    icon: Icons.gavel_rounded,
  ),
  RequestType(
    id: '4',
    title: 'طلب عرض درجات',
    description: 'يستخدم هذا الطلب لمراجعة الدرجات الأكاديمية للفصل الحالي.',
    formUrl: '',
    isGradesRequest: true,
    accentColor: const Color(0xFFE67E22),
    icon: Icons.bar_chart_rounded,
  ),
  RequestType(
    id: '5',
    title: 'طلب غياب',
    description:
        'يستخدم هذا النموذج لتقديم عذر رسمي عن الغياب عن المحاضرات أو الاختبارات.',
    formUrl: 'https://example.com/forms/absence_request.pdf',
    accentColor: const Color(0xFF2C3E50),
    icon: Icons.event_busy_rounded,
  ),
  RequestType(
    id: '6',
    title: 'سداد الرسوم',
    description: 'يستخدم هذا النموذج لرفع إيصالات السداد للخدمات المختلفة.',
    formUrl: '',
    accentColor: const Color(0xFF27AE60),
    iconPath: 'assets/icons/payment.png',
    icon: Icons.payment_rounded,
  ),
];
