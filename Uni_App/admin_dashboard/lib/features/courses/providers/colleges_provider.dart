import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/college_model.dart';

final collegesProvider = FutureProvider.autoDispose<List<CollegeModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  // /colleges is a public endpoint
  final response = await apiClient.get('/colleges');
  final List data = response['data'] ?? [];
  return data.map((e) => CollegeModel.fromJson(e)).toList();
});
