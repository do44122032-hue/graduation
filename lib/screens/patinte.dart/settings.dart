import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
import 'patient_data_entry.dart';
import 'help_center.dart';
import 'about_app.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final languageCode = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: themeService.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppStrings.get('settingsTitle', languageCode),
          style: TextStyle(
            color: themeService.isDarkMode ? Colors.white : const Color(0xFF282828),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: Alignment.bottomRight,
              colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Account (الحساب)
          _buildSectionHeader(AppStrings.get('sectAccount', languageCode), themeService.isDarkMode),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: AppStrings.get('optEditInfo', languageCode),
            subtitle: AppStrings.get('subPersonalInfo', languageCode),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientDataEntryPage(),
                ),
              );
            },
            isDark: themeService.isDarkMode,
          ),

          const SizedBox(height: 24),
          // Section: Appearance (المظهر)
          _buildSectionHeader(AppStrings.get('sectAppearance', languageCode), themeService.isDarkMode),
          Container(
            decoration: BoxDecoration(
              color: themeService.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Dark Mode Toggle
                SwitchListTile(
                  value: themeService.isDarkMode,
                  onChanged: (val) => themeService.toggleTheme(),
                  title: Text(
                    themeService.isDarkMode 
                        ? AppStrings.get('optDarkMode', languageCode)
                        : AppStrings.get('optLightMode', languageCode),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeService.isDarkMode ? Colors.white : const Color(0xFF282828),
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6CA9A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: const Color(0xFFE6CA9A),
                    ),
                  ),
                  activeColor: const Color(0xFFCBD77E),
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                // Language
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6CA9A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.language, color: Color(0xFFE6CA9A)),
                  ),
                  title: Text(
                    AppStrings.get('optLanguage', languageCode),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeService.isDarkMode ? Colors.white : const Color(0xFF282828),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getLanguageName(languageCode),
                        style: const TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
                    ],
                  ),
                  onTap: () => _showLanguagePicker(context, languageService),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Section: Help (المساعدة)
          _buildSectionHeader(AppStrings.get('sectHelp', languageCode), themeService.isDarkMode),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: AppStrings.get('optHelpCenter', languageCode),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterPage(),
                ),
              );
            },
            isDark: themeService.isDarkMode,
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.get('optAboutApp', languageCode),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutAppPage(),
                ),
              );
            },
            isDark: themeService.isDarkMode,
          ),

          const SizedBox(height: 32),
          // Logout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                authService.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373).withOpacity(0.1),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.get('actionLogOut', languageCode),
                style: const TextStyle(
                  color: Color(0xFFE57373),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ku':
        return 'کوردی';
      default:
        return code;
    }
  }

  void _showLanguagePicker(
    BuildContext context,
    LanguageService languageService,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'English', 'en', languageService),
              _buildLanguageOption(context, 'العربية', 'ar', languageService),
              _buildLanguageOption(context, 'کوردی', 'ku', languageService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String name,
    String code,
    LanguageService languageService,
  ) {
    final isSelected = languageService.currentLanguage == code;
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFCBD77E) : const Color(0xFF282828),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFFCBD77E))
          : null,
      onTap: () {
        languageService.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : const Color(0xFF282828),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFCBD77E).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFCBD77E)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF282828),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
      ),
    );
  }
}



