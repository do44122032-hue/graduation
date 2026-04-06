import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import 'student_edit_profile.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  static const Color orangePrimary = Color(0xFFFF9800);
  static const Color orangeLight = Color(0xFFFFB74D);
  static const Color studentThemeColor = Color(0xFFE8C998);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final languageService = Provider.of<LanguageService>(context);
    final user = authService.currentUser;
    final String languageCode = languageService.currentLanguage;
    // Determine text direction based on language
    final TextDirection textDirection =
        languageCode == 'ar' || languageCode == 'ku'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: Text(
            AppStrings.get('titleProfile', languageCode),
            style: const TextStyle(
              color: Color(0xFF282828),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF282828)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: Alignment.bottomRight,
                colors: [studentThemeColor, Color(0xFFF5DDB8)],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Avatar
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipOval(
                    child: user?.profilePicture != null
                        ? Image.network(
                            user!.profilePicture!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'S',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: studentThemeColor,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // User Name & Role
              Text(
                user?.name ?? AppStrings.get('studentName', languageCode),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF282828),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: studentThemeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: studentThemeColor),
                ),
                child: Text(
                  AppStrings.get('roleStudent', languageCode).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF282828),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Info Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildProfileItem(
                      icon: Icons.email_outlined,
                      label: AppStrings.get('labelEmailAddress', languageCode),
                      value: user?.email ?? 'alex.thompson@university.edu',
                    ),
                    const SizedBox(height: 16),
                    _buildProfileItem(
                      icon: Icons.phone_outlined,
                      label: AppStrings.get('labelPhoneNumber', languageCode),
                      value: user?.phoneNumber ?? '+1 234 567 890',
                    ),
                    const SizedBox(height: 16),
                    _buildAcademicRow(languageCode),
                    const SizedBox(height: 32),

                    // Actions
                    _buildActionButton(
                      context,
                      label: AppStrings.get('actionEditProfile', languageCode),
                      icon: Icons.edit_outlined,
                      color: const Color(0xFF282828),
                      textColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StudentEditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      context,
                      label: AppStrings.get('actionLogOut', languageCode),
                      icon: Icons.logout,
                      color: Colors.redAccent.withOpacity(0.1),
                      textColor: Colors.redAccent,
                      onTap: () {
                        authService.logout();
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF282828)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF282828),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicRow(String languageCode) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: AppStrings.get('gpa', languageCode),
            value: '3.82',
            color: orangePrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: AppStrings.get('studentId', languageCode),
            value: '2024-88429',
            color: studentThemeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF282828).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF282828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



