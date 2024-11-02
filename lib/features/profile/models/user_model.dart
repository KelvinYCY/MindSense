import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime lastLogin;
  final int postCount;
  final bool profileCompleted;
  // New fields for session tracking
  final int totalSessions;
  final int totalMinutes;
  final int streakCount;
  final DateTime? lastSessionDate;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.lastLogin,
    required this.postCount,
    required this.profileCompleted,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.streakCount = 0,
    this.lastSessionDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: (map['lastLogin'] as Timestamp).toDate(),
      postCount: map['postCount'] ?? 0,
      profileCompleted: map['profileCompleted'] ?? false,
      totalSessions: map['totalSessions'] ?? 0,
      totalMinutes: map['totalMinutes'] ?? 0,
      streakCount: map['streakCount'] ?? 0,
      lastSessionDate: map['lastSessionDate'] != null 
          ? (map['lastSessionDate'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'postCount': postCount,
      'profileCompleted': profileCompleted,
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'streakCount': streakCount,
      'lastSessionDate': lastSessionDate,
    };
  }
}