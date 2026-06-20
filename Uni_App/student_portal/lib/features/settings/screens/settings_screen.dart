import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/bloc/language_cubit.dart';
import '../../../core/bloc/theme_cubit.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/support_dialog.dart';
import 'package:university_app/l10n/app_localizations.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/cubit/auth_cubit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../../core/utils/normalization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _isFetchingProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFreshProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchFreshProfile();
  }

  Future<void> _fetchFreshProfile() async {
    if (_isFetchingProfile) return;
    _isFetchingProfile = true;
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get(ApiConstants.updateProfile);
      final data = response['data'];
      if (mounted && data != null) {
        context.read<AuthCubit>().updateUser(data);
        debugPrint('[SettingsScreen] Profile refreshed — student status: ${data['student']?['status']}');
      }
    } catch (e) {
      debugPrint('Error fetching fresh profile: $e');
    } finally {
      _isFetchingProfile = false;
    }
  }

  Future<void> _updateProfilePhoto(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        final file = File(image.path);
        final apiClient = context.read<ApiClient>();

        final responseData = await apiClient.postMultipart(
          ApiConstants.updateProfile,
          fields: {
            '_method': 'PUT',
            'phone':
                (context.read<AuthCubit>().state as Authenticated)
                    .user['student']['phone'] ??
                '',
          },
          files: [
            await http.MultipartFile.fromPath('profile_photo', file.path),
          ],
        );

        final data = responseData['data'];
        if (mounted) {
          context.read<AuthCubit>().updateUser(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.photoUpdatedSuccess)),
          );
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorPhotoUpdate)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditPhoneDialog(
    BuildContext context,
    String currentPhone,
  ) async {
    final controller = TextEditingController(text: currentPhone);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editPhoneNumber),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.phoneNumber,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              final normalized = normalizePhone(value);
              if (normalized != value) {
                controller.value = TextEditingValue(
                  text: normalized,
                  selection: TextSelection.collapsed(offset: normalized.length),
                );
              }
            },
            validator: (val) {
              if (val == null || val.trim().isEmpty)
                return 'الرجاء إدخال رقم الهاتف';
              final normalized = normalizePhone(val);
              if (!isValidPhoneNumber(normalized)) {
                return 'رقم الهاتف غير صحيح (8 إلى 15 رقماً)';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                _updatePhone(context, controller.text.trim());
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhone(BuildContext context, String newPhone) async {
    final normalizedPhone = normalizePhone(newPhone);
    setState(() => _isLoading = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.put(
        ApiConstants.updateProfile,
        body: {'phone': normalizedPhone},
      );
      final data = response['data'];
      if (mounted) {
        context.read<AuthCubit>().updateUser(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.phoneUpdatedSuccess)),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorPhoneUpdate)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: RefreshIndicator(
          onRefresh: _fetchFreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                [
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          if (state is! Authenticated)
                            return const SizedBox.shrink();

                          final user = state.user;
                          final student = user['student'] ?? {};

                          final fullName = user['name'];
                          final email = user['email'];
                          final phone = student['phone'];
                          final nationalId = student['national_id']?.toString();
                          final dob = student['date_of_birth'];
                          final gender = student['gender'];
                          final nationality = student['nationality'];
                          final profilePhoto = student['profile_photo_path'];

                          final studentNumber = student['student_number']
                              ?.toString();
                          final majorName = student['program']?['name'];
                          final rawGpa = student['cumulative_gpa'];
                          final isAr = Localizations.localeOf(context).languageCode == 'ar';
                          final gpa = rawGpa == null
                              ? (isAr ? 'غير متوفر' : 'N/A')
                              : double.parse(rawGpa.toString()).toStringAsFixed(2);
                          final creditHours = student['completed_credit_hours']
                              ?.toString();
                          final remainingHours = student['remaining_credit_hours']
                              ?.toString();
                          final status = student['status'];

                          Widget? buildTile(
                            IconData icon,
                            String title,
                            String? value, {
                            Color? valueColor,
                            Widget? trailing,
                          }) {
                            if (value == null || value.trim().isEmpty)
                              return null;
                            return _buildSettingsTile(
                              context,
                              icon: icon,
                              title: title,
                              value: value,
                              valueColor: valueColor,
                              trailing: trailing,
                            );
                          }

                          List<Widget> joinTiles(List<Widget?> tiles) {
                            final validTiles = tiles
                                .whereType<Widget>()
                                .toList();
                            if (validTiles.isEmpty) return [];
                            final result = <Widget>[];
                            for (int i = 0; i < validTiles.length; i++) {
                              result.add(validTiles[i]);
                              if (i < validTiles.length - 1) {
                                result.add(_buildDivider(context));
                              }
                            }
                            return result;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Avatar
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => _updateProfilePhoto(context),
                                    child: Center(
                                      child: CircleAvatar(
                                        radius: 45,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundImage:
                                              profilePhoto != null &&
                                                  profilePhoto.isNotEmpty
                                              ? NetworkImage(profilePhoto)
                                              : null,
                                          child:
                                              profilePhoto == null ||
                                                  profilePhoto.isEmpty
                                              ? Text(
                                                  (fullName != null &&
                                                          fullName.isNotEmpty)
                                                      ? fullName[0]
                                                      : 'U',
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isLoading)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => _updateProfilePhoto(context),
                                  icon: const Icon(
                                    Icons.photo_library_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.pickFromGallery,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Personal Info Section
                              _buildSectionHeader(
                                context,
                                AppLocalizations.of(context)!.personalInfo,
                              ),
                              _buildSettingsContainer(
                                context,
                                children: joinTiles([
                                  buildTile(
                                    Icons.person_rounded,
                                    AppLocalizations.of(context)!.fullName,
                                    fullName,
                                  ),
                                  buildTile(
                                    Icons.email_rounded,
                                    AppLocalizations.of(context)!.email,
                                    email,
                                  ),
                                  buildTile(
                                    Icons.phone_rounded,
                                    AppLocalizations.of(context)!.phoneNumber,
                                    phone,
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _showEditPhoneDialog(
                                        context,
                                        phone ?? '',
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                  buildTile(
                                    Icons.badge_rounded,
                                    AppLocalizations.of(
                                      context,
                                    )!.nationalIdLabel,
                                    nationalId,
                                  ),
                                  buildTile(
                                    Icons.calendar_today_rounded,
                                    AppLocalizations.of(context)!.dateOfBirthLabel,
                                    dob,
                                  ),
                                  buildTile(
                                    Icons.person_outline_rounded,
                                    AppLocalizations.of(context)!.genderLabel,
                                    gender == 'male'
                                        ? AppLocalizations.of(context)!.maleLabel
                                        : (gender == 'female'
                                              ? AppLocalizations.of(context)!.femaleLabel
                                              : gender),
                                  ),
                                  buildTile(
                                    Icons.flag_rounded,
                                    AppLocalizations.of(context)!.nationalityLabel,
                                    nationality,
                                  ),
                                ]),
                              ),

                              const SizedBox(height: 24),

                              // Academic Info Section
                              _buildSectionHeader(
                                context,
                                AppLocalizations.of(context)!.academicInfo,
                              ),
                              _buildSettingsContainer(
                                context,
                                children: joinTiles([
                                  buildTile(
                                    Icons.numbers_rounded,
                                    AppLocalizations.of(context)!.studentNumberLabel,
                                    studentNumber,
                                  ),
                                  buildTile(
                                    Icons.school_rounded,
                                    AppLocalizations.of(context)!.majorLabel,
                                    majorName,
                                  ),
                                  buildTile(
                                    Icons.star_rate_rounded,
                                    AppLocalizations.of(context)!.gpaLabel,
                                    gpa,
                                    valueColor: const Color(0xFFFBC02D),
                                  ),
                                  buildTile(
                                    Icons.access_time_rounded,
                                    AppLocalizations.of(context)!.completedHours,
                                    creditHours,
                                  ),
                                  buildTile(
                                    Icons.hourglass_empty_rounded,
                                    AppLocalizations.of(context)!.remainingHours,
                                    remainingHours,
                                  ),
                                  buildTile(
                                    Icons.verified_user_rounded,
                                    AppLocalizations.of(context)!.statusLabel,
                                    status?.toString().toLowerCase() == 'active'
                                        ? AppLocalizations.of(context)!.statusActive
                                        : (status?.toString().toLowerCase() == 'suspended'
                                              ? AppLocalizations.of(context)!.statusSuspended
                                              : (status?.toString().toLowerCase() == 'graduated'
                                                    ? AppLocalizations.of(context)!.statusGraduated
                                                    : status)),
                                    valueColor: status?.toString().toLowerCase() == 'active'
                                        ? Colors.green
                                        : (status?.toString().toLowerCase() == 'suspended'
                                              ? Colors.red
                                              : Colors.blue),
                                  ),
                                ]),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      // Account Security Section
                      _buildSectionHeader(
                        context,
                        AppLocalizations.of(context)!.passwordLabel,
                      ),
                      _buildSettingsContainer(
                        context,
                        children: [const _PasswordView()],
                      ),

                      const SizedBox(height: 24),
                      // App Settings Section
                      _buildSectionHeader(
                        context,
                        AppLocalizations.of(context)!.appSettings,
                      ),
                      _buildSettingsContainer(
                        context,
                        children: [
                          // Dark Mode Toggle
                          BlocBuilder<ThemeCubit, ThemeMode>(
                            builder: (context, state) {
                              final isDarkMode =
                                  state == ThemeMode.dark ||
                                  (state == ThemeMode.system &&
                                      MediaQuery.of(
                                            context,
                                          ).platformBrightness ==
                                          Brightness.dark);
                              return _buildSwitchTile(
                                context,
                                icon: isDarkMode
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                title: isDarkMode
                                    ? AppLocalizations.of(context)!.darkMode
                                    : AppLocalizations.of(context)!.lightMode,
                                value: isDarkMode,
                                onChanged: (_) =>
                                    context.read<ThemeCubit>().toggleTheme(),
                              );
                            },
                          ),
                          _buildDivider(context),
                          // Language Selector
                          BlocBuilder<LanguageCubit, Locale>(
                            builder: (context, locale) {
                              return _buildLanguageTile(context, locale);
                            },
                          ),
                          _buildDivider(context),
                          // Contact University Button
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => const SupportDialog(),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.support_agent_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.contactUniversity,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]
                    .animate(interval: 20.ms)
                    .fadeIn(duration: 200.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.2, end: 0, duration: 200.ms) +
                [
                  const SizedBox(height: 12),
                  // Logout Button
                  const _AnimatedLogoutButton(),
                ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8, right: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? value,
    Color? valueColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          if (value != null)
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      valueColor ??
                      theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: iconColor,
            activeTrackColor: iconColor.withValues(alpha: 0.4),
            inactiveThumbColor: theme.primaryColor,
            inactiveTrackColor: theme.primaryColor.withValues(alpha: 0.4),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, Locale currentLocale) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.language_rounded, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.language,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Row(
            children: [
              _buildLanguageOption(
                context,
                'en',
                'English',
                currentLocale.languageCode == 'en',
              ),
              const SizedBox(width: 8),
              _buildLanguageOption(
                context,
                'ar',
                'العربية',
                currentLocale.languageCode == 'ar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String label,
    bool isSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? const Color(0xFF64FFDA)
        : Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          context.read<LanguageCubit>().setLanguage(Locale(code));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.grey.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black87 : Colors.white)
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60, // Align with text start details
      endIndent: 0,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
    );
  }
}

class _AnimatedLogoutButton extends StatelessWidget {
  const _AnimatedLogoutButton();

  @override
  Widget build(BuildContext context) {
    return Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.logout,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.2, end: 0)
        .shimmer(duration: 1050.ms, color: Colors.white.withValues(alpha: 0.2));
  }
}

bool _globalIsLocked = false;
int _globalDaysRemaining = 0;

class _PasswordView extends StatefulWidget {
  const _PasswordView();

  @override
  State<_PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends State<_PasswordView> {
  bool _isEditing = false;
  bool _isCurrentObscured = true;
  bool _isNewObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _isCurrentObscured = true;
        _isNewObscured = true;
        _isConfirmObscured = true;
      }
    });
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.put(
        '/change-password',
        body: {
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
          'new_password_confirmation': _confirmPasswordController.text,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تغيير كلمة المرور بنجاح',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isEditing = false;
        _globalIsLocked = true;
        _globalDaysRemaining = 90;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _isCurrentObscured = true;
        _isNewObscured = true;
        _isConfirmObscured = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('ApiException: ', ''),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.secondary;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_rounded, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '••••••••',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
              if (!_globalIsLocked && !_isEditing)
                IconButton(
                  tooltip: null,
                  icon: Icon(Icons.edit_rounded, color: iconColor),
                  onPressed: _toggleEditing,
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isEditing
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: _isCurrentObscured,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.currentPasswordLabel,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isCurrentObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              onPressed: () => setState(
                                () => _isCurrentObscured = !_isCurrentObscured,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return AppLocalizations.of(
                                context,
                              )!.requiredField;
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _isNewObscured,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: l10n.newPassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isNewObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isNewObscured = !_isNewObscured;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.requiredField;
                            }
                            if (value.length < 8) {
                              return AppLocalizations.of(
                                context,
                              )!.passwordMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _isConfirmObscured,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: l10n.confirmPassword,
                            prefixIcon: const Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmObscured = !_isConfirmObscured;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.requiredField;
                            }
                            if (value != _newPasswordController.text) {
                              return AppLocalizations.of(
                                context,
                              )!.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _toggleEditing,
                              child: Text(l10n.cancel),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _savePassword,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.save),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (_globalIsLocked) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_clock_rounded, size: 18, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.passwordLockedMsg,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.daysRemaining(_globalDaysRemaining),
                        style: TextStyle(
                          color: iconColor.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
