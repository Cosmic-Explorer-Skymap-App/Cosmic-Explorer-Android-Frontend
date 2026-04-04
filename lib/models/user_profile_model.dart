class UserProfile {
  final int userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final bool isFollowing;

  UserProfile({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.followerCount,
    required this.followingCount,
    required this.postCount,
    required this.isFollowing,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      followerCount: json['follower_count'] as int,
      followingCount: json['following_count'] as int,
      postCount: json['post_count'] as int,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  UserProfile copyWith({bool? isFollowing, int? followerCount}) {
    return UserProfile(
      userId: userId,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount,
      postCount: postCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  String get displayedName => displayName?.isNotEmpty == true ? displayName! : username;
}
