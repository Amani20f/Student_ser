import 'package:flutter/material.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'reference_screen.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/modern_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? _selectedMajor;
  final List<String> _majors = [
    'Medicine',
    'Engineering',
    'Computer Science',
    'Business',
  ];

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
      floatingLabelStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      filled: true,
      fillColor: isDark
          ? Colors.grey.shade900.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newStudentRegistration),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                [
                      ModernTextField(
                        label: AppLocalizations.of(context)!.fullName,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        keyboardType: TextInputType.phone,
                        label: AppLocalizations.of(context)!.phoneNumber,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        keyboardType: TextInputType.emailAddress,
                        label: AppLocalizations.of(context)!.email,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        keyboardType: TextInputType.number,
                        label: AppLocalizations.of(context)!.highSchoolGpa,
                        prefixIcon: Icons.grade_outlined,
                        suffixText: '%',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedMajor,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        dropdownColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.white,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          context,
                          AppLocalizations.of(context)!.selectMajor,
                          Icons.school_outlined,
                        ),
                        items: _majors.map((String major) {
                          return DropdownMenuItem<String>(
                            value: major,
                            child: Text(major),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedMajor = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Upload Documents Button
                      OutlinedButton.icon(
                        onPressed: () {
                          // Visual only
                        },
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          AppLocalizations.of(context)!.uploadDocuments,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Upload Photos Button
                      OutlinedButton.icon(
                        onPressed: () {
                          // Visual only
                        },
                        icon: const Icon(Icons.add_photo_alternate_rounded),
                        label: Text(
                          AppLocalizations.of(context)!.uploadPhotos,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const ReferenceScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          shadowColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.submitRegistration,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ]
                    .animate(interval: 80.ms)
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutQuart,
                    ),
          ),
        ),
      ),
    );
  }
}
