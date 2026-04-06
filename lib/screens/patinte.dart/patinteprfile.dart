import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import 'patient_data_entry.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('profileTitle', languageCode),
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
              colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
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
                child: Center(
                  child: Text(
                    user?.name != null && user!.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE6CA9A),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // User Name & Role
            Text(
              user?.name ?? AppStrings.get('labelUnknownUser', languageCode),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD77E).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD77E)),
              ),
              child: Text(
                AppStrings.get('labelPatient', languageCode),
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
                    context: context,
                    icon: Icons.email_outlined,
                    label: AppStrings.get('labelEmailAddress', languageCode),
                    value: user?.email ?? AppStrings.get('labelNotAvailable', languageCode),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileItem(
                    context: context,
                    icon: Icons.phone_outlined,
                    label: AppStrings.get('labelPhoneNumber', languageCode),
                    value: user?.phoneNumber ?? AppStrings.get('labelNotAvailable', languageCode),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsRow(context, user, languageCode),
                  const SizedBox(height: 32),

                  // Actions
                  _buildActionButton(
                    context,
                    label: AppStrings.get('actionEditProfile', languageCode),
                    icon: Icons.edit_note,
                    color: const Color(0xFFCBD77E),
                    textColor: const Color(0xFF282828),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientDataEntryPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    context,
                    label: AppStrings.get('actionLogout', languageCode),
                    icon: Icons.logout,
                    color: Colors.redAccent.withOpacity(0.1),
                    textColor: Colors.redAccent,
                    onTap: () {
                      authService.logout();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFCBD77E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, dynamic user, String languageCode) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            label: AppStrings.get('labelAge', languageCode),
            value: user?.age != null
                ? '${user.age} ${AppStrings.get('unitYears', languageCode)}'
                : AppStrings.get('labelNotAvailable', languageCode),
            color: const Color(0xFFCBD77E),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context: context,
            label: AppStrings.get('labelBlood', languageCode),
            value: user?.bloodType ?? AppStrings.get('labelNotAvailable', languageCode),
            color: const Color(0xFFE6CA9A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
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



