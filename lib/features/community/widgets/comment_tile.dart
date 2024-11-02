// File: lib/widgets/comment_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/comments_model.dart';
import '../../../model/user_model.dart';
import '../services/comments_service.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isPostAuthor;
  final VoidCallback? onDelete;

  const CommentTile({
    Key? key,
    required this.comment,
    this.isPostAuthor = false,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserModel?>(context);
    final commentService = Provider.of<CommentService>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(comment.userAvatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isPostAuthor) _buildAuthorBadge(),
                    const Spacer(),
                    _buildPopupMenu(context, currentUser),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        if (currentUser != null) {
                          commentService.toggleLike(comment.postId, comment.id, currentUser.uid);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please log in to like comments')),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            comment.isLikedBy(currentUser?.uid ?? '') ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: comment.isLikedBy(currentUser?.uid ?? '') ? Colors.red : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likes.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Author',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, UserModel? currentUser) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (value) {
        if (value == 'delete' && comment.uid == currentUser?.uid) {
          onDelete?.call();
        } else if (value == 'report') {
          // TODO: Implement report functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report functionality coming soon')),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (comment.uid == currentUser?.uid)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
        const PopupMenuItem<String>(
          value: 'report',
          child: Text('Report'),
        ),
      ],
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