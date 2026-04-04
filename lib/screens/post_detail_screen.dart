import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import '../widgets/user_avatar.dart';
import '../widgets/comments_bottom_sheet.dart';
import 'user_profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final int currentUserId;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _toggleLike() async {
    final wasLiked = _post.isLikedByMe;
    setState(() {
      _post = _post.copyWith(
        isLikedByMe: !wasLiked,
        likeCount: wasLiked ? _post.likeCount - 1 : _post.likeCount + 1,
      );
    });
    try {
      if (wasLiked) {
        await FeedService.unlikePost(_post.id);
      } else {
        await FeedService.likePost(_post.id);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _post = _post.copyWith(
            isLikedByMe: wasLiked,
            likeCount: wasLiked ? _post.likeCount + 1 : _post.likeCount - 1,
          );
        });
      }
    }
  }

  Future<void> _openComments() async {
    final delta = await CommentsBottomSheet.show(
      context,
      postId: _post.id,
      currentUserId: widget.currentUserId,
    );
    if (delta != 0 && mounted) {
      setState(() {
        _post = _post.copyWith(commentCount: _post.commentCount + delta);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      appBar: AppBar(
        backgroundColor: SpaceTheme.deepSpace,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context, _post),
        ),
        title: const Text('Gönderi'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(
                      userId: _post.userId,
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    UserAvatar(
                        username: _post.username,
                        avatarUrl: _post.avatarUrl,
                        radius: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_post.authorName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        Text('@${_post.username}  ·  ${_post.timeAgo}',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Image
            AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: _post.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: SpaceTheme.surfaceCard),
                errorWidget: (_, __, ___) => Container(
                  color: SpaceTheme.surfaceCard,
                  child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white24, size: 48)),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _post.isLikedByMe
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _post.isLikedByMe
                          ? Colors.redAccent
                          : Colors.white54,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text(
                    '${_post.likeCount}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Colors.white54),
                    onPressed: _openComments,
                  ),
                  Text(
                    '${_post.commentCount}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Title + caption
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _post.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  if (_post.caption != null && _post.caption!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _post.caption!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
