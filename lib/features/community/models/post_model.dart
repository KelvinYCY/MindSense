import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PostModel {
  final String id;
  final String uid;
  final String name;
  final String userAvatar;
  final String content;
  final String? imageUrl;
  final int? meditationMinutes;
  final DateTime timestamp;
  final List<String> likes;
  final int commentCount;

  bool get hasMeditationData => meditationMinutes != null;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  String get timeAgo => _getTimeAgo(timestamp);

  const PostModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.userAvatar,
    required this.content,
    this.imageUrl,
    this.meditationMinutes,
    required this.timestamp,
    List<String>? likes,
    this.commentCount = 0,
  }) : this.likes = likes ?? const [];

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? 'https://via.placeholder.com/150',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      meditationMinutes: data['meditationMinutes'],
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  factory PostModel.create({
    required String uid,
    required String name,
    required String userAvatar,
    required String content,
    String? imageUrl,
    int? meditationMinutes,
  }) {
    return PostModel(
      id: '',
      uid: uid,
      name: name,
      userAvatar: userAvatar,
      content: content,
      imageUrl: imageUrl,
      meditationMinutes: meditationMinutes,
      timestamp: DateTime.now(),
      likes: [],
      commentCount: 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'userAvatar': userAvatar,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (meditationMinutes != null) 'meditationMinutes': meditationMinutes,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': likes,
      'commentCount': commentCount,
    };
  }

  bool isLikedBy(String userId) => likes.contains(userId);

  PostModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? userAvatar,
    String? content,
    String? imageUrl,
    int? meditationMinutes,
    DateTime? timestamp,
    List<String>? likes,
    int? commentCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  PostModel toggleLike(String userId) {
    final newLikes = List<String>.from(likes);
    if (isLikedBy(userId)) {
      newLikes.remove(userId);
    } else {
      newLikes.add(userId);
    }
    return copyWith(likes: newLikes);
  }

  PostModel incrementComments() {
    return copyWith(commentCount: commentCount + 1);
  }

  PostModel decrementComments() {
    return copyWith(commentCount: max(0, commentCount - 1));
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM d, y').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uid == other.uid &&
          name == other.name &&
          userAvatar == other.userAvatar &&
          content == other.content &&
          imageUrl == other.imageUrl &&
          meditationMinutes == other.meditationMinutes &&
          timestamp == other.timestamp &&
          likes == other.likes &&
          commentCount == other.commentCount;

  @override
  int get hashCode =>
      id.hashCode ^
      uid.hashCode ^
      name.hashCode ^
      userAvatar.hashCode ^
      content.hashCode ^
      imageUrl.hashCode ^
      meditationMinutes.hashCode ^
      timestamp.hashCode ^
      likes.hashCode ^
      commentCount.hashCode;

  @override
  String toString() =>
      'PostModel(id: $id, uid: $uid, name: $name, content: $content, likes: ${likes.length}, comments: $commentCount)';
}

