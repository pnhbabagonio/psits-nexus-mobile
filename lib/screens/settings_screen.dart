// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _biometricLogin = false;
  bool _autoSync = true;
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _biometricLogin = prefs.getBool('biometric_login') ?? false;
      _autoSync = prefs.getBool('auto_sync') ?? true;
      _language = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsSwitch(
                      title: 'Push Notifications',
                      subtitle: 'Receive updates about events, payments, and requirements',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        _saveSetting('notifications_enabled', value);
                      },
                    ),
                    const Divider(),
                    _buildSettingsSwitch(
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark theme',
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() => _darkMode = value);
                        _saveSetting('dark_mode', value);
                        // Note: You might want to add theme switching logic here
                      },
                    ),
                    const Divider(),
                    _buildSettingsSwitch(
                      title: 'Biometric Login',
                      subtitle: 'Use fingerprint or face ID for login',
                      value: _biometricLogin,
                      onChanged: (value) {
                        setState(() => _biometricLogin = value);
                        _saveSetting('biometric_login', value);
                      },
                    ),
                    const Divider(),
                    _buildSettingsSwitch(
                      title: 'Auto Sync',
                      subtitle: 'Automatically sync data when online',
                      value: _autoSync,
                      onChanged: (value) {
                        setState(() => _autoSync = value);
                        _saveSetting('auto_sync', value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Language Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _language,
                      decoration: const InputDecoration(
                        labelText: 'App Language',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'es',
                          child: Text('Spanish'),
                        ),
                        DropdownMenuItem(
                          value: 'fr',
                          child: Text('French'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _language = value!);
                        _saveSetting('language', value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Server Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Server Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Configure your server connection settings',
                      style: TextStyle(
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.settings_ethernet),
                      title: const Text('Server Settings'),
                      subtitle: const Text('Change IP address and port'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // You can navigate to server config screen or show a dialog
                        _showServerConfigDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Clear Cache'),
                      subtitle: const Text('Remove temporary app data'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _clearCache,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Export Data'),
                      subtitle: const Text('Download your personal data'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _exportData,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // About App
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAboutItem(
                      icon: Icons.info_outline,
                      title: 'Version',
                      value: '1.0.0',
                    ),
                    const Divider(),
                    _buildAboutItem(
                      icon: Icons.update,
                      title: 'Last Updated',
                      value: 'December 2023',
                    ),
                    const Divider(),
                    _buildAboutItem(
                      icon: Icons.security,
                      title: 'Security',
                      value: 'End-to-end encrypted',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Reset to Defaults
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetToDefaults,
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Default Settings'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppTheme.errorColor,
                  side: BorderSide(color: AppTheme.errorColor.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile.adaptive(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.onSurface.withOpacity(0.6),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildAboutItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear app cache? This will remove temporary files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Implement cache clearing logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _exportData() async {
    // Implement data export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature coming soon'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showServerConfigDialog() {
    // You can implement a dialog for server configuration
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Configuration'),
        content: const Text('This feature allows you to change the server IP address and port. Go to login screen to configure server settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      setState(() {
        _notificationsEnabled = true;
        _darkMode = false;
        _biometricLogin = false;
        _autoSync = true;
        _language = 'en';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}