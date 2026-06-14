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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                [
                      // Personal Info Section
                      _buildSectionHeader(
                        context,
                        AppLocalizations.of(context)!.personalInfo,
                      ),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          String fullName = 'N/A';
                          String nationalId = 'N/A';
                          String email = 'N/A';
                          if (state is Authenticated) {
                            fullName = state.user['name'] ?? 'N/A';
                            nationalId = state.user['national_id']?.toString() ?? 'N/A';
                            email = state.user['email'] ?? 'N/A';
                          }
                          return _buildSettingsContainer(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.person_rounded,
                                title: AppLocalizations.of(context)!.fullName,
                                value: fullName,
                              ),
                              _buildDivider(context),
                              _buildSettingsTile(
                                context,
                                icon: Icons.badge_rounded,
                                title: AppLocalizations.of(context)!.nationalIdLabel,
                                value: nationalId,
                              ),
                              _buildDivider(context),
                              _buildSettingsTile(
                                context,
                                icon: Icons.email_rounded,
                                title: AppLocalizations.of(context)!.email,
                                value: email,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Academic Info Section
                      _buildSectionHeader(
                        context,
                        AppLocalizations.of(context)!.academicInfo,
                      ),
                      _buildSettingsContainer(
                        context,
                        children: [
                          _buildSettingsTile(
                            context,
                            icon: Icons.school_rounded,
                            title: AppLocalizations.of(context)!.majorLabel,
                            value: AppLocalizations.of(context)!.majorValue,
                          ),
                          _buildDivider(context),
                          _buildSettingsTile(
                            context,
                            icon: Icons.star_rate_rounded, // or grade_rounded
                            title: AppLocalizations.of(context)!.gpaLabel,
                            value: '3.8',
                            valueColor: const Color(
                              0xFFFBC02D,
                            ), // Gold color for GPA
                          ),
                          _buildDivider(context),
                          _buildSettingsTile(
                            context,
                            icon: Icons.verified_user_rounded,
                            title: AppLocalizations.of(context)!.statusLabel,
                            value: AppLocalizations.of(context)!.statusActive,
                            valueColor: Colors.green,
                          ),
                        ],
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
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    valueColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
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
  bool _isObscured = true;
  bool _isEditing = false;
  bool _isNewObscured = true;
  bool _isConfirmObscured = true;

  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _isNewObscured = true;
        _isConfirmObscured = true;
      }
    });
  }

  void _savePassword() {
    if (_formKey.currentState!.validate()) {
      // Simulate API call and success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.passwordChangedSuccess,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isEditing = false;
        _globalIsLocked = true;
        _globalDaysRemaining = 90;
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _isNewObscured = true;
        _isConfirmObscured = true;
      });
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
                  _isObscured ? '••••••••' : 'MySecurePassword123',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                    letterSpacing: _isObscured ? 2 : 0,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
              if (!_globalIsLocked && !_isEditing)
                IconButton(
                  tooltip: null, // Removed per user request
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
                              return AppLocalizations.of(context)!.requiredField;
                            }
                            if (value.length < 8) {
                              return AppLocalizations.of(context)!.passwordMinLength;
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
                              return AppLocalizations.of(context)!.requiredField;
                            }
                            if (value != _newPasswordController.text) {
                              return AppLocalizations.of(context)!.passwordsDoNotMatch;
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
                              onPressed: _savePassword,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(l10n.save),
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
