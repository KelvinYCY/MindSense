import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../meditation/screens/meditation_screen.dart';
import '../../sleep/screens/sleep_stories_screen.dart';
import '../../breathing/screens/breathing_exercise_screen.dart';
import '../../bodyscan/screens/body_scan_screen.dart';
import 'package:mind_sense/player/screens/audio_player_screen.dart';

class UserExploreScreen extends StatefulWidget {
  const UserExploreScreen({super.key});

  @override
  State<UserExploreScreen> createState() => _UserExploreScreenState();
}

class _UserExploreScreenState extends State<UserExploreScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildPersonalizedSuggestions(),
            const SizedBox(height: 16),
            _buildCategoriesTitle(),
            _buildCategoriesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Explore',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedSuggestions() {
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('meditations')
        .where('type', isEqualTo: 'featured')
        .limit(3)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended for You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final meditation = snapshot.data!.docs[index];
                  final data = meditation.data() as Map<String, dynamic>;
                  
                  return _buildSuggestionCard(
                    title: data['title'] ?? 'Untitled',
                    description: data['description'] ?? 'No description',
                    color: const Color(0xFF7CD0D7),
                    onTap: () => _openMeditation(data),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _openMeditation(Map<String, dynamic> meditationData) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AudioPlayerScreen(
        title: meditationData['title'] ?? 'Untitled',
        description: meditationData['description'] ?? 'No description',
        audioUrl: meditationData['audioUrl'] ?? '',
        imageUrl: meditationData['imageUrl'] ?? 'https://via.placeholder.com/400x200',
      ),
    ),
  );
}

  Widget _buildSuggestionCard({
  required String title, 
  required String description, 
  required Color color,
  required VoidCallback onTap,  // Add this parameter
}) {
  return GestureDetector(
    onTap: onTap,  // Use the onTap callback
    child: Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCategoriesTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Text(
        'Categories',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _buildCategoryCard(
              title: 'Guided Meditation',
              icon: Icons.self_improvement,
              color: const Color(0xFF9C89FF),
            ),
            _buildCategoryCard(
              title: 'Sleep Stories',
              icon: Icons.nightlight_round,
              color: const Color(0xFF7CD0D7),
            ),
            _buildCategoryCard(
              title: 'Breathing Exercises',
              icon: Icons.air,
              color: const Color(0xFFFFB16F),
            ),
            _buildCategoryCard(
              title: 'Body Scan',
              icon: Icons.accessibility_new,
              color: const Color(0xFFA8EDEA),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({required String title, required IconData icon, required Color color}) {
  return GestureDetector(
    onTap: () {
      switch (title) {
        case 'Guided Meditation':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MeditationScreen(),
            ),
          );
          break;
        case 'Sleep Stories':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SleepStoriesScreen(),
            ),
          );
          break;
        case 'Breathing Exercises':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BreathingExerciseScreen(),
            ),
          );
          break;
        case 'Body Scan':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BodyScanScreen(),
            ),
          );
          break;
      }
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
}