import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import '../widgets/comments_bottom_sheet.dart';
import '../widgets/user_avatar.dart';
import 'user_profile_screen.dart';

class ReelsScreen extends StatefulWidget {
  final int currentUserId;
  final Future<FeedResponse> Function({int? cursor}) loader;

  const ReelsScreen({
    super.key,
    required this.currentUserId,
    required this.loader,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final _pageController = PageController();
  final List<Post> _posts = [];
  int? _nextCursor;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  int _currentIndex = 0;

  // userId → isFollowing (null = state not yet fetched)
  final Map<int, bool> _followStates = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _load();
    _pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentIndex) {
      setState(() => _currentIndex = page);
      _prefetchFollowState(page);
    }
    if (page >= _posts.length - 3) _loadMore();
  }

  Future<void> _load() async {
    try {
      final result = await widget.loader();
      if (mounted) {
        setState(() {
          _posts.addAll(result.posts);
          _nextCursor = result.nextCursor;
          _hasMore = result.hasMore;
          _loading = false;
        });
        _prefetchFollowState(0);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await widget.loader(cursor: _nextCursor);
      if (mounted) {
        setState(() {
          _posts.addAll(result.posts);
          _nextCursor = result.nextCursor;
          _hasMore = result.hasMore;
          _loadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _prefetchFollowState(int pageIndex) async {
    if (pageIndex >= _posts.length) return;
    final post = _posts[pageIndex];
    if (post.userId == widget.currentUserId) return;
    if (_followStates.containsKey(post.userId)) return;

    try {
      final profile = await FeedService.getUserProfile(post.userId);
      if (mounted) {
        setState(() => _followStates[post.userId] = profile.isFollowing);
      }
    } catch (_) {}
  }

  void _updatePost(Post updated) {
    final idx = _posts.indexWhere((p) => p.id == updated.id);
    if (idx != -1 && mounted) setState(() => _posts[idx] = updated);
  }

  Future<void> _toggleFollow(int userId) async {
    final wasFollowing = _followStates[userId] ?? false;
    setState(() => _followStates[userId] = !wasFollowing);
    try {
      if (wasFollowing) {
        await FeedService.unfollowUser(userId);
      } else {
        await FeedService.followUser(userId);
      }
    } catch (_) {
      if (mounted) setState(() => _followStates[userId] = wasFollowing);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple),
      );
    }
    if (_posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('Henüz içerik yok.',
                style: TextStyle(color: Colors.white54, fontSize: 16)),
            SizedBox(height: 8),
            Text('Birini takip et veya keşfet!',
                style: TextStyle(color: Colors.white30, fontSize: 13)),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _posts.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _posts.length) {
          return const Center(
            child: CircularProgressIndicator(
                color: SpaceTheme.nebulaPurple, strokeWidth: 2),
          );
        }
        final post = _posts[index];
        final isOwn = post.userId == widget.currentUserId;
        return _ReelPage(
          post: post,
          currentUserId: widget.currentUserId,
          isOwn: isOwn,
          followState: isOwn ? null : _followStates[post.userId],
          onPostUpdated: _updatePost,
          onFollowTap: isOwn ? null : () => _toggleFollow(post.userId),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single reel page
// ---------------------------------------------------------------------------

class _ReelPage extends StatefulWidget {
  final Post post;
  final int currentUserId;
  final bool isOwn;
  // null = loading state (show shimmer), true/false = known state
  final bool? followState;
  final ValueChanged<Post> onPostUpdated;
  final VoidCallback? onFollowTap;

  const _ReelPage({
    required this.post,
    required this.currentUserId,
    required this.isOwn,
    required this.followState,
    required this.onPostUpdated,
    required this.onFollowTap,
  });

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage>
    with SingleTickerProviderStateMixin {
  late Post _post;
  late AnimationController _heartController;
  late Animation<double> _heartAnim;
  bool _showHeart = false;
  bool _captionExpanded = false;

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
    ]).animate(
        CurvedAnimation(parent: _heartController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_ReelPage old) {
    super.didUpdateWidget(old);
    if (old.post.id != widget.post.id ||
        old.post.isLikedByMe != widget.post.isLikedByMe ||
        old.post.likeCount != widget.post.likeCount ||
        old.post.commentCount != widget.post.commentCount) {
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
    setState(() {
      _post = _post.copyWith(
        isLikedByMe: !wasLiked,
        likeCount: wasLiked ? _post.likeCount - 1 : _post.likeCount + 1,
      );
    });
    widget.onPostUpdated(_post);
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
        widget.onPostUpdated(_post);
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
      widget.onPostUpdated(_post);
    }
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: _post.userId,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-screen image ───────────────────────────────────────────
          CachedNetworkImage(
            imageUrl: _post.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.black),
            errorWidget: (_, __, ___) => Container(
              color: Colors.black,
              child: const Center(
                  child: Icon(Icons.broken_image,
                      color: Colors.white24, size: 64)),
            ),
          ),

          // ── Top gradient (status bar readability) ──────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment(0, 0.25),
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),

          // ── Bottom gradient (text readability) ─────────────────────────
          const Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 280,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SizedBox.expand(),
              ),
            ),
          ),

          // ── Double-tap heart ───────────────────────────────────────────
          if (_showHeart)
            Center(
              child: AnimatedBuilder(
                animation: _heartAnim,
                builder: (_, __) => Transform.scale(
                  scale: _heartAnim.value,
                  child: const Icon(Icons.favorite,
                      color: Colors.white, size: 100),
                ),
              ),
            ),

          // ── Right-side action column ───────────────────────────────────
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                // Avatar + follow badge
                _AvatarWithFollow(
                  post: _post,
                  isOwn: widget.isOwn,
                  followState: widget.followState,
                  onAvatarTap: _goToProfile,
                  onFollowTap: widget.onFollowTap,
                ),
                const SizedBox(height: 28),

                // Like
                _SideButton(
                  icon: _post.isLikedByMe
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:
                      _post.isLikedByMe ? Colors.redAccent : Colors.white,
                  label: _post.likeCount > 0
                      ? _fmt(_post.likeCount)
                      : null,
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 20),

                // Comment
                _SideButton(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.white,
                  label: _post.commentCount > 0
                      ? _fmt(_post.commentCount)
                      : null,
                  onTap: _openComments,
                ),
              ],
            ),
          ),

          // ── Bottom-left: user info + title + caption ───────────────────
          Positioned(
            left: 16,
            right: 80,
            bottom: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _goToProfile,
                  child: Text(
                    '@${_post.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _post.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                  ),
                ),
                if (_post.caption != null && _post.caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _captionExpanded = !_captionExpanded),
                    child: Text(
                      _post.caption!,
                      maxLines: _captionExpanded ? null : 2,
                      overflow: _captionExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ---------------------------------------------------------------------------
// Avatar with follow badge
// ---------------------------------------------------------------------------

class _AvatarWithFollow extends StatelessWidget {
  final Post post;
  final bool isOwn;
  final bool? followState; // null = loading
  final VoidCallback onAvatarTap;
  final VoidCallback? onFollowTap;

  const _AvatarWithFollow({
    required this.post,
    required this.isOwn,
    required this.followState,
    required this.onAvatarTap,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: UserAvatar(
              username: post.username,
              avatarUrl: post.avatarUrl,
              radius: 24,
            ),
          ),
        ),
        if (!isOwn)
          Positioned(
            bottom: -10,
            child: GestureDetector(
              onTap: onFollowTap,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: (followState == true)
                      ? Colors.white24
                      : SpaceTheme.nebulaPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: followState == null
                    ? const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: Colors.white),
                      )
                    : Icon(
                        followState! ? Icons.check : Icons.add,
                        size: 13,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Right-side icon + count button
// ---------------------------------------------------------------------------

class _SideButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback onTap;

  const _SideButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 34,
              shadows: const [Shadow(blurRadius: 8, color: Colors.black54)]),
          if (label != null) ...[
            const SizedBox(height: 3),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
