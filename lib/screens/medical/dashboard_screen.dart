import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/modern_horizontal_nav_bar.dart';
import '../patinte.dart/booking.dart';
import '../patinte.dart/medicalrecord.dart';
import '../patinte.dart/patinteprfile.dart';
import '../patinte.dart/labresulit.dart';
import '../patinte.dart/pharmacy.dart';
import '../patinte.dart/messages.dart';
import '../patinte.dart/settings.dart';
import '../ai/chatbot_screen.dart';

class ModernDashboardScreen extends StatefulWidget {
  const ModernDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _activeTabId = 'home';
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'id': '1',
      'doctorName': 'Dr. Michael Chen',
      'specialty': 'Cardiologist',
      'date': 'Jan 12, 2026',
      'time': '10:30 AM',
      'type': 'Video Consultation',
      'status': 'confirmed',
    },
    {
      'id': '2',
      'doctorName': 'Dr. Sarah Wilson',
      'specialty': 'Dermatologist',
      'date': 'Jan 15, 2026',
      'time': '02:00 PM',
      'type': 'In-Person Visit',
      'status': 'confirmed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Stack(
          children: [
            // Tab Content
            Positioned.fill(child: _buildContent(languageCode)),

            // Floating Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: ModernHorizontalNavBar(
                  activeTab: _activeTabId,
                  languageCode: languageCode,
                  activeColor: AppColors.mainButton, // Patient Theme Color
                  navItems: [
                    ModernNavItem(
                      id: 'home',
                      icon: Icons.home_outlined,
                      label: AppStrings.get('navHome', languageCode),
                    ),
                    ModernNavItem(
                      id: 'messages',
                      icon: Icons.chat_bubble_outline,
                      label: AppStrings.get('navMessages', languageCode),
                    ),
                    ModernNavItem(
                      id: 'chatbot',
                      icon: Icons.smart_toy_outlined,
                      label: AppStrings.get('navChatbot', languageCode),
                    ),
                    ModernNavItem(
                      id: 'settings',
                      icon: Icons.settings_outlined,
                      label: AppStrings.get('navSettings', languageCode),
                    ),
                  ],
                  onTabChanged: (id) {
                    setState(() {
                      _activeTabId = id;
                      if (id == 'home') {
                        _animationController.reset();
                        _animationController.forward();
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String languageCode) {
    switch (_activeTabId) {
      case 'home':
        return _buildHomeContent(languageCode);
      case 'messages':
        return const MessagesPage();
      case 'chatbot':
        return const ChatbotScreen();
      case 'settings':
        return const SettingsPage();
      default:
        return _buildHomeContent(languageCode);
    }
  }

  Widget _buildHomeContent(String languageCode) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(languageCode, user),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildQuickActionsList(languageCode),
                const SizedBox(height: 24),
                _buildAnnouncementBanner(
                  AppStrings.get('healthUpdate', languageCode),
                  AppStrings.get(
                    'labPendingReview',
                    languageCode,
                  ).replaceAll('{count}', '2'),
                  Icons.health_and_safety,
                ),
                const SizedBox(height: 24),
                _buildUpcomingAppointments(languageCode),
                const SizedBox(height: 24),
                _buildPatientInfoList(languageCode, user),
                const SizedBox(height: 120), // Height for nav bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(String languageCode) {
    if (_upcomingAppointments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('upcomingAppt', languageCode),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF282828),
          ),
        ),
        const SizedBox(height: 16),
        ..._upcomingAppointments.map(
          (apt) => _buildAppointmentCard(apt, languageCode),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> apt, String languageCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD77E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Color(0xFFCBD77E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apt['doctorName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      apt['specialty'],
                      style: TextStyle(
                        color: const Color(0xFF282828).withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD77E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.get('confirmed', languageCode),
                  style: const TextStyle(
                    color: Color(0xFFCBD77E),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFFE6CA9A),
              ),
              const SizedBox(width: 8),
              Text(
                apt['date'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: Color(0xFFE6CA9A)),
              const SizedBox(width: 8),
              Text(
                apt['time'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(apt, languageCode),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(AppStrings.get('actionCancel', languageCode)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // View details logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBD77E),
                    foregroundColor: const Color(0xFF282828),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(AppStrings.get('viewDetails', languageCode)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> apt, String languageCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.get('actionCancel', languageCode)),
        content: Text(
          "Are you sure you want to cancel your appointment with ${apt['doctorName']} on ${apt['date']} at ${apt['time']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('back', languageCode)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(apt['id'], languageCode);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(String id, String languageCode) {
    setState(() {
      _upcomingAppointments.removeWhere((a) => a['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('msgAppointmentCancelled', languageCode)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 24, right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHeader(String languageCode, dynamic user) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [Color(0xFFE8F1BD), Color(0xFFF9F3E5)],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hamburger Menu
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBD77E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sort,
                        color: Color(0xFF282828),
                        size: 26,
                      ),
                    ),
                    // Profile Image - Larger and positioned like the image
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(55),
                          child: user?.profilePicture != null
                              ? Image.network(
                                  user!.profilePicture!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: const Color(0xFFE6CA9A),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Sarah Johnson',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF282828),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        user?.email ?? 'sarah.j@example.com',
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color(0xFF282828).withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsList(String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.get('quickActions', languageCode),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF282828),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD77E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.get(
                  'activeCount',
                  languageCode,
                ).replaceAll('{count}', '4'),
                style: const TextStyle(
                  color: Color(0xFF282828),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildClinicCard(
                AppStrings.get('bookAppt', languageCode),
                Icons.calendar_today,
                true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookAppointmentPage(),
                    ),
                  );
                },
              ),
              _buildClinicCard(
                AppStrings.get('medicalRecordsShort', languageCode),
                Icons.description,
                false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicalRecordsPage(),
                    ),
                  );
                },
              ),
              _buildClinicCard(
                AppStrings.get('labResultsShort', languageCode),
                Icons.monitor_heart,
                false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LabResultsPage(),
                    ),
                  );
                },
              ),
              _buildClinicCard(
                AppStrings.get('pharmacyShort', languageCode),
                Icons.medication_liquid,
                false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PharmacyPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClinicCard(
    String name,
    IconData icon,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFCBD77E).withOpacity(
                        0.2,
                      ) // Slightly more visible
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFCBD77E)
                      : Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 40,
                  color: isActive
                      ? const Color(0xFFCBD77E)
                      : const Color(0xFFE6CA9A),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF282828),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementBanner(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD77E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFCBD77E), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF282828),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF282828), size: 24),
        ],
      ),
    );
  }

  Widget _buildPatientInfoList(String languageCode, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Builder(
            builder: (context) {
              String formattedDate;
              try {
                formattedDate = DateFormat(
                  'EEEE, d MMMM yyyy',
                  languageCode,
                ).format(DateTime.now());
              } catch (e) {
                // Fallback to English if locale is not supported by intl
                formattedDate = DateFormat(
                  'EEEE, d MMMM yyyy',
                  'en',
                ).format(DateTime.now());
              }
              return Text(
                formattedDate,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildStatItem(
          AppStrings.get('demographics', languageCode),
          '${user?.age ?? "28"} ${AppStrings.get('labelYears', languageCode)}, ${user?.weight ?? "65kg"}',
          Icons.person,
        ),
        _buildStatItem(
          AppStrings.get('bloodType', languageCode),
          user?.bloodType ?? 'O+',
          Icons.bloodtype,
        ),
        _buildStatItem(
          AppStrings.get('socialStatus', languageCode),
          user?.socialStatus ?? AppStrings.get('labelSingle', languageCode),
          Icons.family_restroom,
        ),
        _buildStatItem(
          AppStrings.get('chronicDiseases', languageCode),
          (user?.chronicConditions != null &&
                  user!.chronicConditions!.isNotEmpty)
              ? (user!.chronicConditions as List).join(', ')
              : AppStrings.get('labelNone', languageCode),
          Icons.medical_services,
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFCBD77E), size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCBD77E),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD77E), size: 16),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(
    String title,
    IconData icon,
    String languageCode,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.patientPrimary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.get('labelComingSoon', languageCode),
            style: const TextStyle(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    var controlPoint = Offset(size.width / 2, size.height + 20);
    var endPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
