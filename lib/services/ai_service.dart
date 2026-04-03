import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graduation_project/constants/api_config.dart';

class AiService {
  // Toggle this to true to use Groq direct API, false to use your backend
  static const bool useGroqDirect = true;
  
  // The provided Groq API key used for the patient chatbot activation
  static const String _groqApiKey = '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';
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModel = 'llama-3.1-8b-instant'; // Using latest Llama 3.1 for best performance

  static String get _baseUrl => ApiConfig.baseUrl;

  /// Sends a message to the AI and returns the response string.
  static Future<String> sendMessage(String message) async {
    if (useGroqDirect) {
      return _sendGroqRequest(message);
    }
    
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

  /// Direct call to Groq Cloud API
  static Future<String> _sendGroqRequest(String userMessage) async {
    if (_groqApiKey == 'gsk_YOUR_GROQ_API_KEY_HERE') {
      return 'AI Configuration Error: Please provide your Groq API Key in lib/services/ai_service.dart';
    }

    try {
      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _groqModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful and expert AI Health Assistant for the Carely app. '
                         'Your goal is to help patients understand their health, medications, and lab results better. '
                         'Always provide empathetic but professional and evidence-based advice. '
                         'If the user asks for a diagnosis, explain that you are an AI and they should consult a real doctor, but you can provide general information about symptoms. '
                         'Keep responses concise and structured.'
            },
            {'role': 'user', 'content': userMessage}
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'I am sorry, I couldn\'t process that.';
      } else {
        final error = json.decode(response.body);
        return 'Groq API Error: ${error['error']['message'] ?? 'Unknown Error'}';
      }
    } catch (e) {
      return 'Connection Error: Unable to reach Groq. Please check your internet.';
    }
  }
}
