import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import 'patient_data_entry.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppStrings.get('settingsTitle', languageCode),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(AppStrings.get('sectAccount', languageCode)),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: AppStrings.get('optPersonalInfo', languageCode),
            subtitle: AppStrings.get('subPersonalInfo', languageCode),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientDataEntryPage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: AppStrings.get('optChangePassword', languageCode),
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.payment_outlined,
            title: AppStrings.get('labelPaymentMethods', languageCode),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(AppStrings.get('sectPreferences', languageCode)),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: (val) =>
                      setState(() => _notificationsEnabled = val),
                  title: Text(
                    AppStrings.get('optPushNotifications', languageCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282828),
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6CA9A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFFE6CA9A),
                    ),
                  ),
                  activeColor: const Color(0xFFCBD77E),
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                SwitchListTile(
                  value: _biometricsEnabled,
                  onChanged: (val) => setState(() => _biometricsEnabled = val),
                  title: Text(
                    AppStrings.get('optBiometrics', languageCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282828),
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6CA9A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: Color(0xFFE6CA9A),
                    ),
                  ),
                  activeColor: const Color(0xFFCBD77E),
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                SwitchListTile(
                  value: true,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppStrings.get('msgDoctorModeUpdated', languageCode),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  title: Text(
                    AppStrings.get('labelDoctorMode', languageCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282828),
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6CA9A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFFE6CA9A),
                    ),
                  ),
                  activeColor: const Color(0xFFCBD77E),
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6CA9A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.language, color: Color(0xFFE6CA9A)),
                  ),
                  title: Text(
                    AppStrings.get('optLanguage', languageCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282828),
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
          _buildSectionHeader(AppStrings.get('sectSupport', languageCode)),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: AppStrings.get('optHelpCenter', languageCode),
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.get('optAboutApp', languageCode),
            onTap: () {},
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
                  borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return AppStrings.get('labelEnglish', code);
      case 'ar':
        return AppStrings.get('labelArabic', code);
      case 'ku':
        return AppStrings.get('labelKurdish', code);
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF282828),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF282828),
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
