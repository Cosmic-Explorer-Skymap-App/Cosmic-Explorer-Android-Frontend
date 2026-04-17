class ConversationParticipant {
  final int userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  ConversationParticipant({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  String get label => displayName?.isNotEmpty == true ? displayName! : username;
}

class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      senderId: json['sender_id'] as int,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }
}

class Conversation {
  final int id;
  final ConversationParticipant otherUser;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime lastMessageAt;

  Conversation({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    required this.unreadCount,
    required this.lastMessageAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      otherUser: ConversationParticipant.fromJson(json['other_user'] as Map<String, dynamic>),
      lastMessage: json['last_message'] == null
          ? null
          : ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>),
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String).toUtc(),
    );
  }
}
