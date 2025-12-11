import 'package:flutter/foundation.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';
import 'package:psits_nexus_mobile/models/requirement_model.dart';

class RequirementProvider with ChangeNotifier {
  List<RequirementModel> _requirements = [];
  bool _isLoading = false;
  String? _error;

  List<RequirementModel> get requirements => _requirements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<RequirementModel> get paidRequirements => _requirements
      .where((req) => req.isPaid)
      .toList()
      .reversed
      .toList(); // Most recent first

  List<RequirementModel> get unpaidRequirements => _requirements
      .where((req) => !req.isPaid)
      .toList()
      .reversed
      .toList(); // Most recent first

  List<RequirementModel> get overdueRequirements => _requirements
      .where((req) => req.isOverdue)
      .toList()
      .reversed
      .toList(); // Most recent first

  double get totalAmount => _requirements
      .fold(0.0, (sum, req) => sum + req.amount);

  double get paidAmount => _requirements
      .where((req) => req.isPaid)
      .fold(0.0, (sum, req) => sum + (req.amountPaid ?? req.amount));

  Future<void> loadRequirements(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.getMemberRequirements(token);

    _isLoading = false;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final requirementsList = data['requirements'] as List? ?? [];
      _requirements = requirementsList
          .map((item) => RequirementModel.fromJson(item))
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
    _requirements = [];
    notifyListeners();
  }
}