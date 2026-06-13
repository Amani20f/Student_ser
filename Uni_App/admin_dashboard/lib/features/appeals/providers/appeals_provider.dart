import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/appeal_model.dart';
import '../data/appeal_repository.dart';

final appealRepositoryProvider = Provider<AppealRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppealRepository(apiClient);
});

/// Holds the current status filter for appeals.
final appealStatusFilterProvider = StateProvider<String?>((ref) => null);

/// Fetches all appeals with optional status filtering.
final underReviewAppealsProvider = FutureProvider<List<AppealModel>>((ref) async {
  final repository = ref.watch(appealRepositoryProvider);
  final status = ref.watch(appealStatusFilterProvider);
  return repository.getAppeals(status: status == '___all___' ? null : status);
});

/// Fetches specific appeal details by ID.
final appealDetailsProvider =
    FutureProvider.family<AppealModel, int>((ref, id) async {
  final repository = ref.watch(appealRepositoryProvider);
  return repository.getAppealDetails(id);
});
