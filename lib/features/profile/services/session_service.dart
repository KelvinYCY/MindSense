import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> markSessionComplete({
    required String sessionId,
    required String title,
    required String collectionName,
    required int duration,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // First, add to completed_sessions subcollection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_sessions')
          .add({
        'sessionId': sessionId,
        'title': title,
        'collectionName': collectionName,
        'completedAt': Timestamp.now(),
        'duration': duration,
      });

      // Then, update user stats
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(
          _firestore.collection('users').doc(userId)
        );
        
        if (!userDoc.exists) return;

        final userData = userDoc.data()!;
        final currentStats = {
          'totalSessions': userData['totalSessions'] ?? 0,
          'totalMinutes': userData['totalMinutes'] ?? 0,
          'streakCount': userData['streakCount'] ?? 0,
          'lastSessionDate': userData['lastSessionDate'],
        };

        final now = DateTime.now();
        final lastSession = currentStats['lastSessionDate'] != null 
            ? (currentStats['lastSessionDate'] as Timestamp).toDate()
            : null;
        
        // Calculate new streak
        int newStreak = currentStats['streakCount'];
        if (lastSession == null || !isSameDay(lastSession, now)) {
          if (lastSession != null && isConsecutiveDay(lastSession, now)) {
            newStreak += 1;
          } else {
            newStreak = 1;
          }
        }

        // Update user document
        transaction.update(
          _firestore.collection('users').doc(userId),
          {
            'totalSessions': FieldValue.increment(1),
            'totalMinutes': FieldValue.increment(duration),
            'streakCount': newStreak,
            'lastSessionDate': Timestamp.now(),
          },
        );
      });
    } catch (e) {
      debugPrint('Error marking session complete: $e');
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool isConsecutiveDay(DateTime lastDate, DateTime currentDate) {
    final difference = currentDate.difference(lastDate).inDays;
    return difference == 1;
  }

  Future<bool> isSessionCompleted(String sessionId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_sessions')
          .where('sessionId', isEqualTo: sessionId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking session completion: $e');
      return false;
    }
  }
}