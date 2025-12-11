import 'package:flutter/foundation.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';
import 'package:psits_nexus_mobile/models/payment_model.dart';

class PaymentProvider with ChangeNotifier {
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PaymentModel> get paidPayments => _payments
      .where((payment) => payment.isPaid)
      .toList()
      .reversed
      .toList(); // Most recent first

  List<PaymentModel> get pendingPayments => _payments
      .where((payment) => payment.isPending)
      .toList()
      .reversed
      .toList(); // Most recent first

  double get totalPaid => _payments
      .where((payment) => payment.isPaid)
      .fold(0.0, (sum, payment) => sum + payment.amountPaid);

  Future<void> loadPayments(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.getMemberPayments(token);

    _isLoading = false;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final paymentsList = data['payments'] as List? ?? [];
      _payments = paymentsList
          .map((item) => PaymentModel.fromJson(item))
          .toList();
      _error = null;
    } else {
      _error = result['message'];
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _payments = [];
    notifyListeners();
  }
}