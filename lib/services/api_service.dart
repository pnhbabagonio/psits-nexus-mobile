import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _baseUrl = 'http://10.98.66.168:8000/api';
  static String _ipAddress = '10.98.66.168';
  static String _port = '8000';
  
  // Initialize from shared preferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedIp = prefs.getString('server_ip');
    final savedPort = prefs.getString('server_port');
    
    if (savedIp != null && savedIp.isNotEmpty) {
      _ipAddress = savedIp;
    }
    
    if (savedPort != null && savedPort.isNotEmpty) {
      _port = savedPort;
    }
    
    _updateBaseUrl();
  }

  
  // Update base URL
  static void _updateBaseUrl() {
    _baseUrl = 'http://$_ipAddress:$_port/api';
  }
  
  // Get current base URL
  static String get baseUrl => _baseUrl;
  static String get ipAddress => _ipAddress;
  static String get port => _port;
  
  // Update IP and port
  static Future<void> updateServerConfig(String ip, String port) async {
    _ipAddress = ip.trim();
    _port = port.trim();
    _updateBaseUrl();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _ipAddress);
    await prefs.setString('server_port', _port);
  }
  
  // Helper method for API calls
  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed with status ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
        'url': '$_baseUrl$endpoint',
      };
    }
  }

  // Authentication
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final result = await _makeRequest('POST', '/auth/login', body: {
      'email': email,
      'password': password,
      'device_name': deviceName,
    });

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      return {
        'success': true,
        'token': data['token'],
        'user': data['user'],
      };
    }
    
    return result;
  }

  static Future<Map<String, dynamic>> getUser(String token) async {
    final result = await _makeRequest('GET', '/auth/user', token: token);
    
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      return {
        'success': true,
        'user': data['user'],
      };
    }
    
    return result;
  }

  static Future<Map<String, dynamic>> logout(String token) async {
    return await _makeRequest('POST', '/auth/logout', token: token);
  }

  static Future<Map<String, dynamic>> refreshToken(String token) async {
    return await _makeRequest('POST', '/auth/refresh', token: token);
  }

  // Member Endpoints
  static Future<Map<String, dynamic>> getMemberProfile(String token) async {
    return await _makeRequest('GET', '/member/profile', token: token);
  }

  static Future<Map<String, dynamic>> getMemberDashboard(String token) async {
    return await _makeRequest('GET', '/member/dashboard', token: token);
  }

  static Future<Map<String, dynamic>> getMemberPayments(String token) async {
    return await _makeRequest('GET', '/member/payments', token: token);
  }

  static Future<Map<String, dynamic>> getMemberRequirements(String token) async {
    return await _makeRequest('GET', '/member/requirements', token: token);
  }

  // Events - NOTE: There are two routes, one inside /member and one public
  // Using the public one that requires authentication
  static Future<Map<String, dynamic>> getEvents(String token) async {
    return await _makeRequest('GET', '/events', token: token);
  }

  // Public Test
  static Future<Map<String, dynamic>> testPublic() async {
    return await _makeRequest('GET', '/hello');
  }

  // Protected Test
  static Future<Map<String, dynamic>> testProtected(String token) async {
    return await _makeRequest('GET', '/protected-test', token: token);
  }

  static Future<Map<String, dynamic>> getUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'users': data['data'] ?? [],
          'message': 'Users retrieved successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch users',
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String program,
    required String year,
    required String role,
    String? studentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'program': program,
          'year': year,
          'role': role,
          if (studentId != null) 'student_id': studentId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'] ?? data['data']['token'],
          'user': data['user'] ?? data['data']['user'],
          'message': 'Registration successful',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'status': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

// Event Registration Endpoints
static Future<Map<String, dynamic>> getEventDetails(String token, int eventId) async {
  return await _makeRequest('GET', '/events/$eventId', token: token);
}

static Future<Map<String, dynamic>> registerForEvent(String token, int eventId) async {
  return await _makeRequest('POST', '/events/$eventId/register', token: token);
}

static Future<Map<String, dynamic>> cancelEventRegistration(String token, int eventId) async {
  return await _makeRequest('DELETE', '/events/$eventId/unregister', token: token);
}

static Future<Map<String, dynamic>> checkEventRegistration(String token, int eventId) async {
  return await _makeRequest('GET', '/events/$eventId/check-registration', token: token);
}

static Future<Map<String, dynamic>> getJoinedEvents(String token) async {
  return await _makeRequest('GET', '/member/joined-events', token: token);
}

// Support Tickets Endpoints
static Future<Map<String, dynamic>> createSupportTicket({
  required String token,
  required String subject,
  required String message,
  required String category,
  required String priority,
}) async {
  return await _makeRequest('POST', '/support-tickets', token: token, body: {
    'subject': subject,
    'message': message,
    'category': category,
    'priority': priority,
  });
}

static Future<Map<String, dynamic>> getSupportTickets(String token) async {
  return await _makeRequest('GET', '/support-tickets', token: token);
}

static Future<Map<String, dynamic>> getSupportTicket(String token, int ticketId) async {
  return await _makeRequest('GET', '/support-tickets/$ticketId', token: token);
}

}

