import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String imageUrl;

  const ChatScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadChatHistory(isPolling: true);
    });
  }

  Future<void> _loadChatHistory({bool isPolling = false}) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null) return;

    try {
      final history = await ChatService.fetchChatHistory(user.id, widget.doctorId);
      if (mounted) {
        setState(() {
          _messages = history;
          if (!isPolling) _isLoading = false;
        });
        if (!isPolling) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('Error loading chat history: $e');
      if (mounted && !isPolling) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({
    String text = '',
    String type = 'text',
    Map<String, dynamic>? data,
  }) async {
    if (text.trim().isEmpty && type == 'text') return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null) return;

    final content = text.trim();
    _messageController.clear();

    final success = await ChatService.sendMessage(
      senderId: user.id,
      receiverId: widget.doctorId,
      content: content,
      type: type,
      data: data,
    );

    if (success) {
      _loadChatHistory(isPolling: true);
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  void _showAttachmentOptions(String languageCode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.get('sendToPatient', languageCode),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  icon: Icons.science,
                  label: AppStrings.get('msgLabResult', languageCode),
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _sendMessage(
                      text: "Lab Results: Blood Count",
                      type: 'lab_result',
                      data: {
                        'testName': 'Complete Blood Count (CBC)',
                        'date': '28 Dec 2025',
                        'status': AppStrings.get('statusNormal', languageCode),
                      },
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.medication,
                  label: AppStrings.get('msgMedication', languageCode),
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _sendMessage(
                      text: "Prescription: Amoxicillin",
                      type: 'medication',
                      data: {
                        'name': 'Amoxicillin',
                        'dosage': '500mg',
                        'frequency': '3x daily for 7 days',
                      },
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.calendar_today,
                  label: AppStrings.get('msgAppointment', languageCode),
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _sendMessage(
                      text: "Appointment Scheduled",
                      type: 'appointment',
                      data: {
                        'date': '2 Jan 2026',
                        'time': '10:00 AM',
                        'type': 'Follow-up',
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
              radius: 20,
              backgroundColor: const Color(0xFFCBD77E).withOpacity(0.2),
              child: widget.imageUrl.isEmpty ? const Icon(Icons.person, color: Color(0xFFCBD77E)) : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF282828),
                  ),
                ),
                Text(
                  AppStrings.get('labelOnline', languageCode),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFCBD77E),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF282828)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFCBD77E)))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Start conversation with ${widget.doctorName}',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.isSentByMe(currentUser?.id ?? '');
                          return _buildMessageBubble(message, isMe, languageCode);
                        },
                      ),
          ),
          _buildMessageInput(languageCode),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, String languageCode) {
    Widget content;
    switch (message.type) {
      case 'lab_result':
        content = _buildLabResultContent(message.data, languageCode);
        break;
      case 'medication':
        content = _buildMedicationContent(message.data, languageCode);
        break;
      case 'appointment':
        content = _buildAppointmentContent(message.data, languageCode);
        break;
      case 'text':
      default:
        content = Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : const Color(0xFF282828),
            fontSize: 15,
          ),
        );
    }

    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFCBD77E) : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? Radius.zero : null,
            bottomLeft: !isMe ? Radius.zero : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            content,
            const SizedBox(height: 4),
            Text(
              "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: isMe
                    ? Colors.white.withOpacity(0.8)
                    : const Color(0xFF9E9E9E),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabResultContent(
    Map<String, dynamic> data,
    String languageCode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.science, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.get('msgLabResultsAvailable', languageCode),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['testName'] ?? 'Lab Test',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${AppStrings.get('labelDate', languageCode)} ${data['date'] ?? ''}",
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "${AppStrings.get('labelStatus', languageCode)} ${data['status'] ?? ''}",
                style: TextStyle(
                  fontSize: 12,
                  color:
                      data['status'] == AppStrings.get('statusNormal', 'en') ||
                          data['status'] ==
                              AppStrings.get('statusNormal', 'ar') ||
                          data['status'] == AppStrings.get('statusNormal', 'ku')
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationContent(
    Map<String, dynamic> data,
    String languageCode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.get('labelPrescription', languageCode),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['name'] ?? 'Medication',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(data['dosage'] ?? ''),
              Text(
                data['frequency'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentContent(
    Map<String, dynamic> data,
    String languageCode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.get('msgAppointment', languageCode),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['type'] ?? 'Appointment',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${data['date'] ?? ''} ${AppStrings.get('labelAt', languageCode)} ${data['time'] ?? ''}",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(String languageCode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFFCBD77E),
            ),
            onPressed: () => _showAttachmentOptions(languageCode),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: AppStrings.get('typeMessageHint', languageCode),
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                ),
                onSubmitted: (val) => _sendMessage(text: val),
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
              onPressed: () => _sendMessage(text: _messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}
