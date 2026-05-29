import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/user_management_repository.dart';
import '../data/managed_user_model.dart';

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return UserManagementRepository(client);
});

final userFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final usersProvider = FutureProvider<List<ManagedUserModel>>((ref) async {
  final repo = ref.watch(userManagementRepositoryProvider);
  final filters = ref.watch(userFiltersProvider);
  return repo.getUsers(filters: filters);
});
