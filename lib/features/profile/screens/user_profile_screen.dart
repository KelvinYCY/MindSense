import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../../profile/models/user_model.dart';
import 'user_settings_screen.dart';
import '../../profile/widgets/profile_block.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String userName = 'Loading...';
  String userEmail = 'No email available';
  int totalSessions = 0;
  int totalMinutes = 0;
  int streakDays = 0;
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        UserModel? user = await UserService().getUserData(currentUser.uid);
        if (user != null) {
          setState(() {
            userName = user.name;
            userEmail = user.email;
            totalSessions = user.totalSessions;
            streakDays = user.streakCount;
            totalMinutes = user.totalMinutes;
            isLoading = false;
          });
        }

        // Fetch latest completed sessions
        await _fetchCompletedSessions(currentUser.uid);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCompletedSessions(String userId) async {
    try {
      final sessionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_sessions')
          .orderBy('completedAt', descending: true)
          .limit(5)
          .get();

      // You can use this data to show recent activity
      for (var doc in sessionsSnapshot.docs) {
        print(doc.data()); // For debugging
      }
    } catch (e) {
      print('Error fetching completed sessions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUserData,
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar with Profile Header
                  SliverAppBar(
                    expandedHeight: 150.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.deepPurple,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.deepPurple,
                              Colors.deepPurple.shade300,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Stats Cards
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Streak',
                              '$streakDays days',
                              Icons.local_fire_department,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Sessions',
                              '$totalSessions',
                              Icons.spa,
                              Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Minutes',
                              '$totalMinutes',
                              Icons.timer,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main Content
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Progress Section
                        ProfileBlock(
                          title: 'My Progress',
                          icon: Icons.trending_up,
                          iconColor: Colors.green,
                          onTap: () {
                            // Show detailed progress screen
                          },
                          content:
                              'Total meditation time: $totalMinutes minutes\nConsecutive days: $streakDays',
                        ),
                        const SizedBox(height: 16),

                        // Activity History
                        ProfileBlock(
                          title: 'Recent Activity',
                          icon: Icons.history,
                          iconColor: Colors.blue,
                          onTap: () {
                            // Show activity history screen
                          },
                          content: 'Completed sessions: $totalSessions\nMeditation streak: $streakDays days',
                        ),
                        const SizedBox(height: 16),

                        // Settings
                        ProfileBlock(
                          title: 'Settings',
                          icon: Icons.settings,
                          iconColor: Colors.grey,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          content: 'Customize your app settings and preferences.',
                        ),

                        const SizedBox(height: 16),
                        // Logout Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}