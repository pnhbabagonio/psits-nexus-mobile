import 'package:flutter/foundation.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';
import 'package:psits_nexus_mobile/models/support_ticket_model.dart';

class SupportTicketProvider with ChangeNotifier {
  List<SupportTicket> _tickets = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<SupportTicket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  List<SupportTicket> get openTickets => _tickets
      .where((ticket) => ticket.status.toLowerCase() == 'open')
      .toList()
      .reversed
      .toList();

  List<SupportTicket> get inProgressTickets => _tickets
      .where((ticket) => ticket.status.toLowerCase() == 'in_progress')
      .toList()
      .reversed
      .toList();

  List<SupportTicket> get resolvedTickets => _tickets
      .where((ticket) => ticket.status.toLowerCase() == 'resolved' || ticket.status.toLowerCase() == 'closed')
      .toList()
      .reversed
      .toList();

  Future<void> loadTickets(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.getSupportTickets(token);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final ticketsList = data['tickets'] as List? ?? [];
        _tickets = ticketsList
            .map((item) => SupportTicket.fromJson(item))
            .toList();
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Failed to load support tickets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createTicket({
    required String token,
    required String subject,
    required String message,
    required String category,
    required String priority,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final result = await ApiService.createSupportTicket(
        token: token,
        subject: subject,
        message: message,
        category: category,
        priority: priority,
      );

      if (result['success'] == true) {
        // Reload tickets to include the new one
        await loadTickets(token);
        return {
          'success': true,
          'message': 'Support ticket created successfully',
        };
      } else {
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create support ticket: $e',
      };
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _tickets = [];
    notifyListeners();
  }
}