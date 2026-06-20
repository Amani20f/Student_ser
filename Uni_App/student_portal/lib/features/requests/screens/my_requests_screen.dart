import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:university_app/l10n/app_localizations.dart';
import '../data/requests_repository.dart';
import 'my_request_details_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final repo = context.read<RequestsRepository>();
      final data = await repo.getMyRequests();
      if (mounted) {
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('ApiException:', '').replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

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

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                l10n.failedToLoadRequests,
                style: GoogleFonts.almarai(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.errorLoadingRequests,
                textAlign: TextAlign.center,
                style: GoogleFonts.almarai(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchRequests,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              )
            ],
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  l10n.noPreviousRequests,
                  style: GoogleFonts.almarai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noRequestsSubmitted,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final req = _requests[index];
          final type = req['request_type'] ?? {};
          final typeName = type['name'] ?? l10n.serviceRequest;
          final refNumber = req['ref_number'] ?? 'REF-${req['id']}';
          final status = req['status'] ?? 'pending';
          final paymentStatus = req['payment_status'] ?? 'unpaid';
          final dateStr = req['submitted_at'] ?? '';
          
          DateTime? date;
          if (dateStr.isNotEmpty) {
            date = DateTime.tryParse(dateStr);
          }
          final formattedDate = date != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(date)
              : dateStr;

          final statusColor = _getStatusColor(status);
          final paymentColor = _getPaymentStatusColor(paymentStatus);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                // Navigate to details screen
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyRequestDetailsScreen(request: req),
                  ),
                );
                // Refresh list on return in case payment was made
                _fetchRequests();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            typeName,
                            style: GoogleFonts.almarai(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          refNumber,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Request Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusTranslation(status, l10n),
                                style: GoogleFonts.almarai(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Payment Status Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: paymentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: paymentColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            _getPaymentStatusTranslation(paymentStatus, l10n),
                            style: GoogleFonts.almarai(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: paymentColor,
                            ),
                          ),
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
