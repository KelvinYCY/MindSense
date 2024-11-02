import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedSession {
  final String id;
  final String sessionId;
  final String title;
  final String sessionType; // 'meditation', 'sleep_story', 'breathing', 'body_scan'
  final DateTime completedAt;
  final int duration;
  final String? imageUrl;

  CompletedSession({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.sessionType,
    required this.completedAt,
    required this.duration,
    this.imageUrl,
  });

  // Convert Firestore document to CompletedSession object
  factory CompletedSession.fromMap(Map<String, dynamic> map, String documentId) {
    return CompletedSession(
      id: documentId,
      sessionId: map['sessionId'] ?? '',
      title: map['title'] ?? 'Untitled Session',
      sessionType: map['sessionType'] ?? 'meditation',
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      duration: map['duration'] ?? 0,
      imageUrl: map['imageUrl'],
    );
  }

  // Convert CompletedSession object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'title': title,
      'sessionType': sessionType,
      'completedAt': Timestamp.fromDate(completedAt),
      'duration': duration,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  // Get formatted completion date
  String get formattedDate {
    return '${completedAt.day}/${completedAt.month}/${completedAt.year}';
  }

  // Get formatted duration
  String get formattedDuration {
    if (duration < 60) {
      return '$duration min';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  // Get session type display name
  String get sessionTypeDisplay {
    switch (sessionType) {
      case 'meditation':
        return 'Meditation';
      case 'sleep_story':
        return 'Sleep Story';
      case 'breathing':
        return 'Breathing Exercise';
      case 'body_scan':
        return 'Body Scan';
      default:
        return 'Session';
    }
  }

  // Helper method to create from document snapshot
  static CompletedSession fromDocument(DocumentSnapshot doc) {
    return CompletedSession.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  // Helper method to create a list from query snapshot
  static List<CompletedSession> listFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => fromDocument(doc)).toList();
  }
}

// Optional: Session Type Enum if you prefer type safety
enum SessionType {
  meditation,
  sleepStory,
  breathing,
  bodyScan;

  String get displayName {
    switch (this) {
      case SessionType.meditation:
        return 'Meditation';
      case SessionType.sleepStory:
        return 'Sleep Story';
      case SessionType.breathing:
        return 'Breathing Exercise';
      case SessionType.bodyScan:
        return 'Body Scan';
    }
  }

  String get storageKey {
    switch (this) {
      case SessionType.meditation:
        return 'meditation';
      case SessionType.sleepStory:
        return 'sleep_story';
      case SessionType.breathing:
        return 'breathing';
      case SessionType.bodyScan:
        return 'body_scan';
    }
  }
}
