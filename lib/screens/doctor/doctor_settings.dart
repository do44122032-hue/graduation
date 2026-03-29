import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import 'doctor_profile.dart';
import 'doctor_change_password.dart';
import 'doctor_student_reports.dart';

class DoctorSettingsPage extends StatefulWidget {
  const DoctorSettingsPage({super.key});

  @override
  State<DoctorSettingsPage> createState() => _DoctorSettingsPageState();
}

class _DoctorSettingsPageState extends State<DoctorSettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);

    final languageCode = Provider.of<LanguageService>(context).currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppStrings.get('settingsTitle', languageCode),
          style: TextStyle(
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
              colors: [primaryBlue, Color(0xFF64B5F6)],
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
                  builder: (context) => const DoctorProfilePage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: AppStrings.get('optChangePassword', languageCode),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorChangePasswordScreen(),
                ),
              );
            },
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF282828),
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.notifications_none, color: primaryBlue),
                  ),
                  activeColor: primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Academic Management'),
          _buildSettingsTile(
            icon: Icons.school_outlined,
            title: 'Academic Management',
            subtitle: 'View student submissions and manage assigned tasks',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorStudentReportsPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(AppStrings.get('sectSupport', languageCode)),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: AppStrings.get('optHelpCenter', languageCode),
            onTap: () {}, // Future implementation
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: AppStrings.get('optAboutApp', languageCode),
            onTap: () {}, // Future implementation
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
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
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
    const primaryBlue = Color(0xFF1565C0);
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
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryBlue),
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
