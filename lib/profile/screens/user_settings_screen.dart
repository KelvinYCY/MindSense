import 'package:flutter/material.dart';
import '../../features/auth/screens/user_login_screen.dart'; // Import the UserLoginScreen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Log Out Block
            LogoutBlock(
              onTap: () {
                // Add your log out logic here
                print('User logged out');

                // Navigate to the UserLoginScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Logout Block Widget
class LogoutBlock extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutBlock({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(
              Icons.logout,
              size: 40.0,
              color: Colors.red, // Log out icon color
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Log out text color
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
