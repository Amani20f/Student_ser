import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'payment_model.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  Future<List<PaymentModel>> getAllPayments({Map<String, dynamic>? filters}) async {
    final queryParams = <String, String>{};
    filters?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        if (key == 'created_at_from') {
          queryParams['from_date'] = value.toString();
        } else if (key == 'created_at_to') {
          queryParams['to_date'] = value.toString();
        } else {
          queryParams[key] = value.toString();
        }
      }
    });

    final response = await _apiClient.get(
      ApiConstants.staffPayments,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> verifyPayment(int id) async {
    await _apiClient.put(ApiConstants.staffPaymentVerify(id));
  }

  Future<void> rejectPayment(int id, String reason) async {
    await _apiClient.put(
      ApiConstants.staffPaymentReject(id),
      body: {'reason': reason}, // Backend expects 'reason' field
    );
  }
}
