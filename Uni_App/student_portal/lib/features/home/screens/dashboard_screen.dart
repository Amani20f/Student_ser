import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_app/l10n/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

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
        final schedules = (scheduleResponse['data'] as List<dynamic>?) ?? [];
        if (schedules.isNotEmpty) {
          // Sort by id descending just in case to get the latest
          schedules.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
          setState(() {
            _latestSchedule = schedules.first;
          });
        }
      }
    } catch (e) {
      // Handle error implicitly
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

                      // Announcements Carousel
                      Text(
                        AppLocalizations.of(context)!.announcements,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAnnouncementCarousel(context),
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
    final studentIdNum = student['student_number'] ?? '';
    final studentIdLabel = studentIdNum.isNotEmpty
        ? 'الرقم الجامعي: $studentIdNum'
        : AppLocalizations.of(context)!.studentId;
    final major = program['name'] ?? AppLocalizations.of(context)!.majorValue;
    final gpa = (student['cumulative_gpa'] ?? '0.0').toString();
    final level = (student['current_level'] ?? '1').toString();

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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.grey,
                          ),
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

  Widget _buildAnnouncementCarousel(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                  AppTheme.primaryColor.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'University Announcement ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
            AppLocalizations.of(context)!.noStudySchedules ?? 'No study schedules available for your current level and program.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final schedule = _latestSchedule!;
    final notes = schedule['notes'] as String?;
    final imageUrl = schedule['schedule_image_url'] as String?;
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
                            Text(
                              '${schedule['term']} ${schedule['academic_year']}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.level} ${schedule['level']}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (notes != null && notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.notes ?? 'Notes'}: $notes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                  if (imageUrl != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(imageUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: Text(l10n.viewSchedule ?? 'View Schedule'),
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
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                      AppLocalizations.of(context)!.notificationsTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Action for 'Clear All'
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.clearAllNotifications,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: _isLoadingNotifications
                    ? const Center(child: CircularProgressIndicator())
                    : _notifications.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)!.noNotificationsMsg,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _notifications.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _notifications[index];
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
                                    color: color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: color,
                                  ),
                                ),
                                title: Text(
                                  item["title"] ?? '',
                                  style: TextStyle(
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    item["message"] ?? '',
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
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  if (!isRead) {
                                    _markAsRead(item['id']);
                                  }
                                  Navigator.pop(context); // Close dialog on tap
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
  }
}
