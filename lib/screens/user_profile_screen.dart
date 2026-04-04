import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../models/user_profile_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import '../widgets/user_avatar.dart';
import 'post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final int currentUserId;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.currentUserId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _profile;
  List<Post> _posts = [];
  bool _loading = true;
  bool _followLoading = false;
  int? _nextCursor;
  bool _hasMore = true;
  final _scrollController = ScrollController();

  bool get _isOwn => widget.userId == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMorePosts();
    }
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        FeedService.getUserProfile(widget.userId),
        FeedService.getUserPosts(widget.userId),
      ]);
      if (mounted) {
        final feed = results[1] as FeedResponse;
        setState(() {
          _profile = results[0] as UserProfile;
          _posts = feed.posts;
          _nextCursor = feed.nextCursor;
          _hasMore = feed.hasMore;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_hasMore || _nextCursor == null) return;
    try {
      final feed = await FeedService.getUserPosts(widget.userId, cursor: _nextCursor);
      if (mounted) {
        setState(() {
          _posts.addAll(feed.posts);
          _nextCursor = feed.nextCursor;
          _hasMore = feed.hasMore;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFollow() async {
    if (_profile == null || _followLoading) return;
    setState(() => _followLoading = true);
    try {
      if (_profile!.isFollowing) {
        await FeedService.unfollowUser(widget.userId);
        setState(() {
          _profile = _profile!.copyWith(
            isFollowing: false,
            followerCount: _profile!.followerCount - 1,
          );
        });
      } else {
        await FeedService.followUser(widget.userId);
        setState(() {
          _profile = _profile!.copyWith(
            isFollowing: true,
            followerCount: _profile!.followerCount + 1,
          );
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _followLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple))
          : _profile == null
              ? _buildError()
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(child: _buildHeader()),
                    _buildPostsGrid(),
                    if (_hasMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: SpaceTheme.deepSpace,
      pinned: true,
      title: Text(_profile?.username ?? '', style: const TextStyle(color: Colors.white)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader() {
    final profile = _profile!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                  username: profile.username,
                  avatarUrl: profile.avatarUrl,
                  radius: 36),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Paylaşım', value: profile.postCount),
                    _StatItem(label: 'Takipçi', value: profile.followerCount),
                    _StatItem(label: 'Takip', value: profile.followingCount),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.displayedName,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(profile.bio!,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
          if (!_isOwn) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _followLoading ? null : _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: profile.isFollowing
                      ? SpaceTheme.surfaceCardLight
                      : SpaceTheme.nebulaPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: _followLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        profile.isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (_posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text('Henüz paylaşım yok.',
                style: TextStyle(color: Colors.white38)),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = _posts[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(
                    post: post,
                    currentUserId: widget.currentUserId,
                  ),
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: SpaceTheme.surfaceCard),
                errorWidget: (_, __, ___) => Container(
                  color: SpaceTheme.surfaceCard,
                  child: const Icon(Icons.broken_image,
                      color: Colors.white24),
                ),
              ),
            );
          },
          childCount: _posts.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Text('Profil yüklenemedi.', style: TextStyle(color: Colors.white54)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value > 999 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
