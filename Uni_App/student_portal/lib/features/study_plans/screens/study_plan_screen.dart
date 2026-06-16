import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repositories/study_plan_repository.dart';
import '../models/study_plan_model.dart';
import 'package:university_app/l10n/app_localizations.dart';
import '../../../../core/network/api_client.dart';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  late Future<StudyPlanModel?> _planFuture;

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    final repository = StudyPlanRepository(apiClient);
    _planFuture = repository.getCurrentStudyPlan();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الخطة الدراسية' : 'Study Plan'),
        centerTitle: true,
      ),
      body: FutureBuilder<StudyPlanModel?>(
        future: _planFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${isAr ? 'خطأ' : 'Error'}: ${snapshot.error}'));
          }

          final plan = snapshot.data;
          if (plan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'لا توجد خطة دراسية متاحة لتخصصك حالياً' : 'No study plan available for your program yet.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.picture_as_pdf, size: 48, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          plan.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (plan.program != null)
                          Text(
                            plan.program!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 16),
                        if (plan.uploadedAt != null)
                          Text(
                            '${isAr ? 'تاريخ الرفع' : 'Uploaded at'}: ${plan.uploadedAt.toString().split(' ')[0]}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (plan.fileUrl != null && plan.fileUrl!.isNotEmpty) {
                      final uri = Uri.parse(plan.fileUrl!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isAr ? 'رابط الملف غير متاح' : 'File URL is not available'),
                        ));
                      }
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(isAr ? 'تحميل وعرض الخطة (PDF)' : 'Download & View Plan (PDF)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
