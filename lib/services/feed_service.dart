import 'dart:io';
import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../models/message_model.dart';
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
    final payload = <String, dynamic>{};
    if (displayName != null) {
      payload['display_name'] = displayName;
    }
    if (bio != null) {
      payload['bio'] = bio;
    }
    final response = await ApiService.put('/api/users/me/profile', data: payload);
    return UserProfile.fromJson(response.data);
  }

  static Future<UserProfile> uploadAvatar(File image) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });
    final response = await ApiService.postForm('/api/users/me/profile/avatar', data: formData);
    return UserProfile.fromJson(response.data);
  }

  static Future<UserProfile> getUserProfile(int userId) async {
    final response = await ApiService.get('/api/users/$userId/profile');
    return UserProfile.fromJson(response.data);
  }

  static Future<List<UserProfile>> searchUsers(String query) async {
    final response = await ApiService.get(
      '/api/users/search',
      queryParameters: {'q': query},
    );
    return (response.data as List)
        .map((item) => UserProfile.fromJson(item))
        .toList();
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

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

  static Future<List<Conversation>> getConversations() async {
    final response = await ApiService.get('/api/messages/conversations');
    return (response.data as List)
        .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Conversation> openConversation(int userId) async {
    final response = await ApiService.post('/api/messages/conversations/$userId');
    return Conversation.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<List<ChatMessage>> getMessages(int conversationId) async {
    final response = await ApiService.get('/api/messages/conversations/$conversationId/messages');
    return (response.data as List)
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ChatMessage> sendMessage(int conversationId, String content) async {
    final response = await ApiService.post(
      '/api/messages/conversations/$conversationId/messages',
      data: {'content': content},
    );
    return ChatMessage.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<int> getUnreadCount() async {
    final response = await ApiService.get('/api/messages/unread-count');
    return response.data['unread_count'] as int? ?? 0;
  }
}
