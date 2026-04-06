import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../enums/user_role.dart';
import 'login.dart';
import '../doctor/doctor_dashboard.dart';
import '../medical/dashboard_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showBypassDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Bypass'),
        content: const Text('Access dashboards without a backend connection for UI testing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ModernDashboardScreen())
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6AB5D8)),
                child: const Text('Guest Patient'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const DoctorDashboardScreen())
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCBD77E)),
                child: const Text('Guest Doctor'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;
    final isRTL = languageService.isRTL;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6AB5D8), // Blue
                Color(0xFFCBD77E), // Yellow-Green
                Color(0xFFE6CA9A), // Beige
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            isRTL
                                ? Icons.arrow_forward_ios
                                : Icons.arrow_back_ios,
                            color: const Color(0xFF285430),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onLongPress: () {
                                _showBypassDialog(context, lang);
                              },
                              child: Text(
                                AppStrings.get('selectRole', lang),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF285430),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.get('roleSubtitle', lang),
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF285430).withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Role Cards
                            _buildRoleCard(
                              context: context,
                              role: UserRole.patient,
                              title: AppStrings.get('rolePatient', lang),
                              description: AppStrings.get(
                                'rolePatientDesc',
                                lang,
                              ),
                              icon: Icons.personal_injury,
                              color: const Color(0xFFCBD77E),
                              lang: lang,
                            ),
                            const SizedBox(height: 20),
                            _buildRoleCard(
                              context: context,
                              role: UserRole.doctor,
                              title: AppStrings.get('roleDoctor', lang),
                              description: AppStrings.get(
                                'roleDoctorDesc',
                                lang,
                              ),
                              icon: Icons.medical_services,
                              color: AppColors.doctorPrimary,
                              lang: lang,
                            ),
                            const SizedBox(height: 20),
                            _buildRoleCard(
                              context: context,
                              role: UserRole.student,
                              title: AppStrings.get('roleStudent', lang),
                              description: AppStrings.get(
                                'roleStudentDesc',
                                lang,
                              ),
                              icon: Icons.school,
                              color: const Color(0xFFE8C998),
                              lang: lang,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String lang,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModernLoginScreen(userRole: role),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.6,
            ), // Increased opacity for contrast
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF285430),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF285430).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFF285430).withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



