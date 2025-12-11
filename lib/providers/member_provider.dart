import 'package:flutter/foundation.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';
import 'package:psits_nexus_mobile/models/user_model.dart';
import 'package:psits_nexus_mobile/models/dashboard_data.dart';

class MemberProvider with ChangeNotifier {
  UserModel? _profile;
  DashboardData? _dashboardData; // Change to use DashboardData model
  bool _isLoading = false;
  bool _isDashboardLoading = false;
  String? _error;

  UserModel? get profile => _profile;
  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  bool get isDashboardLoading => _isDashboardLoading;
  String? get error => _error;

  Future<void> loadProfile(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.getMemberProfile(token);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        _profile = UserModel.fromJson(data['profile'] ?? data); // Handle both structures
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard(String token) async {
    _isDashboardLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.getMemberDashboard(token);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        
        // Check if the data has 'summary' key or is already the summary
        if (data.containsKey('summary')) {
          _dashboardData = DashboardData.fromJson(data['summary']);
        } else {
          // If the data is directly the summary
          _dashboardData = DashboardData.fromJson(data);
        }
        
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Failed to load dashboard: $e';
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _profile = null;
    _dashboardData = null;
    notifyListeners();
  }
}