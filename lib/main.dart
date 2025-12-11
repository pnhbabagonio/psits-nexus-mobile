import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psits_nexus_mobile/providers/auth_provider.dart';
import 'package:psits_nexus_mobile/providers/member_provider.dart';
import 'package:psits_nexus_mobile/providers/event_provider.dart';
import 'package:psits_nexus_mobile/providers/payment_provider.dart';
import 'package:psits_nexus_mobile/providers/requirement_provider.dart';
import 'package:psits_nexus_mobile/screens/splash_screen.dart';
import 'package:psits_nexus_mobile/screens/login_screen.dart';
import 'package:psits_nexus_mobile/screens/main_screen.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';
import 'package:psits_nexus_mobile/services/api_service.dart';
import 'package:psits_nexus_mobile/providers/support_ticket_provider.dart';
import 'package:psits_nexus_mobile/screens/chatbot_screen.dart';
import 'package:psits_nexus_mobile/providers/chatbot_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service from shared preferences
  await ApiService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => RequirementProvider()),
        ChangeNotifierProvider(create: (_) => SupportTicketProvider()),
        // Add to your providers list in main.dart
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: MaterialApp(
        title: 'PSITS-NEXUS Member',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const MainScreen(),
          '/chatbot': (context) => const ChatbotScreen(),
        },
      ),
    );
  }
}
