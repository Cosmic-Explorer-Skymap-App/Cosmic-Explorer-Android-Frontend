class Post {
  final int id;
  final int userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String imageUrl;
  final String title;
  final String? caption;
  final int likeCount;
  final int commentCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.imageUrl,
    required this.title,
    this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.isLikedByMe,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      imageUrl: json['image_url'] as String,
      title: json['title'] as String,
      caption: json['caption'] as String?,
      likeCount: json['like_count'] as int,
      commentCount: json['comment_count'] as int,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Post copyWith({
    int? likeCount,
    int? commentCount,
    bool? isLikedByMe,
  }) {
    return Post(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      imageUrl: imageUrl,
      title: title,
      caption: caption,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt,
    );
  }

  String get authorName => displayName?.isNotEmpty == true ? displayName! : username;

  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (diff.inSeconds < 60) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes}d önce';
    if (diff.inHours < 24) return '${diff.inHours}s önce';
    if (diff.inDays < 7) return '${diff.inDays}g önce';
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }
}

class FeedResponse {
  final List<Post> posts;
  final int? nextCursor;
  final bool hasMore;

  FeedResponse({
    required this.posts,
    this.nextCursor,
    required this.hasMore,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      posts: (json['posts'] as List).map((e) => Post.fromJson(e)).toList(),
      nextCursor: json['next_cursor'] as int?,
      hasMore: json['has_more'] as bool,
    );
  }
}
