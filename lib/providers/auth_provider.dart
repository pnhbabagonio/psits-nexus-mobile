import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      await _loadUserData();
    }
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    if (_token != null) {
      final result = await ApiService.getUser(_token!);
      if (result['success'] == true) {
        _user = result['user'];
      }
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    _user = null;
  }

  Future<bool> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.login(
      email: email,
      password: password,
      deviceName: deviceName,
    );

    _isLoading = false;

    if (result['success'] == true) {
      await _saveToken(result['token']);
      _user = result['user'];
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String program,
    required String year,
    required String role,
    String? studentId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.register(
      name: name,
      email: email,
      password: password,
      program: program,
      year: year,
      role: role,
      studentId: studentId,
    );

    _isLoading = false;

    if (result['success'] == true) {
      await _saveToken(result['token']);
      _user = result['user'];
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      await ApiService.logout(_token!);
    }
    await _clearToken();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}