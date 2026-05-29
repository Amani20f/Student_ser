import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:university_app/core/theme/app_theme.dart';
import 'package:university_app/core/widgets/gradient_background.dart';
import 'announcement_details_screen.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  final List<Map<String, dynamic>> _announcements = const [
    {
      'id': 1,
      'title': 'صدور نتائج الفصل الدراسي الأول',
      'description':
          'نود إعلامكم بصدور النتائج النهائية لجميع الكليات عبر البوابة الأكاديمية.',
      'date': '10 فبراير 2024',
      'type': 'results',
      'badge': 'جديد',
      'action': 'عرض النتائج',
      'content':
          'تهنئ إدارة الجامعة جميع الطلاب الناجحين وتتمنى لهم دوام التوفيق. يمكنكم الآن الاطلاع على النتائج التفصيلية من خلال خدمة "طلب عرض درجات" في الصفحة الرئيسية.\n\nفترة التظلمات مفتوحة لمدة أسبوع من تاريخه.',
    },
    {
      'id': 2,
      'title': 'خصم خاص للتسجيل المبكر',
      'description':
          'احصل على خصم 10% عند سداد الرسوم الدراسية للفصل القادم قبل نهاية الشهر.',
      'date': '8 فبراير 2024',
      'type': 'discount',
      'badge': 'هام',
      'action': 'سداد الرسوم',
      'content':
          'تعلن الدائرة المالية عن فتح باب السداد المبكر للفصل الدراسي الثاني للعام 2023/2024 مع منح خصم تشجيعي قدره 10% للطلاب الذين يقومون بسداد كامل الرسوم قبل تاريخ 28 فبراير.\n\nاستغل الفرصة وسدد الآن!',
    },
    {
      'id': 3,
      'title': 'استبيان رضا الطلاب',
      'description':
          'شاركونا رأيكم في الخدمات الجامعية المقدمة لتطوير البيئة التعليمية.',
      'date': '5 فبراير 2024',
      'type': 'survey',
      'badge': null,
      'action': 'بدء الاستبيان',
      'content':
          'لأن رأيكم يهمنا، نرجو منكم تخصيص دقائق قليلة لتعبئة استبيان قياس رضا الطلاب عن الخدمات والمرافق الجامعية. مشاركتكم تساهم في التحسين المستمر.',
    },
    {
      'id': 4,
      'title': 'تنبيه: أعمال صيانة في المواقف',
      'description':
          'سيتم إغلاق البوابة الشمالية يوم السبت لأعمال الصيانة الدورية.',
      'date': '2 فبراير 2024',
      'type': 'alert',
      'badge': 'عاجل',
      'action': null,
      'content':
          'نلفت عناية طلبتنا الأعزاء بأنه سيتم إجراء أعمال صيانة طارئة في مواقف السيارات الشمالية يوم السبت القادم. يرجى استخدام البوابة الجنوبية للدخول.',
    },
    {
      'id': 5,
      'title': 'ساعات عمل المكتبة في الاختبارات',
      'description':
          'تم تمديد ساعات عمل المكتبة المركزية لتكون حتى الساعة 8 مساءً.',
      'date': '1 فبراير 2024',
      'type': 'notice',
      'badge': null,
      'action': null,
      'content':
          'تزامناً مع فترة الاختبارات النهائية، قررت إدارة المكتبة تمديد ساعات العمل لتوفير جو ملائم للمذاكرة. نرحب بكم يومياً من الساعة 8 صباحاً حتى 8 مساءً.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعلانات'),
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: ListView.builder(
          padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 100, // Extra padding for the bottom navigation bar
        ),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final item = _announcements[index];
          return _AnnouncementCard(announcement: item)
              .animate(delay: (index * 60).ms)
              .fadeIn(duration: 200.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.1,
                end: 0,
                duration: 200.ms,
                curve: Curves.easeOutQuart,
              );
        },
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AnnouncementDetailsScreen(announcement: announcement),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(announcement['type']),
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (announcement['badge'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getBadgeColor(announcement['badge']),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  announcement['badge'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Text(
                              announcement['date'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          announcement['title'],
                          style: GoogleFonts.almarai(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          announcement['description'],
                          style: GoogleFonts.almarai(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (announcement['action'] != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      announcement['action'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'results':
        return Icons.analytics_outlined;
      case 'discount':
        return Icons.percent;
      case 'alert':
        return Icons.notifications_active_outlined;
      case 'survey':
        return Icons.checklist_rtl;
      default:
        return Icons.article_outlined;
    }
  }

  Color _getBadgeColor(String badge) {
    if (badge == 'جديد') return Colors.green[600]!;
    if (badge == 'عاجل') return Colors.red[600]!;
    if (badge == 'هام') return AppTheme.goldAccent;
    return Colors.blue;
  }
}
