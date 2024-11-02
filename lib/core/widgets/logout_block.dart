import 'package:flutter/material.dart';

class LogoutBlock extends StatelessWidget {
  final String userId;  // Add userId as a parameter
  final VoidCallback onTap;

  const LogoutBlock({super.key, 
    required this.userId,  // Accept userId in the constructor
    required this.onTap,
  });

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
