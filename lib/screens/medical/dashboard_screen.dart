import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/modern_horizontal_nav_bar.dart';
import '../patinte.dart/booking.dart';
import '../patinte.dart/medicalrecord.dart';
import '../patinte.dart/patinteprfile.dart';
import '../patinte.dart/labresulit.dart';
// import '../patinte.dart/pharmacy.dart';
import '../patinte.dart/messages.dart';
import '../patinte.dart/settings.dart';
import '../ai/chatbot_screen.dart';
import '../patinte.dart/doctor_selection.dart';
import 'doctor_schedule_management.dart';
import '../../models/user_model.dart';

class ModernDashboardScreen extends StatefulWidget {
  const ModernDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _activeTabId = 'home';
  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _healthAlerts = [];
  List<Map<String, dynamic>> _activeMedications = [];
  List<Map<String, dynamic>> _recentVitals = [];
  List<Map<String, dynamic>> _labResults = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null || user.id == null) {
      if(mounted) setState(() => _isLoading = false);
      return;
    }

    // 1. Instantly load from local memory/disk for the best UX while waiting for server
    final localVital = await DashboardService.getLocalVital();
    if (localVital != null && mounted) {
      setState(() {
        _recentVitals = [localVital];
        _isLoading = false; // Show dashboard immediately with local data
      });
    }

    try {
      final data = await DashboardService.fetchPatientDashboard(user.id!);
      if (data['success'] == true && mounted) {
        setState(() {
          _upcomingAppointments = List<Map<String, dynamic>>.from(data['upcomingAppointments'] ?? []);
          _healthAlerts = List<Map<String, dynamic>>.from(data['healthAlerts'] ?? []);
          _activeMedications = List<Map<String, dynamic>>.from(data['activeMedications'] ?? []);
          _recentVitals = (data['recentVitals'] as List).map((v) {
            return {
              'date': v['date']?.toString() ?? '',
              'bloodPressureSys': (v['bloodPressureSys'] as num?)?.toInt() ?? 0,
              'bloodPressureDia': (v['bloodPressureDia'] as num?)?.toInt() ?? 0,
              'heartRate': (v['heartRate'] as num?)?.toInt() ?? 0,
              'weight': (v['weight'] as num?)?.toInt() ?? 0,
            };
          }).toList();
          
          // Fallback to local cache if server is behind
          final localVital = DashboardService.getLastLoggedVital();
          if (_recentVitals.isEmpty || (localVital != null && _recentVitals.first['date'] != 'Just Now')) {
            if (localVital != null) {
              _recentVitals.insert(0, localVital);
            }
          }
          
          // Use robust sorting newest first
          _recentVitals.sort((a, b) {
            try {
              DateTime da = _parseDateString(a['date']?.toString() ?? '');
              DateTime db = _parseDateString(b['date']?.toString() ?? '');
              return db.compareTo(da);
            } catch(_) { return 0; }
          });
          
          _labResults = List<Map<String, dynamic>>.from(data['labResults'] ?? []);
          _isLoading = false;
        });
      } else {
        if(mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Failed to load dashboard data: $e');
      if(mounted) setState(() => _isLoading = false);
    }
  }

  /// Helper to parse various date formats safely
  DateTime _parseDateString(String dateStr) {
    if (dateStr.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    final formats = ['MMM d yyyy', 'MMM dd yyyy', 'yyyy-MM-ddTHH:mm:ss', 'yyyy-MM-dd HH:mm:ss', 'yyyy-MM-dd'];
    String cleanDate = dateStr.trim();
    if (!cleanDate.contains(RegExp(r'\d{4}'))) {
      cleanDate = "$cleanDate ${DateTime.now().year}";
    }
    for (var format in formats) {
      try { return DateFormat(format).parse(cleanDate); } catch (_) { continue; }
    }
    try { return DateTime.parse(dateStr); } catch (e) { return DateTime.fromMillisecondsSinceEpoch(0); }
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
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.mainButton));
    }

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
                _buildQuickActionsList(languageCode, user),
                const SizedBox(height: 24),
                
                // Health Alerts from server
                if (_healthAlerts.isNotEmpty) ...[
                  ..._healthAlerts.map((alert) => _buildAnnouncementBanner(
                        alert['title'] ?? 'Health Alert',
                        alert['message'] ?? '',
                        Icons.warning_amber_rounded,
                        isDanger: alert['type'] == 'danger',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicalRecordsPage(),
                            ),
                          ).then((_) => _loadDashboardData());
                        },
                      )),
                  const SizedBox(height: 16),
                ],
                
                // Show Vitals Summary Card if data exists
                if (_recentVitals.isNotEmpty) ...[
                  _buildLatestVitalsCard(languageCode),
                  const SizedBox(height: 24),
                ],
                
                // Specific Blood Pressure Check - Decoupled from generic alerts
                if (_recentVitals.isNotEmpty && (_recentVitals.first['bloodPressureSys'] > 130 || _recentVitals.first['bloodPressureDia'] > 85)) ...[
                   _buildAnnouncementBanner(
                        'High Blood Pressure Alert',
                        'DANGER: Your last reading was ${_recentVitals.first['bloodPressureSys']}/${_recentVitals.first['bloodPressureDia']}. Please rest and consult your doctor.',
                        Icons.warning_amber_rounded,
                        isDanger: true,
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicalRecordsPage(),
                            ),
                          ).then((_) => _loadDashboardData());
                        }
                      ),
                  const SizedBox(height: 24),
                ] else if (_healthAlerts.isEmpty) ... [
                  // Show lab result update only if no alerts exist to keep UI clean
                  _buildAnnouncementBanner(
                    AppStrings.get('healthUpdate', languageCode),
                    AppStrings.get(
                      'labPendingReview',
                      languageCode,
                    ).replaceAll('{count}', _labResults.length.toString()),
                    Icons.health_and_safety,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LabResultsPage(initialResults: _labResults),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                
                _buildWeeklySummary(languageCode),
                
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

  Widget _buildWeeklySummary(String languageCode) {
    if (_recentVitals.isEmpty) return const SizedBox.shrink();

    int totalSys = 0;
    int totalDia = 0;
    int count = _recentVitals.length;

    for (var v in _recentVitals) {
      totalSys += (v['bloodPressureSys'] as num?)?.toInt() ?? 0;
      totalDia += (v['bloodPressureDia'] as num?)?.toInt() ?? 0;
    }

    int avgSys = count > 0 ? (totalSys ~/ count) : 0;
    int avgDia = count > 0 ? (totalDia ~/ count) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD77E).withOpacity(0.5)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFCBD77E).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics, color: Color(0xFF282828), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('weeklySummary', languageCode),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF282828),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Avg BP: $avgSys/$avgDia mmHg\nEntries: $count recorded this week",
                  style: TextStyle(
                    color: const Color(0xFF282828).withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.monitor_heart, color: Color(0xFFCBD77E)),
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
              _cancelAppointment(apt['id'].toString(), languageCode);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(String id, String languageCode) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFCBD77E)),
      ),
    );

    bool success = await DashboardService.cancelAppointment(id);

    if (mounted) Navigator.pop(context); // Hide loading

    if (success) {
      if (mounted) {
        setState(() {
          _upcomingAppointments.removeWhere((a) => a['id'].toString() == id);
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel appointment. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 15, right: 15),
            child: _buildAnimatedLogo(),
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
                    const SizedBox(width: 44), // Placeholder for balance
                    const SizedBox(width: 44), // Placeholder for balance
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Avatar moved above name
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
                                      color: const Color(0xFFE89B9B),
                                      child: const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: const Color(0xFFE89B9B),
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
                        user?.name ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF282828),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
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

  Widget _buildQuickActionsList(String languageCode, UserModel? user) {
    bool isDoctor = user != null && user.role.name == 'doctor';
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
            if (!isDoctor)
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
                  ).replaceAll('{count}', _activeMedications.length.toString()),
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
              if (isDoctor)
                _buildClinicCard(
                  'Manage Schedule',
                  Icons.calendar_month,
                  true,
                  onTap: () {
                    // Navigate to Doctor Schedule Management View
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorScheduleManagementScreen(),
                      ),
                    );
                  },
                )
              else ...[
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
                    ).then((_) => _loadDashboardData());
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
                    ).then((_) => _loadDashboardData());
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
                  AppStrings.get('callMyDoctors', languageCode).isEmpty ? 'Call My Doctors' : AppStrings.get('callMyDoctors', languageCode),
                  Icons.medical_services,
                  false,
                  onTap: () {
                    // Navigate to the new doctor selection screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorSelectionScreen(),
                      ),
                    );
                  },
                ),
              ],
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
    IconData icon, {
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    final bgColor = isDanger ? const Color(0xFFC62828) : const Color(0xFFCBD77E); // Vibrant Red for Danger
    final iconBgColor = isDanger ? Colors.white.withOpacity(0.2) : Colors.white;
    final iconColor = isDanger ? Colors.white : const Color(0xFFCBD77E);
    final textColor = isDanger ? Colors.white : const Color(0xFF282828);
    final subTextColor = isDanger ? Colors.white.withOpacity(0.9) : const Color(0xFF4A4A4A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: textColor, size: 24),
          ],
        ),
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

  Widget _buildLatestVitalsCard(String languageCode) {
    final latest = _recentVitals.first;
    final sys = latest['bloodPressureSys'] ?? 0;
    final dia = latest['bloodPressureDia'] ?? 0;
    final hr = latest['heartRate'] ?? 0;
    final weight = latest['weight'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Vitals',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF282828),
                ),
              ),
              Text(
                latest['date'] ?? '',
                style: TextStyle(
                  color: const Color(0xFF282828).withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVitalSummaryItem(Icons.favorite, sys > 130 ? Colors.red : const Color(0xFFCBD77E), '$sys/$dia', 'BP'),
              _buildVitalSummaryItem(Icons.bolt, const Color(0xFFCBD77E), '$hr', 'BPM'),
              _buildVitalSummaryItem(Icons.monitor_weight, const Color(0xFFCBD77E), '$weight', 'KG'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSummaryItem(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF282828),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF282828).withOpacity(0.6),
          ),
        ),
      ],
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
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
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
