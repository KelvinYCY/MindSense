  import 'package:flutter/material.dart';
  import 'package:mind_sense/features/profile/screens/user_profile_screen.dart'; // Importing UserProfileScreen
  import '../explore/screens/user_explore_screen.dart'; // Importing UserExploreScreen
  import '../home/user_home_screen.dart'; // Importing UserHomeScreen
 
  class UserDashboardScreen extends StatefulWidget {
    const UserDashboardScreen({super.key});

    @override
    _UserDashboardScreenState createState() => _UserDashboardScreenState();
  }

  class _UserDashboardScreenState extends State<UserDashboardScreen> {
    int _selectedIndex = 0;

    // List of screens to display based on the bottom navigation bar
    final List<Widget> _screens = [
      const UserHomeScreen(),       // Home screen
      const UserExploreScreen(),    // Explore screen
      const UserProfileScreen(),    // Profile screen
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Dashboard'),
          automaticallyImplyLeading: false, // Ensure no back button is shown
        ),
        body: _screens[_selectedIndex], // Display the selected screen
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          onTap: _onItemTapped,
        ),
      );
    }
  }
