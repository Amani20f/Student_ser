import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:university_app/core/network/api_client.dart';
import 'modern_text_field.dart';
import 'package:university_app/l10n/app_localizations.dart';

class ApplicationStatusDialog extends StatefulWidget {
  final VoidCallback onCancel;

  const ApplicationStatusDialog({
    super.key,
    required this.onCancel,
  });

  @override
  State<ApplicationStatusDialog> createState() => _ApplicationStatusDialogState();
}

class _ApplicationStatusDialogState extends State<ApplicationStatusDialog> {
  final _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final apiClient = ApiClient(prefs);
      final id = _idController.text.trim();
      
      final response = await apiClient.get('/apply/status/$id');
      
      if (mounted) {
        setState(() {
          _result = response['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.1,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .shimmer(duration: 1400.ms, delay: 700.ms),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      l10n.verifyReferenceRequest, // Using existing localization key for "Check Application Status"
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (_result == null) ...[
                Form(
                  key: _formKey,
                  child: ModernTextField(
                    controller: _idController,
                    label: 'رقم الهوية / الإقامة / الجواز',
                    prefixIcon: Icons.badge_outlined,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),
                
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                ],

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Text(l10n.verify),
                    ).animate().scale(
                      delay: 350.ms,
                      duration: 200.ms,
                      curve: Curves.easeInOut,
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: widget.onCancel,
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ] else ...[
                // Result Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_result!['application_status']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(_result!['application_status']).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getStatusIcon(_result!['application_status']),
                        color: _getStatusColor(_result!['application_status']),
                        size: 48,
                      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      Text(
                        _result!['status_label'] ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(_result!['application_status']),
                        ),
                      ),
                      const Divider(height: 24),
                      _buildResultRow('اسم المتقدم:', _result!['applicant_name']),
                      _buildResultRow('التخصص:', _result!['program_name']),
                      
                      if (_result!['application_status'] == 'completed' && _result!['student_number'] != null)
                        _buildResultRow('الرقم الجامعي:', _result!['student_number']),
                      
                      if ((_result!['application_status'] == 'pending' || _result!['application_status'] == 'submitted') && _result!['submitted_at'] != null)
                        _buildResultRow('تاريخ التقديم:', _result!['submitted_at']),

                      if (_result!['application_status'] == 'rejected' && _result!['rejection_reason'] != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('سبب الرفض:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                              const SizedBox(height: 4),
                              Text(_result!['rejection_reason'], style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
                
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إغلاق'),
                ),
              ],
            ],
          ),
        ),
      )
      .animate()
      .scale(
        duration: 300.ms,
        curve: Curves.easeOutBack,
        begin: const Offset(0.8, 0.8),
      )
      .fadeIn(duration: 200.ms),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == 'completed') return Colors.green;
    if (status == 'rejected') return Colors.red;
    return Colors.orange;
  }

  IconData _getStatusIcon(String? status) {
    if (status == 'completed') return Icons.check_circle_rounded;
    if (status == 'rejected') return Icons.cancel_rounded;
    return Icons.hourglass_empty_rounded;
  }

  Widget _buildResultRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
