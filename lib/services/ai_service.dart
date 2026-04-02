import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graduation_project/constants/api_config.dart';

class AiService {
  static String get _baseUrl => ApiConfig.baseUrl;

  /// Sends a message to the AI backend and returns the response string.
  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] ?? 'I received an empty response. Please try again.';
      } else {
        return 'Sorry, I am having trouble connecting to my service. Please make sure the AI is configured in the backend.';
      }
    } catch (e) {
      return 'Sorry, there was a connection error. Please try again later.';
    }
  }
}
