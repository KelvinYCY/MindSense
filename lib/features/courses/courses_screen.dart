import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final List<String> categories = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Meditation',
    'Sleep',
    'Anxiety',
  ];

  String selectedCategory = 'All';
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text(
                'Courses',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(categories[index]),
                      selected: selectedCategory == categories[index],
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = categories[index];
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.deepPurple.shade100,
                      checkmarkColor: Colors.deepPurple,
                      labelStyle: TextStyle(
                        color: selectedCategory == categories[index]
                            ? Colors.deepPurple
                            : Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Featured Course
          if (!isSearching) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://via.placeholder.com/400x200',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mindfulness Basics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '10 lessons • Beginner friendly',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Courses Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        const Text('Error loading courses.'),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No courses available yet.'),
                      ],
                    ),
                  );
                }

                var courses = snapshot.data!.docs;

                // Filter courses based on search and category
                if (searchController.text.isNotEmpty) {
                  courses = courses.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['title']
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase());
                  }).toList();
                }

                if (selectedCategory != 'All') {
                  courses = courses.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['level'] == selectedCategory ||
                        (data['tags'] as List).contains(selectedCategory);
                  }).toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 1.8),
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    var courseData = courses[index].data() as Map<String, dynamic>;
                    return CourseTile(
                      courseData: courseData,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CourseDetailScreen(courseData: courseData),
                          ),
                        );
                      },
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

class CourseTile extends StatelessWidget {
  final Map<String, dynamic> courseData;
  final VoidCallback onTap;

  const CourseTile({
    super.key,
    required this.courseData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20.0)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Image.network(
                      courseData['imageUrl'] ?? 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                    if (courseData['progress'] != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: courseData['progress'].toDouble(),
                          backgroundColor: Colors.black26,
                          color: Colors.deepPurple,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          courseData['level'] ?? 'All Levels',
                          style: TextStyle(
                            color: Colors.deepPurple.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        courseData['rating']?.toString() ?? '4.5',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseData['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        courseData['duration'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.play_lesson,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${courseData['lessons']?.toString() ?? '0'} lessons',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
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


class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDetailScreen({super.key, required this.courseData});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  Duration audioDuration = Duration.zero;
  Duration currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listen for audio duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        audioDuration = duration;
      });
    });

    // Listen for audio position changes
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void playAudio() async {
    setState(() => isLoading = true);
    try {
      await _audioPlayer.play(UrlSource(widget.courseData['audioUrl']));
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  void pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  void stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      currentPosition = Duration.zero; // Reset the position
    });
  }

  void rewindAudio() async {
    final newPosition = currentPosition - const Duration(seconds: 10);
    if (newPosition >= Duration.zero) {
      await _audioPlayer.seek(newPosition);
    }
  }

  void forwardAudio() async {
    final newPosition = currentPosition + const Duration(seconds: 10);
    if (newPosition <= audioDuration) {
      await _audioPlayer.seek(newPosition);
    }
  }

  void seekAudio(double value) {
    final newPosition = Duration(milliseconds: value.toInt());
    _audioPlayer.seek(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    bool hasAudio = widget.courseData['audioUrl'] != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseData['title'] ?? 'Course Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.courseData['imageUrl'] ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.courseData['title'] ?? 'Untitled',
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.courseData['description'] ?? 'No description available',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text('Duration: ${widget.courseData['duration'] ?? 'Unknown'}'),
            Text('Level: ${widget.courseData['level'] ?? 'Unknown'}'),
            Text('Tags: ${widget.courseData['tags'] ?? 'No tags'}'),
            const SizedBox(height: 16.0),
            if (hasAudio) ...[
              Slider(
                value: currentPosition.inMilliseconds.toDouble(),
                min: 0,
                max: audioDuration.inMilliseconds.toDouble() > 0
                    ? audioDuration.inMilliseconds.toDouble()
                    : 1, // To avoid the slider being disabled
                onChanged: (value) {
                  seekAudio(value);
                },
              ),
              Text(
                '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / ${audioDuration.inMinutes}:${(audioDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            _buildAudioControls(hasAudio),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls(bool hasAudio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10, size: 32, color: Colors.deepPurple),
          onPressed: hasAudio ? rewindAudio : null,
        ),
        IconButton(
          icon: isLoading
              ? const CircularProgressIndicator()
              : Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 48,
                  color: Colors.deepPurple,
                ),
          onPressed: isLoading ? null : (isPlaying ? pauseAudio : playAudio),
        ),
        IconButton(
          icon: const Icon(Icons.stop_circle, size: 48, color: Colors.red),
          onPressed: hasAudio ? stopAudio : null,
        ),
        IconButton(
          icon: const Icon(Icons.forward_10, size: 32, color: Colors.deepPurple),
          onPressed: hasAudio ? forwardAudio : null,
        ),
      ],
    );
  }
}
