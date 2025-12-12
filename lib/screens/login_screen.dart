import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/screens/main_screen.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deviceController = TextEditingController(text: 'PSITS Mobile');
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  
  bool _showPassword = false;
  bool _rememberMe = true;
  bool _showIpConfig = false;
  bool _isSavingIp = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with test credentials
    _emailController.text = 'member@example.com';
    _passwordController.text = 'password123';
    
    // Initialize IP and port controllers
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    _ipController.text = ApiService.ipAddress;
    _portController.text = ApiService.port;
  }

  Future<void> _saveServerConfig() async {
    if (_ipController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter an IP address',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    if (_portController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a port number',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    setState(() => _isSavingIp = true);

    try {
      await ApiService.updateServerConfig(
        _ipController.text.trim(),
        _portController.text.trim(),
      );
      
      Fluttertoast.showToast(
        msg: 'Server configuration saved successfully!',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
      
      // Hide the config section after saving
      setState(() => _showIpConfig = false);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save configuration: $e',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isSavingIp = false);
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isSavingIp = true);
    
    try {
      // Test with a simple endpoint (assuming you have a /hello endpoint)
      final result = await ApiService.testPublic();
      
      if (result['success'] == true) {
        Fluttertoast.showToast(
          msg: 'Connection successful! Server is reachable.',
          backgroundColor: AppTheme.successColor,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Connection failed: ${result['message']}',
          backgroundColor: AppTheme.errorColor,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Connection error: $e',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isSavingIp = false);
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        deviceName: _deviceController.text.trim(),
      );
      
      if (success) {
        Fluttertoast.showToast(
          msg: 'Welcome to PSITS-NEXUS!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.successColor,
          textColor: Colors.white,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Fluttertoast.showToast(
          msg: authProvider.error ?? 'Login failed',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.errorColor,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _deviceController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Welcome Text
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: AppTheme.onBackground,
                        ),
                      ),
                      Text(
                        'PSITS-NEXUS',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Member Portal',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Server Configuration Section (Initially hidden)
                if (_showIpConfig) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.settings_ethernet, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Server Configuration',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => setState(() => _showIpConfig = false),
                                tooltip: 'Close',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Configure your PSITS-NEXUS server address',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          
                          // IP Address Field
                          TextFormField(
                            controller: _ipController,
                            decoration: InputDecoration(
                              labelText: 'Server IP Address',
                              hintText: '10.98.66.168',
                              prefixIcon: const Icon(Icons.computer),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an IP address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          // Port Field
                          TextFormField(
                            controller: _portController,
                            decoration: InputDecoration(
                              labelText: 'Port',
                              hintText: '8000',
                              prefixIcon: const Icon(Icons.numbers),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a port number';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid port number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSavingIp ? null : _testConnection,
                                  icon: const Icon(Icons.wifi, size: 20),
                                  label: const Text('Test Connection'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSavingIp ? null : _saveServerConfig,
                                  icon: _isSavingIp
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.save, size: 20),
                                  label: Text(_isSavingIp ? 'Saving...' : 'Save Configuration'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current Server: ${ApiService.baseUrl}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'member@psits-nexus.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          hintText: 'Enter your password',
                        ),
                        obscureText: !_showPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Fluttertoast.showToast(
                                msg: 'Contact administrator for password reset',
                                backgroundColor: AppTheme.warningColor,
                              );
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      if (authProvider.isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Server Configuration Button (Small and subtle)
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _showIpConfig = true);
                    },
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Configure Server'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Note Card
                Card(
                  elevation: 0,
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Note',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This app is exclusively for registered PSITS-NEXUS members. '
                          'If you are not a member, please contact the PSITS admin/officer.',
                          style: TextStyle(color: AppTheme.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Server: ${ApiService.baseUrl}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
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
      ),
    );
  }
}