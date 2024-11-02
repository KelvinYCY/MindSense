import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> challenge;
  final String docId;

  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
    required this.docId,
  });

  @override
  _ChallengeDetailScreenState createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool completed = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    completed = widget.challenge['completed'] ?? false;

    // Listen for audio position updates
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Listen for the total duration of the audio
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    // Check if audio has completed
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        _currentPosition = _totalDuration;

        // Mark challenge as complete if audio finishes
        _markAsCompleted();
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void toggleAudio(String audioUrl) async {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else {
      try {
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() => isPlaying = true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void _markAsCompleted() async {
    try {
      await FirebaseFirestore.instance
          .collection('daily_challenges')
          .doc(widget.docId)
          .update({'completed': true});

      setState(() {
        completed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as complete')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.challenge['title'] ?? 'No Title';
    final description = widget.challenge['description'] ?? 'No Description';
    final category = widget.challenge['category'] ?? 'No Category';
    final duration = widget.challenge['duration'] ?? 0;
    final audioUrl = widget.challenge['audioUrl'] ?? '';
    final imageUrl = widget.challenge['imageUrl'] ?? ''; // We are using this field
    final date = (widget.challenge['date'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty) // Only show the image if the URL is not empty
              Hero(
                tag: 'challenge_${widget.docId}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: 100, color: Colors.red);
                    },
                  ),
                ),
              )
            else
              Icon(
                Icons.self_improvement,
                size: 100,
                color: Colors.grey[400],
              ),
            const SizedBox(height: 20),
            Text(
              description,
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.category, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('Category: $category', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.timer, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('Duration: $duration mins', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.date_range, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('Date: ${date.toLocal()}'.split(' ')[0], style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20),

            // Audio control section
            if (audioUrl.isNotEmpty) ...[
              Text(
                'Audio Progress:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                activeColor: Colors.deepPurple,
                value: _currentPosition.inSeconds.toDouble(),
                max: _totalDuration.inSeconds.toDouble(),
                onChanged: (value) async {
                  final newPosition = Duration(seconds: value.toInt());
                  await _audioPlayer.seek(newPosition);
                },
              ),
              Text(
                '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / '
                '${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Center(
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 64,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () => toggleAudio(audioUrl),
                ),
              ),
            ],
            const Spacer(),
            if (!completed)
              Center(
                child: Text(
                  'Complete the audio to mark as completed',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            if (completed)
              Center(
                child: Text(
                  'Completed',
                  style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
