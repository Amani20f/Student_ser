import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/request_model.dart';
import '../data/request_repository.dart';

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RequestRepository(apiClient);
});

final requestFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final allRequestsProvider = FutureProvider<List<RequestModel>>((ref) async {
  final repository = ref.watch(requestRepositoryProvider);
  final filters = ref.watch(requestFiltersProvider);
  
  final hasActiveFilter = filters.values.any((value) => value != null && value.toString().isNotEmpty);
  if (!hasActiveFilter) {
    return <RequestModel>[];
  }
  
  return repository.getRequests(filters: filters);
});
