import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import 'user_avatar.dart';
import 'comments_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final int currentUserId;
  final VoidCallback? onProfileTap;
  final ValueChanged<Post>? onPostUpdated;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    this.onProfileTap,
    this.onPostUpdated,
    this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late Post _post;
  late AnimationController _heartController;
  late Animation<double> _heartAnim;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(PostCard old) {
    super.didUpdateWidget(old);
    if (old.post.id != widget.post.id ||
        old.post.isLikedByMe != widget.post.isLikedByMe ||
        old.post.likeCount != widget.post.likeCount) {
      setState(() => _post = widget.post);
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final wasLiked = _post.isLikedByMe;
    // Optimistic update
    setState(() {
      _post = _post.copyWith(
        isLikedByMe: !wasLiked,
        likeCount: wasLiked ? _post.likeCount - 1 : _post.likeCount + 1,
      );
    });
    widget.onPostUpdated?.call(_post);

    try {
      if (wasLiked) {
        await FeedService.unlikePost(_post.id);
      } else {
        await FeedService.likePost(_post.id);
      }
    } catch (_) {
      // Revert on error
      if (mounted) {
        setState(() {
          _post = _post.copyWith(
            isLikedByMe: wasLiked,
            likeCount: wasLiked ? _post.likeCount + 1 : _post.likeCount - 1,
          );
        });
        widget.onPostUpdated?.call(_post);
      }
    }
  }

  void _onDoubleTap() {
    if (!_post.isLikedByMe) _toggleLike();
    setState(() => _showHeart = true);
    _heartController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeart = false);
    });
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
      widget.onPostUpdated?.call(_post);
    }
  }

  void _showMenu() {
    final isOwn = _post.userId == widget.currentUserId;
    showModalBottomSheet(
      context: context,
      backgroundColor: SpaceTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwn)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Postu Sil', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
              ),
            if (!isOwn)
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.orange),
                title: const Text('Bildir', style: TextStyle(color: Colors.orange)),
                onTap: () => Navigator.pop(context),
              ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.white54),
              title: const Text('Kapat', style: TextStyle(color: Colors.white54)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SpaceTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: UserAvatar(
                    username: _post.username,
                    avatarUrl: _post.avatarUrl,
                    radius: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _post.authorName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        Text(
                          '@${_post.username}  ·  ${_post.timeAgo}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
                  onPressed: _showMenu,
                ),
              ],
            ),
          ),

          // Image with double-tap like
          GestureDetector(
            onDoubleTap: _onDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: _post.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: SpaceTheme.surfaceCardLight,
                      child: const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: SpaceTheme.nebulaPurple),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: SpaceTheme.surfaceCardLight,
                      child: const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white24, size: 48)),
                    ),
                  ),
                ),
                if (_showHeart)
                  AnimatedBuilder(
                    animation: _heartAnim,
                    builder: (_, __) => Transform.scale(
                      scale: _heartAnim.value,
                      child: const Icon(Icons.favorite,
                          color: Colors.white, size: 80),
                    ),
                  ),
              ],
            ),
          ),

          // Action bar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Row(
              children: [
                _ActionBtn(
                  icon: _post.isLikedByMe
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _post.isLikedByMe
                      ? Colors.redAccent
                      : Colors.white54,
                  label: _post.likeCount > 0 ? '${_post.likeCount}' : '',
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.white54,
                  label:
                      _post.commentCount > 0 ? '${_post.commentCount}' : '',
                  onTap: _openComments,
                ),
                const Spacer(),
              ],
            ),
          ),

          // Title + caption
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _post.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                if (_post.caption != null && _post.caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _ExpandableCaption(caption: _post.caption!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpandableCaption extends StatefulWidget {
  final String caption;
  const _ExpandableCaption({required this.caption});

  @override
  State<_ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<_ExpandableCaption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Text(
        widget.caption,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
        maxLines: _expanded ? null : 2,
        overflow:
            _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    );
  }
}
