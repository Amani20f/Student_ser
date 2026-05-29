import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/log_model.dart';
import '../data/log_repository.dart';

final logRepositoryProvider = Provider<LogRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LogRepository(apiClient);
});

final logsProvider = FutureProvider<List<LogModel>>((ref) async {
  final repository = ref.watch(logRepositoryProvider);
  return repository.getLogs();
});
