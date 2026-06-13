import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/payment_model.dart';
import '../data/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRepository(apiClient);
});

final paymentFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final allPaymentsProvider = FutureProvider<List<PaymentModel>>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  final filters = ref.watch(paymentFiltersProvider);
  
  final hasActiveFilter = filters.values.any((value) => value != null && value.toString().isNotEmpty);
  if (!hasActiveFilter) {
    return <PaymentModel>[];
  }
  
  final cleanFilters = Map<String, dynamic>.from(filters);
  cleanFilters.removeWhere((key, value) => value == '___all___' || value == -1);
  
  return repository.getAllPayments(filters: cleanFilters);
});
