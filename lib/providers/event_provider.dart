import 'package:flutter/foundation.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';
import 'package:psits_nexus_mobile/models/event_model.dart';

class EventProvider with ChangeNotifier {
  List<EventModel> _events = [];
  List<EventModel> _joinedEvents = [];
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _error;

  List<EventModel> get events => _events;
  List<EventModel> get joinedEvents => _joinedEvents;
  bool get isLoading => _isLoading;
  bool get isRegistering => _isRegistering;
  String? get error => _error;

  // Filter events by status
  List<EventModel> get upcomingEvents => _events
      .where((event) => event.status.toLowerCase() == 'upcoming')
      .toList()
      .reversed
      .toList();

  List<EventModel> get ongoingEvents => _events
      .where((event) => event.status.toLowerCase() == 'ongoing')
      .toList()
      .reversed
      .toList();

  List<EventModel> get pastEvents => _events
      .where((event) => event.status.toLowerCase() == 'completed' || 
                       event.status.toLowerCase() == 'cancelled')
      .toList()
      .reversed
      .toList();

  // Load all events
  Future<void> loadEvents(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.getEvents(token);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final eventsList = data['events'] as List? ?? [];
        _events = eventsList
            .map((item) => EventModel.fromJson(item))
            .toList();
        
        // Also load joined events to update registration status
        await _loadJoinedEvents(token);
        
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = 'Failed to load events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load joined events
  Future<void> _loadJoinedEvents(String token) async {
    try {
      final result = await ApiService.getJoinedEvents(token);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final joinedEventsList = data['joined_events'] as List? ?? [];
        _joinedEvents = joinedEventsList
            .map((item) => EventModel.fromJson(item))
            .toList();

        // Update registration status in main events list
        _updateEventsRegistrationStatus();
      }
    } catch (e) {
      print('Failed to load joined events: $e');
    }
  }

  // Update registration status in events list
  void _updateEventsRegistrationStatus() {
    final Map<int, EventModel> joinedEventsMap = {
      for (var event in _joinedEvents) event.id: event
    };

    _events = _events.map((event) {
      if (joinedEventsMap.containsKey(event.id)) {
        final joinedEvent = joinedEventsMap[event.id]!;
        return event.copyWith(
          attendanceStatus: joinedEvent.attendanceStatus,
          registeredAt: joinedEvent.registeredAt,
          isRegistered: true,
        );
      }
      return event;
    }).toList();
  }

  // Register for an event
  Future<Map<String, dynamic>> registerForEvent(String token, int eventId) async {
    _isRegistering = true;
    notifyListeners();

    try {
      final result = await ApiService.registerForEvent(token, eventId);

      if (result['success'] == true) {
        // Update the event in the list
        final index = _events.indexWhere((event) => event.id == eventId);
        if (index != -1) {
          _events[index] = _events[index].copyWith(
            isRegistered: true,
            attendanceStatus: 'registered',
            registeredAt: DateTime.now(),
          );
          notifyListeners();
        }
        return {'success': true, 'message': 'Successfully registered for event'};
      } else {
        return {'success': false, 'message': result['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to register: $e'};
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  // Cancel event registration
  Future<Map<String, dynamic>> cancelEventRegistration(String token, int eventId) async {
    _isRegistering = true;
    notifyListeners();

    try {
      final result = await ApiService.cancelEventRegistration(token, eventId);

      if (result['success'] == true) {
        // Update the event in the list
        final index = _events.indexWhere((event) => event.id == eventId);
        if (index != -1) {
          _events[index] = _events[index].copyWith(
            isRegistered: false,
            attendanceStatus: null,
            registeredAt: null,
          );
          notifyListeners();
        }
        return {'success': true, 'message': 'Successfully cancelled registration'};
      } else {
        return {'success': false, 'message': result['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to cancel registration: $e'};
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  // Check registration status
  Future<Map<String, dynamic>> checkRegistration(String token, int eventId) async {
    try {
      final result = await ApiService.checkEventRegistration(token, eventId);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Failed to check registration: $e'};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _events = [];
    _joinedEvents = [];
    notifyListeners();
  }
}