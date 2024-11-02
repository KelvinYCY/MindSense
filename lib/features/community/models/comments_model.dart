import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String uid;  // Changed from userId
  final String name; // Changed from userName
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final List<String> likes;

  CommentModel({
    required this.id,
    required this.postId,
    required this.uid,
    required this.name,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    List<String>? likes,
  }) : this.likes = likes ?? [];

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? 'https://via.placeholder.com/150',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'uid': uid,
      'name': name,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? uid,
    String? name,
    String? userAvatar,
    String? content,
    DateTime? timestamp,
    List<String>? likes,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
    );
  }

  bool isLikedBy(String uid) {
    return likes.contains(uid);
  }

  CommentModel toggleLike(String uid) {
    final newLikes = List<String>.from(likes);
    if (isLikedBy(uid)) {
      newLikes.remove(uid);
    } else {
      newLikes.add(uid);
    }
    return copyWith(likes: newLikes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          postId == other.postId &&
          uid == other.uid &&
          name == other.name &&
          userAvatar == other.userAvatar &&
          content == other.content &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      postId.hashCode ^
      uid.hashCode ^
      name.hashCode ^
      userAvatar.hashCode ^
      content.hashCode ^
      timestamp.hashCode;

  @override
  String toString() {
    return 'CommentModel{id: $id, postId: $postId, uid: $uid, name: $name, content: $content, timestamp: $timestamp, likes: ${likes.length}}';
  }
}