import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:university_app/core/network/api_client.dart';
import 'package:university_app/core/constants/api_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class OptionalSurveysScreen extends StatefulWidget {
  const OptionalSurveysScreen({super.key});

  @override
  State<OptionalSurveysScreen> createState() => _OptionalSurveysScreenState();
}

class _OptionalSurveysScreenState extends State<OptionalSurveysScreen> {
  bool _isLoading = true;
  List<dynamic> _surveys = [];

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      
      final response = await context.read<ApiClient>().get(ApiConstants.optionalSurveys);
      
      if (mounted) {
        setState(() {
          _surveys = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الاستبيانات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsViewed(int id, String url) async {
    try {
      final parsedUrl = Uri.parse(url);
      bool launched = false;

      if (await canLaunchUrl(parsedUrl)) {
        launched = await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
      }

      if (launched) {
        await context.read<ApiClient>().post(ApiConstants.markOptionalSurveyViewed(id));
        _loadSurveys(); // Refresh list to update status
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح الرابط. الرجاء المحاولة مرة أخرى.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء فتح الاستبيان'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستبيانات'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? const Center(child: Text('لا توجد استبيانات اختيارية في الوقت الحالي'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _surveys.length,
                  itemBuilder: (context, index) {
                    final survey = _surveys[index];
                    final isViewed = survey['is_viewed'] == true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => _markAsViewed(survey['id'], survey['google_form_url']),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      survey['title'] ?? 'بدون عنوان',
                                      style: GoogleFonts.almarai(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isViewed ? Colors.green.withOpacity(0.1) : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isViewed ? 'تم الاطلاع' : 'جديد',
                                      style: GoogleFonts.almarai(
                                        color: isViewed ? Colors.green : Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                survey['description'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    survey['created_at'] != null 
                                      ? survey['created_at'].toString().split('T')[0]
                                      : '',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () => _markAsViewed(survey['id'], survey['google_form_url']),
                                    icon: const Icon(Icons.open_in_new, size: 16),
                                    label: const Text('فتح الاستبيان'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
