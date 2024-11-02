import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/screens/welcome_screen.dart';  // Import Welcome Screen
import '../../features/dashboard/user_dashboard_screen.dart';     // Import Home Screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          // If the user is logged in, show the Home Screen
          if (user == null) {
            return const WelcomeScreen();  // Not logged in, show Welcome/Login
          } else {
            return UserDashboardScreen();  // Logged in, show Home Screen
          }
        } else {
          // Show a loading spinner while checking the auth state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}