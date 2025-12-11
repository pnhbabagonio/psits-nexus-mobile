import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/providers/member_provider.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';
import 'package:psits_nexus_mobile/screens/settings_screen.dart';
import 'package:psits_nexus_mobile/screens/help_and_support_screen.dart';
import 'package:psits_nexus_mobile/screens/privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    
    if (authProvider.token == null) return;

    setState(() {
      _isLoading = true;
    });

    await memberProvider.loadProfile(authProvider.token!);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final user = authProvider.user;
    final profile = memberProvider.profile;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryDark,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?['name']?.substring(0, 1).toUpperCase() ?? 'M',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile?.fullName ?? user?['name'] ?? 'Member',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user?['email'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Personal Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onBackground,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              label: 'Student ID',
                              value: profile?.studentId ?? user?['student_id'] ?? 'N/A',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Program',
                              value: profile?.program ?? user?['program'] ?? 'N/A',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Year Level',
                              value: profile?.year ?? user?['year'] ?? 'N/A',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Role',
                              value: profile?.role ?? user?['role'] ?? 'Member',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Status',
                              value: profile?.isActive == true ? 'Active' : 'Inactive',
                              valueColor: profile?.isActive == true
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onBackground,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              label: 'Member Since',
                              value: profile?.formattedMemberSince ?? 'N/A',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Last Login',
                              value: profile?.formattedLastLogin ?? 'Never',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              label: 'Account Type',
                              value: profile?.isOfficer == true ? 'Officer/Admin' : 'Member',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Settings
                    Card(
                      child: Column(
                        children: [
                ListTile(
                  leading: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.onSurface,
                  ),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    color: AppTheme.onSurface,
                  ),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpAndSupportScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: AppTheme.onSurface,
                  ),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                          const Divider(height: 0),
                          ListTile(
                            leading: Icon(
                              Icons.logout,
                              color: AppTheme.errorColor,
                            ),
                            title: Text(
                              'Logout',
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                            onTap: () async {
                              await authProvider.logout();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppTheme.onBackground,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}