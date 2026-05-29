import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:university_app/core/theme/app_theme.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDetailsScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الإعلان')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              color: AppTheme.navyPrimary.withOpacity(0.1),
              child: Icon(
                _getIconForType(announcement['type']),
                size: 64,
                color: AppTheme.navyPrimary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (announcement['badge'] != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(
                          announcement['badge'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getBadgeColor(announcement['badge']),
                        ),
                      ),
                      child: Text(
                        announcement['badge'],
                        style: TextStyle(
                          color: _getBadgeColor(announcement['badge']),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  Text(
                    announcement['title'],
                    style: GoogleFonts.almarai(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navyPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        announcement['date'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  Text(
                    announcement['content'] ?? 'لا يوجد تفاصيل إضافية.',
                    style: GoogleFonts.almarai(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 40),

                  if (announcement['action'] != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تنفيذ الإجراء')),
                          );
                        },
                        icon: const Icon(Icons.touch_app),
                        label: Text(announcement['action']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.navyPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'results':
        return Icons.newspaper;
      case 'discount':
        return Icons.discount;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'survey':
        return Icons.poll;
      default:
        return Icons.article;
    }
  }

  Color _getBadgeColor(String badge) {
    if (badge == 'جديد') return Colors.green;
    if (badge == 'عاجل') return Colors.red;
    if (badge == 'هام') return AppTheme.goldAccent;
    return Colors.blue;
  }
}
