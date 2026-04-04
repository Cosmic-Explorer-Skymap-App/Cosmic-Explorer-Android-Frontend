class Comment {
  final int id;
  final int userId;
  final int postId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      postId: json['post_id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get authorName => displayName?.isNotEmpty == true ? displayName! : username;

  String get timeAgo {
    final diff = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (diff.inSeconds < 60) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes}d önce';
    if (diff.inHours < 24) return '${diff.inHours}s önce';
    return '${diff.inDays}g önce';
  }
}
