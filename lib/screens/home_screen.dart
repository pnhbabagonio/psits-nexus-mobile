import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _testResult;
  bool _isTesting = false;

  Future<void> _testPublicEndpoint() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final result = await ApiService.testPublic();
    
    setState(() {
      _isTesting = false;
      _testResult = result;
    });

    if (result['success'] == true) {
      Fluttertoast.showToast(
        msg: 'Public endpoint works!',
        backgroundColor: Colors.green,
      );
    } else {
      Fluttertoast.showToast(
        msg: result['message'],
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _testProtectedEndpoint() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final result = await ApiService.testProtected(authProvider.token!);
    
    setState(() {
      _isTesting = false;
      _testResult = result;
    });

    if (result['success'] == true) {
      Fluttertoast.showToast(
        msg: 'Protected endpoint works!',
        backgroundColor: Colors.green,
      );
    } else {
      Fluttertoast.showToast(
        msg: result['message'],
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _getUsers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final result = await ApiService.getUsers(authProvider.token!);
    
    setState(() {
      _isTesting = false;
      _testResult = result;
    });

    if (result['success'] == true) {
      final usersCount = result['users']?.length ?? 0;
      Fluttertoast.showToast(
        msg: 'Found $usersCount users',
        backgroundColor: Colors.green,
      );
    } else {
      Fluttertoast.showToast(
        msg: result['message'],
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _refreshToken() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final result = await ApiService.refreshToken(authProvider.token!);
    
    setState(() {
      _isTesting = false;
      _testResult = result;
    });

    if (result['success'] == true) {
      // Update token in provider (you'll need to add this method)
      Fluttertoast.showToast(
        msg: 'Token refreshed!',
        backgroundColor: Colors.green,
      );
    } else {
      Fluttertoast.showToast(
        msg: result['message'],
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Testing Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Fluttertoast.showToast(
                msg: 'Logged out successfully',
                backgroundColor: Colors.green,
              );
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '👤 User Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user != null) ...[
                        _buildInfoRow('Name', user['name'] ?? 'N/A'),
                        _buildInfoRow('Email', user['email'] ?? 'N/A'),
                        _buildInfoRow('Role', user['role'] ?? 'N/A'),
                        _buildInfoRow('Program', user['program'] ?? 'N/A'),
                        _buildInfoRow('Year', user['year'] ?? 'N/A'),
                        if (user['student_id'] != null)
                          _buildInfoRow('Student ID', user['student_id']),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Token: ${authProvider.token?.substring(0, 30)}...',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // API Testing Section
              const Text(
                '🔧 API Testing',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Quick Actions Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    icon: Icons.public,
                    title: 'Test Public',
                    color: Colors.green,
                    onTap: _testPublicEndpoint,
                  ),
                  _buildActionCard(
                    icon: Icons.lock,
                    title: 'Test Protected',
                    color: Colors.orange,
                    onTap: _testProtectedEndpoint,
                  ),
                  _buildActionCard(
                    icon: Icons.people,
                    title: 'Get Users',
                    color: Colors.blue,
                    onTap: _getUsers,
                  ),
                  _buildActionCard(
                    icon: Icons.refresh,
                    title: 'Refresh Token',
                    color: Colors.purple,
                    onTap: _refreshToken,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Results Section
              if (_isTesting)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Testing API...'),
                    ],
                  ),
                ),
              
              if (_testResult != null) ...[
                const Text(
                  '📊 Test Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _testResult!['success'] == true
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _testResult!['success'] == true
                                ? 'SUCCESS'
                                : 'FAILED',
                            style: TextStyle(
                              color: _testResult!['success'] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ')
                                  .convert(_testResult),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
              
              // Server Info
              Card(
                color: const Color(0xFF667EEA),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🌐 Server Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Base URL: ${ApiService.baseUrl}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${authProvider.isAuthenticated ? 'Connected' : 'Disconnected'}',
                        style: TextStyle(
                          color: authProvider.isAuthenticated
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}