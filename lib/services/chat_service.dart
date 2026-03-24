import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'dashboard_service.dart';

class ChatService {
  static String get baseUrl => DashboardService.baseUrl;

  static Future<bool> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'text',
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'content': content,
          'type': type,
          'data': data,
        }),
      );

      print('Send message response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return json.decode(response.body)['success'] ?? false;
      } else {
        print('Send message failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  static Future<List<ChatMessage>> fetchChatHistory(String user1Id, String user2Id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/history/$user1Id/$user2Id'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching chat history: $e');
      return [];
    }
  }

  static Future<List<ChatConversation>> fetchConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatConversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }
}
