import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../models/user_profile_model.dart';
import '../services/feed_service.dart';
import '../theme/space_theme.dart';
import 'user_avatar.dart';

class CommentsBottomSheet extends StatefulWidget {
  final int postId;
  final int currentUserId;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  static Future<int> show(
    BuildContext context, {
    required int postId,
    required int currentUserId,
  }) async {
    int delta = 0;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SpaceTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CommentsSheetContent(
        postId: postId,
        currentUserId: currentUserId,
        onDeltaChange: (d) => delta = d,
      ),
    );
    return delta;
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _CommentsSheetContent extends StatefulWidget {
  final int postId;
  final int currentUserId;
  final ValueChanged<int> onDeltaChange;

  const _CommentsSheetContent({
    required this.postId,
    required this.currentUserId,
    required this.onDeltaChange,
  });

  @override
  State<_CommentsSheetContent> createState() => _CommentsSheetContentState();
}

class _CommentsSheetContentState extends State<_CommentsSheetContent> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Comment> _comments = [];
  bool _loading = true;
  bool _sending = false;
  int _added = 0;
  int _deleted = 0;
  UserProfile? _myProfile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    widget.onDeltaChange(_added - _deleted);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        FeedService.getComments(widget.postId),
        FeedService.getMyProfile(),
      ]);
      if (mounted) {
        setState(() {
          _comments = results[0] as List<Comment>;
          _myProfile = results[1] as UserProfile;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final comment = await FeedService.addComment(widget.postId, text);
      _controller.clear();
      setState(() {
        _comments.add(comment);
        _added++;
        _sending = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (_) {
      setState(() => _sending = false);
    }
  }

  Future<void> _delete(Comment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpaceTheme.surfaceCard,
        title: const Text('Yorumu Sil', style: TextStyle(color: Colors.white)),
        content: const Text('Bu yorumu silmek istiyor musun?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Vazgeç', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await FeedService.deleteComment(comment.id);
      setState(() {
        _comments.removeWhere((c) => c.id == comment.id);
        _deleted++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Yorumlar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(color: Colors.white12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: SpaceTheme.nebulaPurple))
                  : _comments.isEmpty
                      ? const Center(
                          child: Text('Henüz yorum yok. İlk sen yaz!',
                              style: TextStyle(color: Colors.white54)),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _comments.length,
                          itemBuilder: (_, i) => _CommentTile(
                            comment: _comments[i],
                            isOwn: _comments[i].userId == widget.currentUserId,
                            onDelete: () => _delete(_comments[i]),
                          ),
                        ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  UserAvatar(
                    username: _myProfile?.username ?? '',
                    avatarUrl: _myProfile?.avatarUrl,
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Yorum yaz...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: SpaceTheme.surfaceCardLight,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: SpaceTheme.nebulaPurple))
                      : IconButton(
                          icon: const Icon(Icons.send_rounded, color: SpaceTheme.nebulaPurple),
                          onPressed: _send,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool isOwn;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isOwn ? onDelete : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(username: comment.username, avatarUrl: comment.avatarUrl, radius: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(comment.authorName,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(comment.timeAgo,
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(comment.content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            if (isOwn)
              GestureDetector(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.delete_outline, size: 16, color: Colors.white30),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
