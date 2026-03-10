import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import 'chat_screen.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;

    // Mock Data
    final conversations = [
      {
        'name': AppStrings.get('doctorName', languageCode),
        'specialty': AppStrings.get('doctorTitle', languageCode),
        'lastMessage': AppStrings.get('msgInitialLast', languageCode),
        'time': '10:30 AM',
        'unread': 2,
        'image':
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=150',
      },
      {
        'name': 'Dr. Emily Rodriguez',
        'specialty': AppStrings.get('specDermatology', languageCode),
        'lastMessage': AppStrings.get('msgPhotoRequest', languageCode),
        'time': AppStrings.get('timeAgo_yesterday', languageCode),
        'unread': 0,
        'image':
            'https://images.unsplash.com/photo-1594824476967-48c8b964273f?auto=format&fit=crop&q=80&w=150',
      },
      {
        'name': 'Dr. Sarah Johnson',
        'specialty': AppStrings.get('specGeneral', languageCode),
        'lastMessage': AppStrings.get('msgApptConfirmed', languageCode),
        'time': 'Mon',
        'unread': 0,
        'image':
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=150',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppStrings.get('navMessages', languageCode),
          style: const TextStyle(
            color: Color(0xFF282828),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: conversations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final chat = conversations[index];
          return _buildConversationCard(context, chat as Map<String, dynamic>);
        },
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    Map<String, dynamic> chat,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(doctorName: chat['name'], imageUrl: chat['image']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(chat['image']),
                    radius: 28,
                  ),
                  if ((chat['unread'] as int) > 0)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD77E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF282828),
                          ),
                        ),
                        Text(
                          chat['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: (chat['unread'] as int) > 0
                                ? const Color(0xFFCBD77E)
                                : const Color(0xFF9E9E9E),
                            fontWeight: (chat['unread'] as int) > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat['specialty'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCBD77E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat['lastMessage'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: (chat['unread'] as int) > 0
                                  ? const Color(0xFF282828)
                                  : const Color(0xFF757575),
                              fontWeight: (chat['unread'] as int) > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if ((chat['unread'] as int) > 0)
                          Container(
                            margin: const EdgeInsetsDirectional.only(start: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFCBD77E),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              (chat['unread'] as int).toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
