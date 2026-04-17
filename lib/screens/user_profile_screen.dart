import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post_model.dart';
import '../models/user_profile_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import '../widgets/user_avatar.dart';
import 'messages_screen.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  UserProfile? _profile;
  List<Post> _posts = [];
  bool _loading = true;
  bool _followLoading = false;
  bool _avatarLoading = false;
  int? _nextCursor;
  bool _hasMore = true;

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _loadMorePosts();
    }
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        FeedService.getUserProfile(widget.userId),
        FeedService.getUserPosts(widget.userId),
      ]);
      if (!mounted) return;
      final feed = results[1] as FeedResponse;
      setState(() {
        _profile = results[0] as UserProfile;
        _posts = feed.posts;
        _nextCursor = feed.nextCursor;
        _hasMore = feed.hasMore;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_hasMore || _nextCursor == null) return;
    try {
      final feed = await FeedService.getUserPosts(widget.userId, cursor: _nextCursor);
      if (!mounted) return;
      setState(() {
        _posts.addAll(feed.posts);
        _nextCursor = feed.nextCursor;
        _hasMore = feed.hasMore;
      });
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

  Future<void> _openMessages() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessagesScreen(
          currentUserId: widget.currentUserId,
          initialUserId: widget.userId,
        ),
      ),
    );
  }

  Future<void> _updateAvatar() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (file == null) return;

    setState(() => _avatarLoading = true);
    try {
      final updated = await FeedService.uploadAvatar(File(file.path));
      if (!mounted) return;
      setState(() => _profile = updated);
    } catch (_) {}
    if (mounted) setState(() => _avatarLoading = false);
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
      actions: [
        if (_isOwn)
          IconButton(
            tooltip: 'Profil fotoğrafı güncelle',
            icon: _avatarLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.photo_camera_outlined, color: Colors.white),
            onPressed: _avatarLoading ? null : _updateAvatar,
          )
        else
          IconButton(
            tooltip: 'Mesaj gönder',
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
            onPressed: _openMessages,
          ),
        const SizedBox(width: 4),
      ],
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
              UserAvatar(username: profile.username, avatarUrl: profile.avatarUrl, radius: 36),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(profile.bio!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
          if (_isOwn) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _avatarLoading ? null : _updateAvatar,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Profil Fotoğrafını Güncelle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _followLoading ? null : _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: profile.isFollowing ? SpaceTheme.surfaceCardLight : SpaceTheme.nebulaPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _followLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            profile.isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openMessages,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Mesaj'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Takip ederek akışta öncelik kazanır, mesaj atarak doğrudan iletişim kurarsın.',
              style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
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
            child: Text('Henüz paylaşım yok.', style: TextStyle(color: Colors.white38)),
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
                placeholder: (context, url) => Container(color: SpaceTheme.surfaceCard),
                errorWidget: (context, url, error) => Container(
                  color: SpaceTheme.surfaceCard,
                  child: const Icon(Icons.broken_image, color: Colors.white24),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
