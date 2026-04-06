import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message.dart';
import '../patinte.dart/chat_screen.dart';

class DoctorMessagesPage extends StatefulWidget {
  const DoctorMessagesPage({Key? key}) : super(key: key);

  @override
  State<DoctorMessagesPage> createState() => _DoctorMessagesPageState();
}

class _DoctorMessagesPageState extends State<DoctorMessagesPage> {
  bool _isLoading = true;
  List<ChatConversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null) return;

    try {
      final convs = await ChatService.fetchConversations(user.id);
      if (mounted) {
        setState(() {
          _conversations = convs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations for doctor: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('navMessages', languageCode),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.doctorPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.doctorPrimary))
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get('noMessages', languageCode).isEmpty 
                            ? 'No messages yet' 
                            : AppStrings.get('noMessages', languageCode),
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  color: AppColors.doctorPrimary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      return _buildConversationCard(context, conv, languageCode);
                    },
                  ),
                ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    ChatConversation conv,
    String languageCode,
  ) {
    final partner = conv.partner;
    final lastMsg = conv.lastMessage;
    
    String timeStr = '';
    if (lastMsg != null) {
      final localTimestamp = lastMsg.timestamp.toLocal();
      final now = DateTime.now();
      final diff = now.difference(localTimestamp);
      if (diff.inDays == 0 && now.day == localTimestamp.day) {
        timeStr = DateFormat.jm().format(localTimestamp);
      } else if (diff.inDays <= 1 && now.day - localTimestamp.day == 1) {
        timeStr = AppStrings.get('timeAgo_yesterday', languageCode);
      } else {
        timeStr = "${localTimestamp.day}/${localTimestamp.month}";
      }
    }

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 1,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverId: partner['id'].toString(),
                receiverName: partner['name'] ?? 'Patient',
                imageUrl: partner['profilePicture'] ?? '',
              ),
            ),
          ).then((_) => _loadConversations());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: partner['profilePicture'] != null 
                        ? NetworkImage(partner['profilePicture']) 
                        : null,
                    radius: 28,
                    backgroundColor: AppColors.doctorPrimary.withOpacity(0.1),
                    child: partner['profilePicture'] == null 
                        ? const Icon(Icons.person, color: AppColors.doctorPrimary) 
                        : null,
                  ),
                  if (conv.unreadCount > 0)
                    PositionedDirectional(
                      end: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.doctorPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Colors.white, width: 2),
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
                          partner['name'] ?? 'Patient',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: conv.unreadCount > 0
                                ? AppColors.doctorPrimary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: conv.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMsg?.content ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: conv.unreadCount > 0
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: conv.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (conv.unreadCount > 0)
                          Container(
                            margin: const EdgeInsetsDirectional.only(start: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.doctorPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              conv.unreadCount.toString(),
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



