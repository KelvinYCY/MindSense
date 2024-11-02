import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'challenge_detail_screen.dart'; // Import the detail screen

class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  _DailyChallengesScreenState createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final challengesRef = FirebaseFirestore.instance.collection('daily_challenges');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Mindfulness Challenges'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search challenges...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: challengesRef.orderBy('date', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error loading challenges: ${snapshot.error}'),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No challenges available.'));
                }

                final challenges = snapshot.data!.docs.where((doc) {
                  final title = doc['title'] ?? '';
                  return title.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: challenges.length,
                  itemBuilder: (context, index) {
                    final challenge = challenges[index].data() as Map<String, dynamic>;
                    return ChallengeBlock(
                      challenge: challenge,
                      docId: challenges[index].id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeBlock extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final String docId;

  const ChallengeBlock({
    super.key,
    required this.challenge,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final title = challenge['title'] ?? 'No Title';
    final imageUrl = challenge['imageUrl'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeDetailScreen(
              challenge: challenge,
              docId: docId,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl.isNotEmpty
                  ? Hero(
                      tag: 'challenge_$docId',
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 100),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.self_improvement, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (challenge['date'] as Timestamp).toDate().toLocal().toString().split(' ')[0],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
