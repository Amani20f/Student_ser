import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/admissions_repository.dart';
import '../data/application_model.dart';

final admissionsRepositoryProvider = Provider<AdmissionsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdmissionsRepository(client);
});

final admissionsFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final applicationsListProvider = FutureProvider<List<ApplicationModel>>((ref) async {
  final repo = ref.watch(admissionsRepositoryProvider);
  final filters = ref.watch(admissionsFiltersProvider);
  return await repo.getApplications(filters: filters);
});

final applicationDetailsProvider = FutureProvider.family<ApplicationModel, int>((ref, id) async {
  final repo = ref.watch(admissionsRepositoryProvider);
  return await repo.getApplicationDetails(id);
});
