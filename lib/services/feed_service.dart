import 'dart:io';
import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../models/user_profile_model.dart';
import '../models/comment_model.dart';
import 'api_service.dart';

class FeedService {
  // ---------------------------------------------------------------------------
  // Posts
  // ---------------------------------------------------------------------------

  static Future<FeedResponse> getFeed({int? cursor}) async {
    final params = <String, dynamic>{};
    if (cursor != null) params['cursor'] = cursor;
    final response = await ApiService.get('/api/posts/feed', queryParameters: params);
    return FeedResponse.fromJson(response.data);
  }

  static Future<FeedResponse> getExplore({int? cursor}) async {
    final params = <String, dynamic>{};
    if (cursor != null) params['cursor'] = cursor;
    final response = await ApiService.get('/api/posts/explore', queryParameters: params);
    return FeedResponse.fromJson(response.data);
  }

  static Future<FeedResponse> getUserPosts(int userId, {int? cursor}) async {
    final params = <String, dynamic>{};
    if (cursor != null) params['cursor'] = cursor;
    final response = await ApiService.get('/api/posts/user/$userId', queryParameters: params);
    return FeedResponse.fromJson(response.data);
  }

  static Future<Post> createPost({
    required File image,
    required String title,
    String? caption,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      if (caption != null && caption.isNotEmpty) 'caption': caption,
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });
    final response = await ApiService.postForm('/api/posts/', data: formData);
    return Post.fromJson(response.data);
  }

  static Future<void> deletePost(int postId) async {
    await ApiService.delete('/api/posts/$postId');
  }

  // ---------------------------------------------------------------------------
  // Likes
  // ---------------------------------------------------------------------------

  /// Returns {liked: bool, like_count: int}
  static Future<Map<String, dynamic>> likePost(int postId) async {
    final response = await ApiService.post('/api/posts/$postId/like');
    return Map<String, dynamic>.from(response.data);
  }

  static Future<Map<String, dynamic>> unlikePost(int postId) async {
    final response = await ApiService.delete('/api/posts/$postId/like');
    return Map<String, dynamic>.from(response.data);
  }

  // ---------------------------------------------------------------------------
  // Comments
  // ---------------------------------------------------------------------------

  static Future<List<Comment>> getComments(int postId) async {
    final response = await ApiService.get('/api/posts/$postId/comments');
    return (response.data as List).map((e) => Comment.fromJson(e)).toList();
  }

  static Future<Comment> addComment(int postId, String content) async {
    final response = await ApiService.post(
      '/api/posts/$postId/comments',
      data: {'content': content},
    );
    return Comment.fromJson(response.data);
  }

  static Future<void> deleteComment(int commentId) async {
    await ApiService.delete('/api/comments/$commentId');
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  static Future<UserProfile> getMyProfile() async {
    final response = await ApiService.get('/api/users/me/profile');
    return UserProfile.fromJson(response.data);
  }

  static Future<UserProfile> setupProfile({
    required String username,
    String? displayName,
  }) async {
    final response = await ApiService.post('/api/users/me/profile/setup', data: {
      'username': username,
      if (displayName != null && displayName.isNotEmpty) 'display_name': displayName,
    });
    return UserProfile.fromJson(response.data);
  }

  static Future<UserProfile> updateProfile({
    String? displayName,
    String? bio,
  }) async {
    final response = await ApiService.put('/api/users/me/profile', data: {
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
    });
    return UserProfile.fromJson(response.data);
  }

  static Future<UserProfile> getUserProfile(int userId) async {
    final response = await ApiService.get('/api/users/$userId/profile');
    return UserProfile.fromJson(response.data);
  }

  static Future<bool> hasProfile() async {
    try {
      await getMyProfile();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Follows
  // ---------------------------------------------------------------------------

  static Future<void> followUser(int userId) async {
    await ApiService.post('/api/users/$userId/follow');
  }

  static Future<void> unfollowUser(int userId) async {
    await ApiService.delete('/api/users/$userId/follow');
  }

  static Future<List<UserProfile>> getFollowers(int userId) async {
    final response = await ApiService.get('/api/users/$userId/followers');
    return (response.data as List).map((e) => UserProfile.fromJson(e)).toList();
  }

  static Future<List<UserProfile>> getFollowing(int userId) async {
    final response = await ApiService.get('/api/users/$userId/following');
    return (response.data as List).map((e) => UserProfile.fromJson(e)).toList();
  }
}
