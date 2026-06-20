import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/appeal_model.dart';
import '../data/appeal_repository.dart';

final appealRepositoryProvider = Provider<AppealRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppealRepository(apiClient);
});

/// Holds the current status filter for appeals.
final appealStatusFilterProvider = StateProvider<dynamic>((ref) => 'verified');

/// Holds the current program filter for appeals.
final appealProgramFilterProvider = StateProvider<dynamic>((ref) => '__all__');

/// Fetches all appeals with optional status and program filtering.
final underReviewAppealsProvider = FutureProvider<List<AppealModel>>((ref) async {
  final repository = ref.watch(appealRepositoryProvider);
  final status = ref.watch(appealStatusFilterProvider);
  final programId = ref.watch(appealProgramFilterProvider);
  return repository.getAppeals(
    status: (status == '___all___' || status == '__all__' || status == null) ? null : status,
    programId: (programId == '___all___' || programId == '__all__' || programId == null) ? null : int.tryParse(programId.toString()),
  );
});

/// Fetches specific appeal details by ID.
final appealDetailsProvider =
    FutureProvider.family<AppealModel, int>((ref, id) async {
  final repository = ref.watch(appealRepositoryProvider);
  return repository.getAppealDetails(id);
});
