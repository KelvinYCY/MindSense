import 'package:flutter/material.dart';

class CourseTile extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final String audioUrl;
  final String imageUrl;
  final String level;
  final String tags;
  final VoidCallback onTap;

  const CourseTile({
    super.key,
    required this.title,
    required this.description,
    required this.duration,
    required this.audioUrl,
    required this.imageUrl,
    required this.level,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed 500x500 Image
            SizedBox(
              width: 500,
              height: 500,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
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
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Duration: $duration',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4.0),
                  Text('Level: $level'),
                  Text('Tags: $tags'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
