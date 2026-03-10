import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';

enum MessageType { text, labResult, medication, appointment }

class Message {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? data;

  Message({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.type = MessageType.text,
    this.data,
  });
}

class ChatScreen extends StatefulWidget {
  final String doctorName;
  final String imageUrl;

  const ChatScreen({Key? key, required this.doctorName, required this.imageUrl})
    : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<Message> _messages;
  bool _initialized = false;

  void _initMessages(String languageCode) {
    if (_initialized) return;
    _messages = [
      Message(
        text: AppStrings.get('msgDoctorInitial', languageCode),
        isSentByMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Message(
        text: AppStrings.get('msgPatientInitial', languageCode),
        isSentByMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ];
    _initialized = true;
  }

  void _sendMessage({
    String text = '',
    MessageType type = MessageType.text,
    Map<String, dynamic>? data,
  }) {
    if (text.trim().isEmpty && type == MessageType.text) return;

    setState(() {
      _messages.add(
        Message(
          text: text,
          isSentByMe: true,
          timestamp: DateTime.now(),
          type: type,
          data: data,
        ),
      );
    });
    _messageController.clear();
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
                      type: MessageType.labResult,
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
                      type: MessageType.medication,
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
                      type: MessageType.appointment,
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
    _initMessages(languageCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
              radius: 20,
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, languageCode);
              },
            ),
          ),
          _buildMessageInput(languageCode),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, String languageCode) {
    Widget content;
    switch (message.type) {
      case MessageType.labResult:
        content = _buildLabResultContent(message.data!, languageCode);
        break;
      case MessageType.medication:
        content = _buildMedicationContent(message.data!, languageCode);
        break;
      case MessageType.appointment:
        content = _buildAppointmentContent(message.data!, languageCode);
        break;
      case MessageType.text:
      default:
        content = Text(
          message.text,
          style: TextStyle(
            color: message.isSentByMe ? Colors.white : const Color(0xFF282828),
            fontSize: 15,
          ),
        );
    }

    return Align(
      alignment: message.isSentByMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isSentByMe ? const Color(0xFFCBD77E) : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isSentByMe ? Radius.zero : null,
            bottomLeft: !message.isSentByMe ? Radius.zero : null,
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
                color: message.isSentByMe
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
                data['testName'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${AppStrings.get('labelDate', languageCode)} ${data['date']}",
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "${AppStrings.get('labelStatus', languageCode)} ${data['status']}",
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
                data['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(data['dosage']),
              Text(
                data['frequency'],
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
                data['type'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${data['date']} ${AppStrings.get('labelAt', languageCode)} ${data['time']}",
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppStrings.get(
                              'msgAppointmentCancelled',
                              languageCode,
                            ),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(
                            bottom: 100,
                            left: 24,
                            right: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(AppStrings.get('actionCancel', languageCode)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(String languageCode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ), // Added bottom padding to clear nav bar
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
