import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/comments_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Changed return type to Stream<QuerySnapshot>
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>;

    final comment = CommentModel(
      id: '',
      postId: postId,
      uid: userId,
      name: userData['name'] ?? 'Anonymous',
      userAvatar: userData['profilePicture'] ?? 'https://via.placeholder.com/150',
      content: content,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(comment.toFirestore());

    // Update comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();

    // Update comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  Future<void> toggleLike(String postId, String commentId, String uid) async {
    final docRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final doc = await docRef.get();
    final likes = List<String>.from(doc.data()?['likes'] ?? []);

    if (likes.contains(uid)) {
      likes.remove(uid);
    } else {
      likes.add(uid);
    }

    await docRef.update({'likes': likes});
  }
}