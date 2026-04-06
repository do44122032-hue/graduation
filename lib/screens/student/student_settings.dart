import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
import '../../services/auth_service.dart';
import 'student_profile.dart';
import 'student_change_password.dart';
import '../patinte.dart/help_center.dart';
import '../patinte.dart/about_app.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {


  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('settingsTitle', languageCode),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF282828),
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
              colors: [Color(0xFFE8C998), Color(0xFFF5DDB8)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(AppStrings.get('sectAccount', languageCode), context),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: AppStrings.get('optPersonalInfo', languageCode),
            subtitle: AppStrings.get('subPersonalInfo', languageCode),
            context: context,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentProfileScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: AppStrings.get('optChangePassword', languageCode),
            context: context,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentChangePasswordScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(AppStrings.get('sectPreferences', languageCode), context),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildLanguageTile(languageCode, context),
                const Divider(height: 1, indent: 60),
                _buildThemeTile(context),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(AppStrings.get('sectSupport', languageCode), context),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: AppStrings.get('optHelpCenter', languageCode),
            context: context,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterPage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.get('optAboutApp', languageCode),
            context: context,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutAppPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
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

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8C998).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Color(0xFFE8C998)),
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
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
      ),
    );
  }

  Widget _buildLanguageTile(String languageCode, BuildContext context) {
    return ListTile(
      onTap: () => _showLanguageBottomSheet(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8C998).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.language, color: Color(0xFFE8C998)),
      ),
      title: Text(
        AppStrings.get('optLanguage', languageCode),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLanguageName(languageCode),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    const primaryOrange = Color(0xFFE8C998);
    final themeService = Provider.of<ThemeService>(context);
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;
    final isDark = themeService.isDarkMode;

    return ListTile(
      onTap: () => themeService.toggleTheme(),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: primaryOrange,
        ),
      ),
      title: Text(
        isDark ? AppStrings.get('optDarkMode', languageCode) : AppStrings.get('optLightMode', languageCode),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: (_) => themeService.toggleTheme(),
        activeColor: primaryOrange,
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'ku':
        return 'کوردی';
      default:
        return 'English';
    }
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final languageService = Provider.of<LanguageService>(
          context,
          listen: false,
        );
        final currentLang = languageService.currentLanguage;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.get('optLanguage', currentLang),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context,
                'English',
                'en',
                currentLang == 'en',
              ),
              _buildLanguageOption(
                context,
                'العربية',
                'ar',
                currentLang == 'ar',
              ),
              _buildLanguageOption(
                context,
                'کوردی',
                'ku',
                currentLang == 'ku',
              ),
              const SizedBox(height: 24),
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
    bool isSelected,
  ) {
    return ListTile(
      onTap: () {
        Provider.of<LanguageService>(
          context,
          listen: false,
        ).changeLanguage(code);
        Navigator.pop(context);
      },
      leading: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFFE8C998))
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFE8C998) : null,
        ),
      ),
    );
  }
}
