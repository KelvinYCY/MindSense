import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onDelete;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    Key? key,
    required this.post,
    this.onDelete,
    this.onLike,
    this.onComment,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, currentUser, theme),
          _buildContent(theme),
          if (post.imageUrl != null) _buildImage(context),
          if (post.meditationMinutes != null && post.meditationMinutes! > 0)
            _buildMeditationChip(theme),
          _buildInteractionBar(context, currentUser, theme),
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? currentUser, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTimestamp(post.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildMenuButton(context, currentUser),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to user profile
      },
      child: Hero(
        tag: 'avatar_${post.uid}',
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
          backgroundImage: CachedNetworkImageProvider(post.userAvatar),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, User? currentUser) {
    final isAuthor = currentUser?.uid == post.uid;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            onDelete?.call();
            break;
          case 'report':
            _showReportDialog(context);
            break;
        }
      },
      itemBuilder: (context) => [
        if (isAuthor)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                const SizedBox(width: 12),
                Text(
                  'Delete',
                  style: TextStyle(color: Colors.red[400]),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag_outlined, color: Colors.grey[700], size: 20),
              const SizedBox(width: 12),
              const Text('Report'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (post.content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        post.content,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Hero(
        tag: 'post_image_${post.id}',
        child: SizedBox(
          width: double.infinity,
          height: 300,
          child: CachedNetworkImage(
            imageUrl: post.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationChip(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Chip(
        avatar: const Icon(Icons.timer_outlined, size: 18),
        label: Text('${post.meditationMinutes} min meditation'),
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(color: theme.primaryColor),
      ),
    );
  }

  Widget _buildInteractionBar(BuildContext context, User? currentUser, ThemeData theme) {
    final isLiked = currentUser != null && post.isLikedBy(currentUser.uid);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildIconButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: '${post.likes.length}',
            onPressed: onLike,
            color: isLiked ? Colors.red : null,
          ),
          _buildIconButton(
            icon: Icons.chat_bubble_outline,
            label: '${post.commentCount}',
            onPressed: onComment,
          ),
          _buildIconButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onPressed: onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        '${post.likes.length} likes · ${post.commentCount} comments',
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          extendBodyBehindAppBar: true,
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Hero(
                tag: 'post_image_${post.id}',
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 16),
            ...['Inappropriate content', 'Spam', 'Harassment', 'Other']
                .map((reason) => ListTile(
                      title: Text(reason),
                      onTap: () {
                        Navigator.pop(context);
                        _submitReport(context, reason);
                      },
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _submitReport(BuildContext context, String reason) {
    // TODO: Implement report submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Thank you for reporting. We will review this post.',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat.yMMMd().format(timestamp);
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
}