import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/unified_request_model.dart';
import '../data/unified_request_repository.dart';

final unifiedRequestRepositoryProvider = Provider<UnifiedRequestRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UnifiedRequestRepository(apiClient);
});

final unifiedFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'search': '',
  'status': '',
  'request_type': 'all',
});

final unifiedRequestsListProvider = FutureProvider<List<UnifiedRequestModel>>((ref) async {
  final repository = ref.watch(unifiedRequestRepositoryProvider);
  final filters = ref.watch(unifiedFiltersProvider);
  
  // Fetch all requests without passing status query parameter to the backend, so we can map and filter client-side
  final allList = await repository.getUnifiedRequests(
    search: filters['search'] as String?,
  );

  final selectedType = filters['request_type'] as String?;
  final selectedStatus = filters['status'] as String?;

  // 1. Map non-academic statuses to their academic equivalents
  final mappedList = allList.map((req) {
    final statusLower = req.status.toLowerCase();
    String newStatus = req.status;
    if (statusLower == 'verified' || statusLower == 'paid' || statusLower == 'ratified') {
      newStatus = 'pending';
    } else if (statusLower == 'completed') {
      newStatus = 'approved';
    }
    return UnifiedRequestModel(
      id: req.id,
      studentName: req.studentName,
      submittedDate: req.submittedDate,
      status: newStatus,
      requestType: req.requestType,
      requestTypeEn: req.requestTypeEn,
      originalType: req.originalType,
      details: req.details,
    );
  }).toList();

  // 2. Filter by status on client side (using mapped status)
  var filteredList = mappedList;
  if (selectedStatus != null && selectedStatus.isNotEmpty) {
    filteredList = filteredList.where((req) => req.status.toLowerCase() == selectedStatus.toLowerCase()).toList();
  }

  // 3. Filter by request type
  if (selectedType == null || selectedType == 'all') {
    return filteredList;
  }

  return filteredList.where((req) {
    if (selectedType == 'student_application') {
      return req.originalType == 'student_application';
    } else if (selectedType == 'appeal') {
      return req.originalType == 'appeal';
    } else if (selectedType == 'payment') {
      return req.originalType == 'payment';
    } else if (selectedType == 'absence_excuse') {
      return req.originalType == 'absence_request';
    } else if (selectedType == 'suspension_of_enrollment') {
      return req.originalType == 'suspension_request';
    } else if (selectedType == 're_enrollment') {
      return req.originalType == 're_enrollment_request';
    } else {
      return req.originalType == 'request';
    }
  }).toList();
});
