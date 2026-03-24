class ChatMessage {
  final int id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> data;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.type = 'text',
    this.data = const {},
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      senderId: json['senderId'].toString(),
      receiverId: json['receiverId'].toString(),
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'] ?? 'text',
      data: json['data'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'data': data,
    };
  }

  bool isSentByMe(String currentUserId) => senderId == currentUserId;
}

class ChatConversation {
  final Map<String, dynamic> partner;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ChatConversation({
    required this.partner,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      partner: json['partner'] as Map<String, dynamic>,
      lastMessage: json['lastMessage'] != null 
          ? ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
