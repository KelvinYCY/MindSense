import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import './create_post_sheet.dart';
import './comments_sheet.dart';
import 'dart:async';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final PostService _postService = PostService();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  bool _hasMore = true;
  List<PostModel> _posts = [];
  DocumentSnapshot? _lastDocument;
  static const int _postsPerPage = 10;
  
  StreamSubscription<QuerySnapshot>? _postsSubscription;

  @override
  void initState() {
    super.initState();
    _setupPostsListener();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postsSubscription?.cancel();
    super.dispose();
  }

  void _setupPostsListener() {
    final postsQuery = _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(_postsPerPage);

    _postsSubscription = postsQuery.snapshots().listen(
      (snapshot) {
        if (mounted) {
          setState(() {
            _posts = snapshot.docs
                .map((doc) => PostModel.fromFirestore(doc))
                .toList();
            _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
            _hasMore = snapshot.docs.length >= _postsPerPage;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          _showErrorSnackBar('Error loading posts');
        }
      },
    );
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _postService.getPosts(
        startAfter: _lastDocument,
        limit: _postsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _posts = [..._posts, ...result.posts];
        _lastDocument = result.lastDocument;
        _hasMore = result.posts.length >= _postsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error loading more posts');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.95) {
      _loadMorePosts();
    }
  }

  Future<void> _likePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      _showErrorSnackBar('Please sign in to like posts');
      return;
    }

    try {
      await _postService.toggleLike(postId, user.uid);
    } catch (e) {
      _showErrorSnackBar('Error updating like');
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _postService.deletePost(postId);
        _showSuccessSnackBar('Post deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting post');
      }
    }
  }

  void _showComments(PostModel post) {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => CommentsSheet(
        postId: post.id,
        postUserId: post.uid,
      ),
    );
  }

  Future<void> _createNewPost(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      _showErrorSnackBar('Please sign in to create a post');
      return;
    }

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const CreatePostSheet(),
      );
    } catch (e) {
      _showErrorSnackBar('Error creating post');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildEmptyState() {
    final user = _auth.currentUser;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, 
            size: 64, 
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your experience!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (user != null)
            ElevatedButton.icon(
              onPressed: () => _createNewPost(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_isLoading) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindSense Community'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.add, size: 28),
              onPressed: () => _createNewPost(context),
              tooltip: 'Create Post',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _postsSubscription?.cancel();
          _setupPostsListener();
        },
        child: _posts.isEmpty && !_isLoading
            ? _buildEmptyState()
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    return _buildLoadingIndicator();
                  }
                  
                  final post = _posts[index];
                  return PostCard(
                    key: ValueKey(post.id),
                    post: post,
                    onDelete: () => _deletePost(post.id),
                    onLike: () => _likePost(post.id),
                    onComment: () => _showComments(post),
                    onShare: () => _showErrorSnackBar('Sharing coming soon!'),
                  );
                },
              ),
      ),
      floatingActionButton: user != null
          ? FloatingActionButton(
              onPressed: () => _createNewPost(context),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
              tooltip: 'Create Post',
            )
          : null,
    );
  }
}
