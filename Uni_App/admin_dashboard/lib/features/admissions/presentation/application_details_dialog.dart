import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/admissions_provider.dart';
import '../data/application_model.dart';

class ApplicationDetailsDialog extends ConsumerStatefulWidget {
  final int applicationId;

  const ApplicationDetailsDialog({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicationDetailsDialog> createState() => _ApplicationDetailsDialogState();
}

class _ApplicationDetailsDialogState extends ConsumerState<ApplicationDetailsDialog> {
  final _rejectionController = TextEditingController();

  @override
  void dispose() {
    _rejectionController.dispose();
    super.dispose();
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open document.')));
      }
    }
  }

  void _approveApplication(ApplicationModel app) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to approve this application?', style: tt.bodyLarge),
            const SizedBox(height: 16),
            Text('Student Name: ${app.fullName}'),
            Text('Desired Program: ${app.desiredProgram}'),
            Text('College: ${app.college}'),
            const SizedBox(height: 16),
            Text(
              'A student account will be automatically created and an email with the new Student ID and password will be sent.',
              style: tt.bodySmall?.copyWith(color: cs.onSurface.withAlpha(150)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close confirm dialog
              try {
                final repo = ref.read(admissionsRepositoryProvider);
                final res = await repo.approveApplication(app.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Approved successfully')));
                Navigator.pop(context); // Close main dialog
                ref.invalidate(applicationsListProvider);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectApplication(ApplicationModel app) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال سبب الرفض. سيتم إرسال هذا السبب للطالب.'),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب سبب الرفض هنا...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              if (_rejectionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة سبب الرفض')));
                return;
              }
              Navigator.pop(dialogContext); // Close confirm dialog
              try {
                final repo = ref.read(admissionsRepositoryProvider);
                await repo.rejectApplication(app.id, _rejectionController.text.trim());
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application rejected successfully.')));
                Navigator.pop(context); // Close main dialog
                ref.invalidate(applicationsListProvider);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appAsync = ref.watch(applicationDetailsProvider(widget.applicationId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(32),
        child: appAsync.when(
          data: (app) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Application Details: ${app.applicationNumber}', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSectionHeader('Personal Information', tt, cs),
                      _buildInfoRow('Full Name', app.fullName),
                      _buildInfoRow('National ID', app.nationalIdNumber ?? 'N/A'),
                      _buildInfoRow('Date of Birth', app.dateOfBirth ?? 'N/A'),
                      _buildInfoRow('Gender', app.gender ?? 'N/A'),
                      _buildInfoRow('Nationality', app.nationality ?? 'N/A'),
                      const SizedBox(height: 16),
                      
                      _buildSectionHeader('Academic Information', tt, cs),
                      _buildInfoRow('Desired Program', app.desiredProgram ?? 'N/A'),
                      _buildInfoRow('Department', app.department ?? 'N/A'),
                      _buildInfoRow('College', app.college ?? 'N/A'),
                      const SizedBox(height: 16),

                      _buildSectionHeader('Contact Information', tt, cs),
                      _buildInfoRow('Phone', app.phoneNumber ?? 'N/A'),
                      _buildInfoRow('Email', app.emailAddress ?? 'N/A'),
                      _buildInfoRow('Address', app.address ?? 'N/A'),
                      const SizedBox(height: 16),

                      if (app.rejectionReason != null) ...[
                        _buildSectionHeader('Rejection Reason', tt, cs),
                        Text(app.rejectionReason!, style: TextStyle(color: Colors.red[700])),
                        const SizedBox(height: 16),
                      ],

                      _buildSectionHeader('Uploaded Documents', tt, cs),
                      if (app.identityDocumentUrl != null)
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: const Text('Identity Document'),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () => _launchUrl(app.identityDocumentUrl!),
                        ),
                      if (app.qualificationDocumentUrl != null)
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: const Text('Secondary Certificate / Qualification'),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () => _launchUrl(app.qualificationDocumentUrl!),
                        ),
                      if (app.personalPhotoUrl != null)
                        ListTile(
                          leading: const Icon(Icons.image),
                          title: const Text('Personal Photo'),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: () => _launchUrl(app.personalPhotoUrl!),
                        ),
                      if (app.identityDocumentUrl == null && app.qualificationDocumentUrl == null && app.personalPhotoUrl == null)
                        const Text('No documents uploaded.'),
                    ],
                  ),
                ),
                const Divider(),
                if (app.status == 'pending' || app.status == 'submitted')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _rejectApplication(app),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _approveApplication(app),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text('Approve & Create Account'),
                      ),
                    ],
                  )
                else
                  Center(
                    child: Text(
                      'Application is already ${app.status?.toUpperCase()}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error loading details: $e')),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextTheme tt, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
