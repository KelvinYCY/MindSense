import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'posts';

  Future<String> createPost(PostModel post) async {
    try {
      final docRef = await _firestore.collection(_collection).add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating post: $e');
      throw Exception('Failed to create post');
    }
  }

  Future<QueryResult> getPosts({
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      return QueryResult(
        posts: querySnapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList(),
        lastDocument: querySnapshot.docs.isNotEmpty
            ? querySnapshot.docs.last
            : null,
      );
    } catch (e) {
      debugPrint('Error getting posts: $e');
      throw Exception('Failed to get posts');
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_collection).doc(postId);
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('Post not found');
        }

        final postData = postDoc.data() as Map<String, dynamic>;
        final likes = List<String>.from(postData['likes'] ?? []);
        
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }

        transaction.update(postRef, {'likes': likes});
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
      throw Exception('Failed to toggle like');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final postRef = _firestore.collection(_collection).doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final commentsSnapshot = await postRef
            .collection('comments')
            .get();

        for (var doc in commentsSnapshot.docs) {
          transaction.delete(doc.reference);
        }

        transaction.delete(postRef);
      });
    } catch (e) {
      debugPrint('Error deleting post: $e');
      throw Exception('Failed to delete post');
    }
  }

  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection(_collection)
        .where('uid', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList());
  }

  Stream<PostModel?> getPost(String postId) {
    return _firestore
        .collection(_collection)
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists ? PostModel.fromFirestore(doc) : null);
  }
}

class QueryResult {
  final List<PostModel> posts;
  final DocumentSnapshot? lastDocument;

  QueryResult({
    required this.posts,
    this.lastDocument,
  });
}