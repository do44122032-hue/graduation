import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../models/user_model.dart';
import '../../widgets/modern_horizontal_nav_bar.dart';
import 'doctor_patients.dart';
import 'doctor_schedule.dart';
import 'doctor_settings.dart';
import 'doctor_profile.dart';
import 'doctor_messages.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  String _activeTabId = 'home';
  List<UserModel> _patients = [];
  bool _isLoadingPatients = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoadingPatients = true);
    try {
      final patients = await DashboardService.fetchPatients();
      setState(() {
        _patients = patients;
        _isLoadingPatients = false;
      });
    } catch (e) {
      setState(() => _isLoadingPatients = false);
      print('Error loading patients in dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.white, // White background for the body
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildContent(languageCode, authService)),
            ],
          ),
          // Floating Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: ModernHorizontalNavBar(
                activeTab: _activeTabId,
                languageCode: languageCode,
                activeColor: AppColors.doctorPrimary, // Doctor Theme Color
                navItems: [
                  ModernNavItem(
                    id: 'home',
                    icon: Icons.grid_view_rounded,
                    label: AppStrings.get('navHome', languageCode),
                  ),
                  ModernNavItem(
                    id: 'patients',
                    icon: Icons.people_alt_rounded,
                    label: AppStrings.get('navPatients', languageCode),
                  ),
                  ModernNavItem(
                    id: 'schedule',
                    icon: Icons.calendar_month_rounded,
                    label: AppStrings.get('navSchedule', languageCode),
                  ),
                  ModernNavItem(
                    id: 'messages',
                    icon: Icons.message_rounded,
                    label: AppStrings.get('navMessages', languageCode),
                  ),
                  ModernNavItem(
                    id: 'settings',
                    icon: Icons.settings_rounded,
                    label: AppStrings.get('navSettings', languageCode),
                  ),
                ],
                onTabChanged: (id) {
                  setState(() {
                    _activeTabId = id;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String languageCode, AuthService authService) {
    switch (_activeTabId) {
      case 'home':
        return _buildHomeContent(languageCode, authService);
      case 'patients':
        return const DoctorPatientsPage();
      case 'schedule':
        return const DoctorSchedulePage();
      case 'messages':
        return const DoctorMessagesPage();
      case 'settings':
        return const DoctorSettingsPage();
      default:
        return _buildHomeContent(languageCode, authService);
    }
  }

  Widget _buildHomeContent(String languageCode, AuthService authService) {
    final user = authService.currentUser;
    String dateStr;
    try {
      dateStr = DateFormat(
        'EEEE, d MMMM y',
        languageCode,
      ).format(DateTime.now());
    } catch (e) {
      // Fallback to English if the current locale is not supported by intl
      dateStr = DateFormat('EEEE, d MMMM y', 'en').format(DateTime.now());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Header from Image Reference
          Stack(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: AppColors.doctorBackground,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, right: 15),
                  child: _buildAnimatedLogo(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  48,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: [
                    // User Info Group
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Avatar moved above name
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorProfilePage(user: user),
                              ),
                            );
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                                  ? Image.network(
                                      user.profilePicture!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppColors.doctorPrimary.withOpacity(0.5),
                                        child: const Icon(Icons.person, size: 40, color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.doctorPrimary.withOpacity(0.5),
                                      child: const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.name ?? "Jaimin Panchal",
                          style: AppTextStyles.h2(languageCode: languageCode)
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                        ),
                        Text(
                          user?.email ?? "jaimin.panchal@gmail.com",
                          style: AppTextStyles.caption(
                            languageCode: languageCode,
                          ).copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                    // User Avatar removed from here
                ],
              ),
            ),
          ],
        ),
          const SizedBox(height: AppSpacing.lg),

          // Clinic List Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.get('doctorPatientListTitle', languageCode),
                  style: AppTextStyles.h3(languageCode: languageCode).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.doctorPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_patients.length} ${AppStrings.get('navPatients', languageCode)}",
                    style: AppTextStyles.caption(
                      languageCode: languageCode,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            child: _isLoadingPatients
                ? const Center(child: CircularProgressIndicator())
                : _patients.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.get('noPatients', languageCode),
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: _patients.length,
                        itemBuilder: (context, index) {
                          final patient = _patients[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.md,
                            ),
                            child: _buildPatientCard(
                              patient.name,
                              false,
                              languageCode,
                              patient.profilePicture,
                              () => setState(() => _activeTabId = 'patients'),
                            ),
                          );
                        },
                      ),
          ),

          const SizedBox(height: 24),

          // Medical Insights Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.doctorPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.science_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('doctorInsightsTitle', languageCode),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get('doctorInsightsSubtitle', languageCode),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),



          const SizedBox(height: 24),

          // Date
          Center(
            child: Text(
              dateStr,
              style: const TextStyle(
                color: AppColors.doctorPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stats List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildStatListItem(
                  AppStrings.get('statTotalPatients', languageCode),
                  _patients.length.toString(),
                  Icons.assignment_outlined,
                  AppColors.doctorPrimary,
                ),
                _buildStatListItem(
                  AppStrings.get('statCompletedToday', languageCode),
                  "12",
                  Icons.check_circle_outline,
                  AppColors.doctorPrimary,
                ),
                _buildStatListItem(
                  AppStrings.get('statPendingReviews', languageCode),
                  "5",
                  Icons.rate_review_outlined,
                  AppColors.doctorPrimary,
                ),
                _buildStatListItem(
                  AppStrings.get('statTodaysAppointments', languageCode),
                  "35",
                  Icons.calendar_today_outlined,
                  AppColors.doctorPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(
    String name,
    bool isActive,
    String languageCode,
    String? profilePicture,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? AppColors.doctorPrimary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isActive
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.doctorPrimary.withOpacity(0.1),
              backgroundImage:
                  profilePicture != null ? NetworkImage(profilePicture) : null,
              child: profilePicture == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: isActive ? Colors.white : AppColors.doctorPrimary,
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(languageCode: languageCode).copyWith(
                color: isActive ? Colors.white : AppColors.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatListItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16).copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ).copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return const PulseAnimatedLogo();
  }
}

class PulseAnimatedLogo extends StatefulWidget {
  const PulseAnimatedLogo({super.key});

  @override
  State<PulseAnimatedLogo> createState() => _PulseAnimatedLogoState();
}

class _PulseAnimatedLogoState extends State<PulseAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SizedBox(
              height: 150,
              width: 150,
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  key: UniqueKey(), // Forces browser to load the new clean version
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        size: 60,
                        color: Color(0xFF62A5F9),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);

    var secondControlPoint = Offset(3 * size.width / 4, size.height);
    var secondEndPoint = Offset(size.width, size.height - 50);

    path.cubicTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
