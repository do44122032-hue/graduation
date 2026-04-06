import 'package:flutter/material.dart';
import 'package:graduation_project/services/ai_service.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<BotMessage> _messages;
  bool _isTyping = false;
  late String _languageCode;

  @override
  void initState() {
    super.initState();
    _messages = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageCode = Provider.of<LanguageService>(context).currentLanguage;
    if (_messages.isEmpty) {
      _messages.add(BotMessage(
        text: AppStrings.get('chatbotWelcome', _languageCode),
        isUser: false,
      ));
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(BotMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _messageController.clear();

    // Call the actual AI Service
    final responseText = await AiService.sendMessage(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(BotMessage(text: responseText, isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD77E).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Color(0xFFCBD77E)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('chatbotTitle', _languageCode),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  AppStrings.get('chatbotAlwaysAvailable', _languageCode),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1A1F1C), const Color(0xFF0F1210)],
                  )
                : const LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
                  ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildQuickSuggestions(_languageCode),
          _buildMessageInput(_languageCode),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions(String languageCode) {
    return Container(
      height: 50,
      margin: const EdgeInsetsDirectional.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSuggestionChip(AppStrings.get('suggestHeadache', languageCode)),
          _buildSuggestionChip(AppStrings.get('suggestBookAppt', languageCode)),
          _buildSuggestionChip(AppStrings.get('suggestLabResults', languageCode)),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
        ),
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: const Color(0xFFCBD77E).withOpacity(0.5)),
        ),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          AppStrings.get('chatbotTyping', _languageCode),
          style: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BotMessage message) {
    return Align(
      alignment: message.isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser 
              ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFCBD77E) : const Color(0xFF282828))
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomRight: message.isUser ? Radius.zero : null,
            bottomLeft: !message.isUser ? Radius.zero : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser 
                ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(String languageCode) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        16,
        16,
        16,
        100,
      ), // Added bottom padding to clear nav bar
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: _sendMessage,
                decoration: InputDecoration(
                  hintText: AppStrings.get('chatbotInputHint', languageCode),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFCBD77E),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}

class BotMessage {
  final String text;
  final bool isUser;

  BotMessage({required this.text, required this.isUser});
}



