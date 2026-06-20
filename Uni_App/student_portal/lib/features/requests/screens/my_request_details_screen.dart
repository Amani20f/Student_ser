import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:university_app/l10n/app_localizations.dart';
import 'forms/payment_form.dart';

class MyRequestDetailsScreen extends StatelessWidget {
  final dynamic request;

  const MyRequestDetailsScreen({super.key, required this.request});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        return Colors.green;
      case 'rejected':
      case 'suspended':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'ratified':
      case 'under_review':
        return Colors.blue;
      case 'paid':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getStatusTranslation(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'approved':
        return l10n.statusApproved;
      case 'rejected':
        return l10n.statusRejected;
      case 'pending':
        return l10n.statusPending;
      case 'ratified':
        return l10n.statusRatified;
      case 'under_review':
        return l10n.statusUnderReview;
      case 'paid':
        return l10n.statusPaid;
      default:
        return status;
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return Colors.teal;
      case 'pending_verification':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'unpaid':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusTranslation(String paymentStatus, AppLocalizations l10n) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return l10n.paymentPaid;
      case 'pending_verification':
        return l10n.paymentPendingVerification;
      case 'rejected':
        return l10n.paymentRejected;
      case 'unpaid':
        return l10n.paymentUnpaid;
      default:
        return paymentStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final type = request['request_type'] ?? {};
    final typeName = type['name'] ?? l10n.serviceRequest;
    final refNumber = request['ref_number'] ?? 'REF-${request['id']}';
    final status = request['status'] ?? 'pending';
    final paymentStatus = request['payment_status'] ?? 'unpaid';
    final description = request['description'] ?? '';
    final staffResponse = request['staff_response'];
    final rejectionReason = request['rejection_reason'];
    final listAttachments = (request['attachments'] as List<dynamic>?) ?? [];
    
    final dateStr = request['submitted_at'] ?? '';
    DateTime? date;
    if (dateStr.isNotEmpty) {
      date = DateTime.tryParse(dateStr);
    }
    final formattedDate = date != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(date)
        : dateStr;

    final updatedDateStr = request['updated_at'] ?? '';
    DateTime? updatedDate;
    if (updatedDateStr.isNotEmpty) {
      updatedDate = DateTime.tryParse(updatedDateStr);
    }
    final formattedUpdatedDate = updatedDate != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(updatedDate)
        : updatedDateStr;

    final fee = type['fee'] != null ? double.tryParse(type['fee'].toString()) ?? 0.0 : 0.0;
    final isUnpaid = paymentStatus.toLowerCase() == 'unpaid';
    final requiresPayment = fee > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requestDetailsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Reference Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.referenceNumberLabel,
                          style: GoogleFonts.almarai(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          refNumber,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.requestTypeLabel,
                          style: GoogleFonts.almarai(fontSize: 14, color: Colors.grey[600]),
                        ),
                        Text(
                          typeName,
                          style: GoogleFonts.almarai(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.requestStatusLabel,
                              style: GoogleFonts.almarai(fontSize: 12, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                              ),
                              child: Text(
                                _getStatusTranslation(status, l10n),
                                style: GoogleFonts.almarai(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.paymentStatusLabel,
                              style: GoogleFonts.almarai(fontSize: 12, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getPaymentStatusColor(paymentStatus).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getPaymentStatusColor(paymentStatus).withOpacity(0.3)),
                              ),
                              child: Text(
                                _getPaymentStatusTranslation(paymentStatus, l10n),
                                style: GoogleFonts.almarai(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _getPaymentStatusColor(paymentStatus),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Time Metadata Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          l10n.submissionDateLabel,
                          style: GoogleFonts.almarai(fontSize: 13, color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Text(
                          formattedDate,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.update_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          l10n.lastUpdateLabel,
                          style: GoogleFonts.almarai(fontSize: 13, color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Text(
                          formattedUpdatedDate,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description Section
            if (description.isNotEmpty) ...[
              Text(
                l10n.requestDescriptionTitle,
                style: GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      description,
                      style: GoogleFonts.almarai(fontSize: 14, height: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Rejection Reason Alert Card
            if (status.toLowerCase() == 'rejected' && rejectionReason != null && rejectionReason.toString().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_rounded, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          l10n.rejectionReasonLabel,
                          style: GoogleFonts.almarai(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rejectionReason.toString(),
                      style: GoogleFonts.almarai(fontSize: 14, color: Colors.red[900], height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Staff Response Section
            if (status.toLowerCase() != 'rejected' && staffResponse != null && staffResponse.toString().isNotEmpty) ...[
              Text(
                l10n.staffResponseLabel,
                style: GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      staffResponse.toString(),
                      style: GoogleFonts.almarai(fontSize: 14, height: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Attachments Section
            if (listAttachments.isNotEmpty) ...[
              Text(
                l10n.attachedFilesCount(listAttachments.length),
                style: GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: listAttachments.map<Widget>((attachment) {
                  final attachmentStr = attachment.toString();
                  final fileName = attachmentStr.split('/').last;
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file_rounded, color: Colors.teal),
                      title: Text(
                        fileName,
                        style: GoogleFonts.outfit(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                      onTap: () async {
                        try {
                          final uri = Uri.parse(attachmentStr);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.couldNotOpenAttachment(attachmentStr))),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.errorOpeningFileMsg(e.toString()))),
                            );
                          }
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Payment Action Button
            if (requiresPayment && isUnpaid) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Map request type slug to initialServiceType
                    String initialServiceType = '';
                    final slug = type['slug']?.toString() ?? '';
                    if (slug == 'grade_appeal' || request['is_appeal'] == true) {
                      initialServiceType = 'تظلم — 10 دولار';
                    } else if (slug == 'suspension_of_enrollment' || slug == 'tagyl-dras') {
                      initialServiceType = 'إيقاف قيد — 10 دولار';
                    } else if (slug == 're_enrollment') {
                      initialServiceType = 'إعادة قيد — 10 دولار';
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentFormScreen(
                          initialRefNumber: refNumber,
                          initialServiceType: initialServiceType.isNotEmpty ? initialServiceType : null,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment_rounded),
                  label: Text(l10n.payFeesNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}
