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
  
  final allList = await repository.getUnifiedRequests(
    search: filters['search'] as String?,
    status: filters['status'] as String?,
  );

  final selectedType = filters['request_type'] as String?;
  if (selectedType == null || selectedType == 'all') {
    return allList;
  }

  return allList.where((req) {
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
