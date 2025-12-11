import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/screens/dashboard_screen.dart';
import 'package:psits_nexus_mobile/screens/profile_screen.dart';
import 'package:psits_nexus_mobile/screens/payments_screen.dart';
import 'package:psits_nexus_mobile/screens/requirements_screen.dart';
import 'package:psits_nexus_mobile/screens/events_screen.dart';
import 'package:psits_nexus_mobile/screens/chatbot_screen.dart'; // Add this import
import 'package:psits_nexus_mobile/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _showChatButton = true;

  static final List<Widget> _screens = [
    const DashboardScreen(),
    const EventsScreen(),
    const PaymentsScreen(),
    const RequirementsScreen(),
    const ProfileScreen(),
  ];

  static const List<NavigationDestination> _navDestinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_outlined),
      selectedIcon: Icon(Icons.event),
      label: 'Events',
    ),
    NavigationDestination(
      icon: Icon(Icons.payments_outlined),
      selectedIcon: Icon(Icons.payments),
      label: 'Payments',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt_outlined),
      selectedIcon: Icon(Icons.list_alt),
      label: 'Requirements',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Hide chat button on chatbot screen
      _showChatButton = index != 4; // Assuming chatbot is at index 4 if we add it
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'PSITS-NEXUS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (user != null && (user['role'] == 'Officer' || user['role'] == 'Admin'))
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user['role'] == 'Admin' ? 'ADMIN' : 'OFFICER',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          // Changed from notifications to chatbot
          // IconButton(
          //   icon: const Icon(Icons.smart_toy_outlined), // Robot icon
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const ChatbotScreen(),
          //       ),
          //     );
          //   },
          //   tooltip: 'PSITS Assistant',
          // ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _navDestinations,
      ),
      // Floating chat button
      floatingActionButton: _showChatButton
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatbotScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.smart_toy),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              tooltip: 'Chat with PSITS Assistant',
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}