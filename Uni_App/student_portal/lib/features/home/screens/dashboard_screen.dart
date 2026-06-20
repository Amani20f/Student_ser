import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/l10n/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/normalization.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../study_plans/screens/study_plan_screen.dart';
import '../../requests/data/requests_repository.dart';
import '../../requests/screens/my_request_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _notifications = [];
  bool _isLoadingNotifications = true;
  Map<String, dynamic>? _latestSchedule;
  bool _isLoadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadLatestSchedule();
  }

  void _loadNotifications() async {
    try {
      final response = await context.read<ApiClient>().get('/student/notifications');
      setState(() {
        _notifications = response['data'] ?? [];
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  void _markAsRead(int id) async {
    try {
      await context.read<ApiClient>().put('/student/notifications/$id/read', body: {});
      setState(() {
        for (var n in _notifications) {
          if (n['id'] == id) {
            n['is_read'] = true;
          }
        }
      });
    } catch (e) {
      // Ignore
    }
  }

  Future<bool> _clearAllNotifications() async {
    try {
      await context.read<ApiClient>().delete('/student/notifications');
      if (mounted) {
        setState(() {
          _notifications = [];
        });
      }
      return true;
    } catch (e) {
      debugPrint('[Dashboard] clearAll notifications error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorClearNotifications),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  void _loadLatestSchedule() async {
    try {
      // 1. Fetch semesters to find the active one
      final semestersResponse = await context.read<ApiClient>().get('/semesters');
      final semesters = (semestersResponse['data'] as List<dynamic>?) ?? [];
      final activeSemester = semesters.firstWhere(
        (s) => s['is_current'] == true,
        orElse: () => null,
      );

      if (activeSemester != null) {
        // 2. Fetch schedule
        final scheduleResponse = await context.read<ApiClient>().get(
          '/student/study-schedules?semester_id=${activeSemester['id']}',
        );
        
        final scheduleData = scheduleResponse['data'];
        
        if (scheduleData != null && scheduleData is Map<String, dynamic>) {
          setState(() {
            _latestSchedule = scheduleData;
          });
        }
      }
    } catch (e) {
      debugPrint('[Dashboard] schedule load error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSchedule = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['is_read'] == false).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.dashboardTitle,
        ), // Or maybe empty/logo
        actions: [
          IconButton(
            onPressed: () {
              _showNotificationsDialog(context);
            },
            icon: unreadCount > 0
                ? Badge(
                    label: Text(unreadCount.toString()),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 100.0, // Extra padding for the bottom navigation bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                [
                      // Student Card
                      _buildStudentCard(context),
                      const SizedBox(height: 24),


                      // Schedule
                      Text(
                        AppLocalizations.of(context)!.mySchedule,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildScheduleCard(context),
                      const SizedBox(height: 24),
                      
                      // Study Plan Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudyPlanScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'عرض الخطة الدراسية'
                              : 'View Study Plan',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ]
                    .animate(interval: 30.ms)
                    .fadeIn(duration: 200.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 200.ms,
                      curve: Curves.easeOutQuart,
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    Map<String, dynamic> user = {};
    Map<String, dynamic> student = {};
    Map<String, dynamic> program = {};
    if (authState is Authenticated) {
      user = authState.user;
      student = user['student'] ?? {};
      program = student['program'] ?? {};
    }

    final name = user['name'] ?? AppLocalizations.of(context)!.studentName;
    final profilePhoto = student['profile_photo_path'];
    final studentIdNum = student['student_number'] ?? '';
    final l10n = AppLocalizations.of(context)!;
    final studentIdLabel = studentIdNum.isNotEmpty
        ? l10n.studentIdWithNumber(studentIdNum)
        : l10n.studentId;
    final major = program['name'] ?? AppLocalizations.of(context)!.majorValue;
    final rawGpa = student['cumulative_gpa'];
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final gpa = rawGpa == null
        ? (isAr ? 'غير متوفر' : 'N/A')
        : double.parse(rawGpa.toString()).toStringAsFixed(2);
    final level = (student['current_level'] ?? '1').toString();
    final statusVal = student['status']?.toString().toLowerCase() ?? 'active';

    String getStatusTranslation(String status) {
      switch (status) {
        case 'active':
          return isAr ? 'نشط' : 'Active';
        case 'suspended':
          return isAr ? 'موقوف' : 'Suspended';
        case 'graduated':
          return isAr ? 'خريج' : 'Graduated';
        default:
          return status;
      }
    }

    Color getStatusColor(String status) {
      switch (status) {
        case 'active':
          return Colors.green;
        case 'suspended':
          return Colors.red;
        case 'graduated':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00695C), // Darker Teal
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                backgroundImage: profilePhoto != null && profilePhoto.isNotEmpty ? NetworkImage(profilePhoto) : null,
                                child: profilePhoto == null || profilePhoto.isEmpty
                                  ? Text(
                                      (name.isNotEmpty) ? name[0] : 'U',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                                    )
                                  : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      studentIdLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: getStatusColor(statusVal).withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          getStatusTranslation(statusVal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildStudentInfoItem(
                          context,
                          AppLocalizations.of(context)!.majorLabel,
                          major,
                          Icons.school,
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      Expanded(
                        child: _buildStudentInfoItem(
                          context,
                          AppLocalizations.of(context)!.gpaLabel,
                          gpa,
                          Icons.star_rate_rounded,
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      Expanded(
                        child: _buildStudentInfoItem(
                          context,
                          AppLocalizations.of(context)!.levelLabel,
                          level,
                          Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }



  Widget _buildScheduleCard(BuildContext context) {
    if (_isLoadingSchedule) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_latestSchedule == null) {
      return Container(
        height: 180,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noStudySchedules,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final schedule = _latestSchedule!;
    final notes = schedule['title'] as String?;
    final rawImageUrl = schedule['file_url'] as String?;
    final imageUrl = rawImageUrl != null ? normalizeFileUrl(rawImageUrl) : null;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Subtle Grid Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: GridPaper(
                  color: AppTheme.primaryColor,
                  divisions: 2,
                  subdivisions: 2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          size: 28,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (schedule['program'] != null)
                              Text(
                                '${schedule['program']}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            if (schedule['level'] != null || schedule['term'] != null || schedule['academic_year'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (schedule['term'] != null) schedule['term'],
                                  if (schedule['academic_year'] != null) schedule['academic_year'],
                                  if (schedule['level'] != null) '${l10n.level} ${schedule['level']}',
                                ].join(' - '),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (notes != null && notes.isNotEmpty && !['schedule', 'study schedule', 'جدول دراسي', 'الجدول الدراسي'].contains(notes.toLowerCase().trim())) ...[
                    const SizedBox(height: 16),
                    Text(
                      notes,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  if (imageUrl != null) ...[
                    const SizedBox(height: 16),
                    if (RegExp(r'\.(png|jpg|jpeg|webp|gif)(\?|$)', caseSensitive: false).hasMatch(imageUrl) || 
                        (!imageUrl.toLowerCase().contains('.pdf') && !imageUrl.toLowerCase().contains('.docx') && !imageUrl.toLowerCase().contains('.doc'))) ...[
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child: Image.network(imageUrl!),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('[Dashboard] Image load error: $error');
                              return Container(
                                height: 100,
                                color: Colors.red.withValues(alpha: 0.1),
                                child: const Center(child: Icon(Icons.broken_image, color: Colors.red)),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(imageUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: Text(l10n.viewSchedule),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        // Use StatefulBuilder so the sheet can reflect live state changes
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            final isDark = Theme.of(builderContext).brightness == Brightness.dark;
            // Mirror the parent's notification list into the sheet
            final sheetNotifications = _notifications;

            return Container(
              height: MediaQuery.of(builderContext).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(builderContext)!.notificationsTitle,
                          style: Theme.of(builderContext).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (sheetNotifications.isNotEmpty)
                          TextButton.icon(
                            onPressed: () async {
                              final original = List.from(_notifications);
                              // Optimistically clear in the sheet
                              setSheetState(() {
                                _notifications = [];
                              });
                              final success = await _clearAllNotifications();
                              if (!success && mounted) {
                                setSheetState(() {
                                  _notifications = original;
                                });
                              }
                            },
                            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                            label: Text(
                              AppLocalizations.of(builderContext)!.clearAllNotifications,
                              style: TextStyle(
                                color: Theme.of(builderContext).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(builderContext).colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: _isLoadingNotifications
                        ? const Center(child: CircularProgressIndicator())
                        : sheetNotifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_off_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(builderContext)!.noNotificationsMsg,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: sheetNotifications.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = sheetNotifications[index];
                                  final isRead = item['is_read'] == true;

                                  IconData icon = Icons.notifications_outlined;
                                  Color color = AppTheme.primaryColor;
                                  if (item['related_type'] == 'announcement') {
                                    icon = Icons.campaign_outlined;
                                    color = Colors.orange;
                                  } else if (item['related_type'] == 'grade') {
                                    icon = Icons.grade_outlined;
                                    color = Colors.blue;
                                  } else if (item['related_type'] == 'service_request') {
                                    icon = Icons.description_outlined;
                                    color = Colors.teal;
                                  }

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(icon, color: color),
                                    ),
                                    title: Text(
                                      item['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight:
                                            isRead ? FontWeight.normal : FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        item['message'] ?? '',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    trailing: !isRead
                                        ? Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          )
                                        : null,
                                     onTap: () async {
                                       if (!isRead) {
                                         _markAsRead(item['id']);
                                         setSheetState(() {
                                           item['is_read'] = true;
                                         });
                                       }
                                                  final relatedType = item['related_type']?.toString();
                                       final relatedId = item['related_id'];

                                       if (relatedId != null && relatedType != null) {
                                         final typeLower = relatedType.toLowerCase();
                                         final isAppeal = typeLower.contains('appeal') || typeLower.contains('grievance');
                                         final isRequest = typeLower.contains('request') || typeLower.contains('payment');

                                         if (isRequest || isAppeal) {
                                           // Show loading indicator or dialog
                                           showDialog(
                                             context: context,
                                             barrierDismissible: false,
                                             builder: (context) => const Center(
                                               child: CircularProgressIndicator(),
                                             ),
                                           );

                                           try {
                                             final requestsRepo = context.read<RequestsRepository>();
                                             final allRequests = await requestsRepo.getMyRequests();
                                             
                                             // Dismiss loading dialog
                                             if (context.mounted) {
                                               Navigator.pop(context);
                                             }

                                             final req = allRequests.firstWhere(
                                               (r) {
                                                 final reqId = r['id']?.toString();
                                                 final reqIsAppeal = r['is_appeal'] == true;
                                                 final targetId = relatedId.toString();

                                                 if (isAppeal && reqIsAppeal) {
                                                   return reqId == targetId;
                                                 }
                                                 if (isRequest && !reqIsAppeal) {
                                                   return reqId == targetId;
                                                 }
                                                 return reqId == targetId;
                                               },
                                               orElse: () => null,
                                             );

                                             if (req != null && context.mounted) {
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(
                                                   builder: (context) => MyRequestDetailsScreen(request: req),
                                                 ),
                                               );
                                             } else {
                                               if (context.mounted) {
                                                 ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(AppLocalizations.of(context)!.relatedRequestNotFound)),
                                                  );
                                               }
                                             }
                                           } catch (e) {
                                             // Dismiss loading dialog if open
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingRequestDetails)),
                                                );
                                             }
                                           }
                                         }
                                       }
                                     },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  )
                                      .animate(delay: (index * 40).ms)
                                      .fadeIn(duration: 150.ms)
                                      .slideX(begin: 0.1, end: 0, duration: 150.ms);
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
