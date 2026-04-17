import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/post_model.dart';
import '../models/user_profile_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/user_avatar.dart';
import 'create_post_screen.dart';
import 'reels_screen.dart';
import 'setup_username_screen.dart';
import 'user_profile_screen.dart';

enum _FeedMode { feed, reels }

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  UserProfile? _myProfile;
  bool _loadingProfile = true;
  String? _profileError;
  _FeedMode _mode = _FeedMode.feed;
  bool _reelsReady = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await FeedService.getMyProfile();
      if (!mounted) return;
      setState(() {
        _myProfile = profile;
        _loadingProfile = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      if (error.response?.statusCode == 404) {
        final createdProfile = await Navigator.push<UserProfile>(
          context,
          MaterialPageRoute(builder: (_) => const SetupUsernameScreen()),
        );
        if (!mounted) return;
        if (createdProfile != null) {
          setState(() {
            _myProfile = createdProfile;
            _loadingProfile = false;
          });
        } else {
          setState(() {
            _profileError = 'Kullanıcı profili oluşturulamadı.';
            _loadingProfile = false;
          });
        }
      } else {
        setState(() {
          _profileError = 'Cosmic Feed yüklenemedi.';
          _loadingProfile = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profileError = 'Cosmic Feed yüklenemedi.';
        _loadingProfile = false;
      });
    }
  }

  Future<void> _openCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _openSearch() async {
    if (_myProfile == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserSearchSheet(currentUserId: _myProfile!.userId),
    );
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == _FeedMode.feed ? _FeedMode.reels : _FeedMode.feed;
      if (_mode == _FeedMode.reels) {
        _reelsReady = true;
      }
    });
    if (_mode == _FeedMode.reels) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        backgroundColor: SpaceTheme.deepSpace,
        body: Center(
          child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple),
        ),
      );
    }

    if (_profileError != null || _myProfile == null) {
      return Scaffold(
        backgroundColor: SpaceTheme.deepSpace,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, color: Colors.white24, size: 60),
                const SizedBox(height: 16),
                Text(
                  _profileError ?? 'Cosmic Feed yüklenemedi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpaceTheme.nebulaPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: SpaceTheme.deepSpace,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cosmic Feed',
              style: TextStyle(
                color: SpaceTheme.stellarGold,
                fontWeight: FontWeight.w800,
                fontSize: 21,
              ),
            ),
            Text(
              _mode == _FeedMode.feed ? 'Topluluk akışı ve arama' : 'Odaklı reels akışı',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _mode.index,
          children: [
            _CommunityFeedView(
              currentUserId: _myProfile!.userId,
              onSearchTap: _openSearch,
              onCreateTap: _openCreate,
            ),
            _reelsReady
                ? ReelsScreen(
                    currentUserId: _myProfile!.userId,
                    loader: FeedService.getExplore,
                  )
                : const _ReelsLandingPlaceholder(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CentralModeButton(
        mode: _mode,
        onPressed: _toggleMode,
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0E1424).withValues(alpha: 0.96),
        elevation: 12,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Kullanıcı ara',
                onPressed: _openSearch,
                icon: const Icon(Icons.search_rounded, color: Colors.white),
              ),
              const SizedBox(width: 72),
              IconButton(
                tooltip: 'Yeni paylaşım',
                onPressed: _openCreate,
                icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReelsLandingPlaceholder extends StatelessWidget {
  const _ReelsLandingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_outline_rounded, size: 72, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Reels moda geçmek için ortadaki butonu kullan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _CentralModeButton extends StatelessWidget {
  final _FeedMode mode;
  final VoidCallback onPressed;

  const _CentralModeButton({required this.mode, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isFeed = mode == _FeedMode.feed;
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: isFeed ? SpaceTheme.nebulaPurple : SpaceTheme.stellarGold,
      foregroundColor: Colors.white,
      elevation: 10,
      icon: Icon(isFeed ? Icons.play_circle_fill_rounded : Icons.dynamic_feed_rounded),
      label: Text(isFeed ? 'Reels' : 'Akış'),
    );
  }
}

class _CommunityFeedView extends StatelessWidget {
  final int currentUserId;
  final VoidCallback onSearchTap;
  final VoidCallback onCreateTap;

  const _CommunityFeedView({
    required this.currentUserId,
    required this.onSearchTap,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _CommunityHeroCard(
            onSearchTap: onSearchTap,
            onCreateTap: onCreateTap,
          ),
        ),
        Expanded(
          child: _FeedList(
            loader: FeedService.getFeed,
            currentUserId: currentUserId,
          ),
        ),
      ],
    );
  }
}

class _CommunityHeroCard extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onCreateTap;

  const _CommunityHeroCard({required this.onSearchTap, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D2671), Color(0xFF6C2BD9), Color(0xFF0F2027)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [SpaceTheme.stellarGold.withValues(alpha: 0.95), Colors.white],
                  ),
                ),
                child: const Icon(Icons.groups_rounded, color: Color(0xFF101425)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topluluğu Keşfet',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'İçeriği tek akışta izle, kullanıcı ara ve tek dokunuşla takip et.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  icon: Icons.search_rounded,
                  label: 'Kullanıcı Ara',
                  onTap: onSearchTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionChip(
                  icon: Icons.add_photo_alternate_outlined,
                  label: 'Paylaş',
                  onTap: onCreateTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _FeedLoader = Future<FeedResponse> Function({int? cursor});

class _FeedList extends StatefulWidget {
  final _FeedLoader loader;
  final int currentUserId;

  const _FeedList({required this.loader, required this.currentUserId});

  @override
  State<_FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<_FeedList> {
  final List<Post> _posts = [];
  final _scrollController = ScrollController();
  bool _loading = true;
  bool _loadingMore = false;
  int? _nextCursor;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 420) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await widget.loader();
      if (!mounted) return;
      setState(() {
        _posts
          ..clear()
          ..addAll(result.posts);
        _nextCursor = result.nextCursor;
        _hasMore = result.hasMore;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Feed yüklenemedi.';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _nextCursor == null) return;
    setState(() => _loadingMore = true);
    try {
      final result = await widget.loader(cursor: _nextCursor);
      if (!mounted) return;
      setState(() {
        _posts.addAll(result.posts);
        _nextCursor = result.nextCursor;
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onPostUpdated(Post updated) {
    final idx = _posts.indexWhere((post) => post.id == updated.id);
    if (idx != -1 && mounted) {
      setState(() => _posts[idx] = updated);
    }
  }

  Future<void> _deletePost(Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpaceTheme.surfaceCard,
        title: const Text('Postu Sil', style: TextStyle(color: Colors.white)),
        content: const Text('Bu gönderiyi silmek istiyor musun?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FeedService.deletePost(post.id);
        if (mounted) setState(() => _posts.removeWhere((item) => item.id == post.id));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _load,
              child: const Text('Tekrar Dene', style: TextStyle(color: SpaceTheme.nebulaPurple)),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        color: SpaceTheme.nebulaPurple,
        backgroundColor: SpaceTheme.surfaceCard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
          children: const [
            Icon(Icons.auto_awesome_mosaic_rounded, size: 72, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Henüz içerik yok.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Kullanıcı ara, takip et veya ilk paylaşımını yap.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white30, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: SpaceTheme.nebulaPurple,
      backgroundColor: SpaceTheme.surfaceCard,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 110),
        itemCount: _posts.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: SpaceTheme.nebulaPurple),
              ),
            );
          }

          final post = _posts[index];
          return PostCard(
            post: post,
            currentUserId: widget.currentUserId,
            onPostUpdated: _onPostUpdated,
            onDelete: () => _deletePost(post),
            onProfileTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(
                  userId: post.userId,
                  currentUserId: widget.currentUserId,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserSearchSheet extends StatefulWidget {
  final int currentUserId;

  const _UserSearchSheet({required this.currentUserId});

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<UserProfile> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(value.trim());
    });
  }

  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await FeedService.searchUsers(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Kullanıcılar yüklenemedi.';
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollow(UserProfile profile) async {
    final shouldUnfollow = profile.isFollowing;
    setState(() {
      _results = _results
          .map((item) => item.userId == profile.userId
              ? item.copyWith(isFollowing: !shouldUnfollow)
              : item)
          .toList();
    });

    try {
      if (shouldUnfollow) {
        await FeedService.unfollowUser(profile.userId);
      } else {
        await FeedService.followUser(profile.userId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = _results
            .map((item) => item.userId == profile.userId
                ? item.copyWith(isFollowing: shouldUnfollow)
                : item)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.65,
      maxChildSize: 0.98,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D1321),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Kullanıcı ara',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: TextField(
                    controller: _controller,
                    onChanged: _onQueryChanged,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'username ya da görünen isim',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple),
                        )
                      : _error != null
                          ? Center(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.white54),
                              ),
                            )
                          : _controller.text.trim().length < 2
                              ? ListView(
                                  controller: scrollController,
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                  children: const [
                                    SizedBox(height: 16),
                                    Text(
                                      'En az 2 karakter yaz ve topluluğu keşfet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white54, height: 1.4),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  controller: scrollController,
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                                  itemBuilder: (context, index) {
                                    final profile = _results[index];
                                    final isOwn = profile.userId == widget.currentUserId;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                      ),
                                      child: ListTile(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => UserProfileScreen(
                                              userId: profile.userId,
                                              currentUserId: widget.currentUserId,
                                            ),
                                          ),
                                        ),
                                        leading: UserAvatar(
                                          username: profile.username,
                                          avatarUrl: profile.avatarUrl,
                                          radius: 22,
                                        ),
                                        title: Text(
                                          profile.displayedName,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                        ),
                                        subtitle: Text(
                                          '@${profile.username} · ${profile.followerCount} takipçi',
                                          style: const TextStyle(color: Colors.white54),
                                        ),
                                        trailing: isOwn
                                            ? const Text(
                                                'Sen',
                                                style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w600),
                                              )
                                            : TextButton(
                                                onPressed: () => _toggleFollow(profile),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: profile.isFollowing
                                                      ? Colors.white.withValues(alpha: 0.08)
                                                      : SpaceTheme.nebulaPurple,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                ),
                                                child: Text(profile.isFollowing ? 'Takip Ediliyor' : 'Takip Et'),
                                              ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemCount: _results.length,
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
