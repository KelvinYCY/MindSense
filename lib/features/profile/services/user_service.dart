import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await getUserData(user.uid);
      }
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    }
    return null;
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (userSnapshot.exists) {
        return UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
    return null;
  }

  // Save user data
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Update meditation session
  Future<void> updateMeditationSession(String uid, int duration, String sessionType) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final currentData = userDoc.data()!;
        
        // Get current values or default to 0
        final totalSessions = (currentData['totalSessions'] ?? 0) + 1;
        final totalMinutes = (currentData['totalMinutes'] ?? 0) + duration;
        
        // Calculate streak
        final now = DateTime.now();
        final lastSessionDate = currentData['lastSessionDate'] != null 
            ? (currentData['lastSessionDate'] as Timestamp).toDate() 
            : null;
        
        int currentStreak = currentData['streakCount'] ?? 0;
        
        if (lastSessionDate == null) {
          currentStreak = 1;
        } else {
          final difference = now.difference(lastSessionDate).inDays;
          if (difference == 0) {
            // Same day, keep streak
          } else if (difference == 1) {
            // Consecutive day, increase streak
            currentStreak += 1;
          } else {
            // Streak broken
            currentStreak = 1;
          }
        }

        // Add completed session
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('completed_sessions')
            .add({
              'sessionType': sessionType,
              'duration': duration,
              'completedAt': now,
            });

        // Update user stats
        transaction.update(userRef, {
          'totalSessions': totalSessions,
          'totalMinutes': totalMinutes,
          'streakCount': currentStreak,
          'lastSessionDate': now,
        });
      });
    } catch (e) {
      print('Error updating meditation session: $e');
      rethrow;
    }
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data()!;
      
      return {
        'totalMinutes': userData['totalMinutes'] ?? 0,
        'totalSessions': userData['totalSessions'] ?? 0,
        'streakCount': userData['streakCount'] ?? 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      rethrow;
    }
  }

  // Get recent sessions
  Future<List<Map<String, dynamic>>> getRecentSessions(String uid, {int limit = 10}) async {
    try {
      final sessionsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('completed_sessions')
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return sessionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'sessionType': data['sessionType'],
          'duration': data['duration'],
          'completedAt': (data['completedAt'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Error getting recent sessions: $e');
      return [];
    }
  }

  // Update user settings
  Future<void> updateSettings(String uid, Map<String, dynamic> settings) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'settings': settings});
    } catch (e) {
      print('Error updating settings: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUserAccount(String uid) async {
    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(uid).delete();
      
      // Delete user authentication
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print('Error deleting user account: $e');
      rethrow;
    }
  }
}