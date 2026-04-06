import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          AppStrings.get('optHelpCenter', lang),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A3A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : const Color(0xFF1A3A2E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: isDark ? const Color(0xFF2D5F4C).withOpacity(0.2) : const Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.support_agent_rounded,
                      size: 50,
                      color: isDark ? const Color(0xFFCBD77E) : const Color(0xFF2D5F4C),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('labelDeveloper', lang),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Eng.dania Al-Zubaidi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFCBD77E) : const Color(0xFF1A3A2E),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildContactInfo(
                    context: context,
                    icon: Icons.email_outlined,
                    label: AppStrings.get('labelContactEmail', lang),
                    value: 'daniadano2004@gmail.com',
                  ),
                  const SizedBox(height: 16),
                  _buildContactInfo(
                    context: context,
                    icon: Icons.location_on_outlined,
                    label: 'Support Availability',
                    value: '24/7 Dedicated Support',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F8E9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? const Color(0xFFCBD77E) : const Color(0xFF2D5F4C), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A3A2E),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.copy_rounded, size: 18, color: isDark ? Colors.white24 : Colors.grey),
        ],
      ),
    );
  }
}



