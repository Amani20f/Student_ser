import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/request_type_model.dart';

final pricingProvider = FutureProvider.autoDispose<List<RequestTypeModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(ApiConstants.adminRequestTypes);
  final List data = response['data'] ?? [];
  return data.map((e) => RequestTypeModel.fromJson(e)).toList();
});

class PricingNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiClient apiClient;
  final Ref ref;

  PricingNotifier(this.apiClient, this.ref) : super(const AsyncData(null));

  Future<void> updateService(int id, {
    required String name,
    String? description,
    required double price,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    try {
      await apiClient.put(ApiConstants.adminRequestTypeById(id), body: {
        'name': name,
        'description': description,
        'price': price,
        'is_active': isActive,
      });
      ref.invalidate(pricingProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final pricingNotifierProvider = StateNotifierProvider<PricingNotifier, AsyncValue<void>>((ref) {
  return PricingNotifier(ref.watch(apiClientProvider), ref);
});
