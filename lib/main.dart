import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'core/auth/auth_wrapper.dart'; // Import the AuthWrapper
import 'config/firebase_options.dart'; // Firebase options
import 'features/auth/screens/welcome_screen.dart'; // Import WelcomeScreen
import 'features/auth/screens/user_login_screen.dart'; // Import UserLoginScreen
import 'features/dashboard/user_dashboard_screen.dart'; // Import UserDashboardScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    debugPrint('Firebase initialized');
  runApp(const MindSenseApp());
}

class MindSenseApp extends StatelessWidget {
  const MindSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindSense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => const WelcomeScreen(), // Route to WelcomeScreen
        '/user-login': (context) => const LoginScreen(), // Route to UserLoginScreen
        '/user-dashboard': (context) => const UserDashboardScreen(), // Route to UserDashboardScreen
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const WelcomeScreen(), // Fallback route
      ),
    );
  }
}
