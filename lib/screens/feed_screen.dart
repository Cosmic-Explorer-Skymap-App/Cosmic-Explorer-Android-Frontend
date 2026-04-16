import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_profile_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'reels_screen.dart';
import 'user_profile_screen.dart';
import 'setup_username_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _myProfile;
  bool _profileChecked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Rebuild when tab changes so FAB and physics update reactively
    _tabController.addListener(() => setState(() {}));
    _checkProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkProfile() async {
    try {
      final profile = await FeedService.getMyProfile();
      if (mounted) setState(() => _myProfile = profile);
    } on DioException catch (e) {
      // Only redirect to setup when the server explicitly says "no profile" (404).
      // For network errors or other failures, stay on the loading screen so the
      // user can retry rather than being sent to the setup flow incorrectly.
      if (e.response?.statusCode == 404 && mounted) {
        final result = await Navigator.push<UserProfile>(
          context,
          MaterialPageRoute(builder: (_) => const SetupUsernameScreen()),
        );
        if (result != null && mounted) {
          setState(() => _myProfile = result);
        }
      }
    }
    if (mounted) setState(() => _profileChecked = true);
  }

  Future<void> _openCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    if (result == true) {
      // Refresh both tabs
      setState(() {}); // triggers rebuild → _FeedList reinits
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_profileChecked) {
      return const Scaffold(
        backgroundColor: SpaceTheme.deepSpace,
        body: Center(child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple)),
      );
    }

    final isReels = _tabController.index == 2;

    return Scaffold(
      backgroundColor: SpaceTheme.deepSpace,
      extendBodyBehindAppBar: isReels,
      appBar: AppBar(
        backgroundColor:
            isReels ? Colors.transparent : SpaceTheme.deepSpace,
        elevation: 0,
        title: isReels
            ? null
            : const Text(
                '✦ Cosmic Feed',
                style: TextStyle(
                    color: SpaceTheme.stellarGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: SpaceTheme.nebulaPurple,
          labelColor: isReels ? Colors.white : SpaceTheme.nebulaPurple,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'Takip Edilenler'),
            Tab(text: 'Keşfet'),
            Tab(text: 'Reels'),
          ],
        ),
      ),
      body: _myProfile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Profil yüklenemedi.',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() => _profileChecked = false);
                      _checkProfile();
                    },
                    child: const Text('Tekrar Dene',
                        style: TextStyle(color: SpaceTheme.nebulaPurple)),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              // Disable horizontal swipe on Reels tab so PageView gets vertical scroll
              physics: _tabController.index == 2
                  ? const NeverScrollableScrollPhysics()
                  : const ScrollPhysics(),
              children: [
                _FeedList(
                  key: const ValueKey('feed'),
                  loader: FeedService.getFeed,
                  currentUserId: _myProfile!.userId,
                ),
                _FeedList(
                  key: const ValueKey('explore'),
                  loader: FeedService.getExplore,
                  currentUserId: _myProfile!.userId,
                ),
                ReelsScreen(
                  key: const ValueKey('reels'),
                  loader: FeedService.getExplore,
                  currentUserId: _myProfile!.userId,
                ),
              ],
            ),
      floatingActionButton: _myProfile != null && _tabController.index != 2
          ? FloatingActionButton(
              backgroundColor: SpaceTheme.nebulaPurple,
              foregroundColor: Colors.white,
              onPressed: _openCreate,
              tooltip: 'Yeni Paylaşım',
              child: const Icon(Icons.add_photo_alternate_outlined),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Infinite scroll list
// ---------------------------------------------------------------------------

typedef _FeedLoader = Future<FeedResponse> Function({int? cursor});

class _FeedList extends StatefulWidget {
  final _FeedLoader loader;
  final int currentUserId;

  const _FeedList({super.key, required this.loader, required this.currentUserId});

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
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
      if (mounted) {
        setState(() {
          _posts
            ..clear()
            ..addAll(result.posts);
          _nextCursor = result.nextCursor;
          _hasMore = result.hasMore;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Feed yüklenemedi.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _nextCursor == null) return;
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

  void _onPostUpdated(Post updated) {
    final idx = _posts.indexWhere((p) => p.id == updated.id);
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
        content: const Text('Bu gönderiyi silmek istiyor musun?',
            style: TextStyle(color: Colors.white70)),
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
        if (mounted) setState(() => _posts.removeWhere((p) => p.id == post.id));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple));
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
              child: const Text('Tekrar Dene',
                  style: TextStyle(color: SpaceTheme.nebulaPurple)),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('Henüz paylaşım yok.',
                style: TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Birini takip et veya kendin paylaşım yap!',
                style: TextStyle(color: Colors.white30, fontSize: 13)),
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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: _posts.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: SpaceTheme.nebulaPurple),
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
