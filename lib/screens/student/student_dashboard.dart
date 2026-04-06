import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/modern_horizontal_nav_bar.dart';
import 'patient_case_study.dart';
import 'my_courses.dart';
import 'student_settings.dart';
import 'student_profile.dart';
import '../../services/dashboard_service.dart';
import '../../models/user_model.dart';
import '../../models/student_report_model.dart';
import '../../models/student_task_model.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _activeTabId = 'home';

  // Colors
  static const Color orangePrimary = Color(0xFFE8C998);
  static const Color orangeLight = Color(0xFFF9F3E5);

  // Student State
  String? _selectedDoctor;
  List<UserModel> _realDoctors = [];
  bool _isLoadingDoctors = false;

  Future<void> _loadDoctors() async {
    setState(() => _isLoadingDoctors = true);
    try {
      final doctors = await DashboardService.fetchActiveDoctors();
      if (mounted) {
        setState(() {
          _realDoctors = doctors;
          _isLoadingDoctors = false;
        });
      }
    } catch (e) {
      print('Error loading doctors for student: $e');
      if (mounted) setState(() => _isLoadingDoctors = false);
    }
  }


  void _showHospitalInfo(String languageCode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle for bottom sheet
            Center(
              child: Container(
                margin: const EdgeInsetsDirectional.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Large Hospital Image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'C:/Users/User/.gemini/antigravity/brain/ca0bd178-e7d3-4763-b245-8cbeb6400837/hospital_building_1767119126123.png',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.local_hospital,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      AppStrings.get('hospitalName', languageCode),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: orangePrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.get('hospitalAddress', languageCode),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Info Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            AppStrings.get('labelDepartments', languageCode),
                            '24',
                            Icons.domain,
                            const Color(0xFFCBD77E),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            AppStrings.get('toolDoctors', languageCode),
                            '350+',
                            Icons.people_alt,
                            const Color(0xFFCBD77E),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            AppStrings.get('labelBeds', languageCode),
                            '1200',
                            Icons.bed,
                            const Color(0xFFCBD77E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        AppStrings.get('aboutUs', languageCode),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.get('hospitalDesc', languageCode),
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: Text(AppStrings.get('closeInfo', languageCode)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : const Color(0xFFCBD77E).withOpacity(0.1),
                          foregroundColor: const Color(0xFFCBD77E),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Famous Doctor Case Studies Data
  List<Map<String, String>> _getCaseStudies(String languageCode) {
    return [
      {
        'title': 'Complex Type 1 Diabetes',
        'doctorName': 'Dr. Michael Chen',
        'specialty': AppStrings.get('specCardiology', languageCode),
        'date': '15 Oct 2024',
        'description':
            'A comprehensive study on managing difficult Type 1 Diabetes cases in adolescents, focusing on insulin pump therapy and continuous glucose monitoring. This case explores the challenges of hormonal changes and lifestyle adjustments.',
        'image':
            'C:/Users/User/.gemini/antigravity/brain/120b4062-e932-4172-987c-a248d6ea9a46/supervisor_profile_1_1767109633858.png',
      },
      {
        'title': 'Early Melanoma Detection',
        'doctorName': 'Prof. Sarah Miller',
        'specialty': AppStrings.get('specDermatology', languageCode),
        'date': '10 Oct 2024',
        'description':
            'This case highlights the subtle signs of early-stage melanoma that are often missed in routine checks. Prof. Miller discusses dermatoscopy patterns and the importance of rapid biopsy in suspicious lesions.',
        'image':
            'C:/Users/User/.gemini/antigravity/brain/120b4062-e932-4172-987c-a248d6ea9a46/supervisor_profile_2_1767109648441.png',
      },
      {
        'title': 'Geriatric Hypertension',
        'doctorName': 'Dr. Ahmed Khalid',
        'specialty': AppStrings.get('specCardiology', languageCode),
        'date': '05 Oct 2024',
        'description':
            'Managing hypertension in patients over 80 requires a delicate balance. Dr. Khalid presents a case study on resistant hypertension in an elderly patient with multiple comorbidities, discussing medication choices and side effect management.',
        'image':
            'C:/Users/User/.gemini/antigravity/brain/120b4062-e932-4172-987c-a248d6ea9a46/supervisor_profile_3_1767109667047.png',
      },
      {
        'title': 'Rare Autoimmune Disorder',
        'doctorName': 'Dr. Emily Wong',
        'specialty': 'Immunology',
        'date': '28 Sep 2024',
        'description':
            'An unusual presentation of a rare autoimmune condition. This case walks through the diagnostic journey, from initial confusing symptoms to the definitive lab tests and successful treatment plan.',
        'image': '', // Fallback to icon
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _animationController.forward();
    _loadDoctors();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Tab Content
            Positioned.fill(child: _buildContent(languageCode)),

            // Floating Navigation Bar
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 20,
              child: Center(
                child: ModernHorizontalNavBar(
                  activeTab: _activeTabId,
                  activeColor: orangePrimary, // Student Theme Color
                  languageCode: languageCode,
                  navItems: [
                    ModernNavItem(
                      id: 'home',
                      icon: Icons.school_outlined,
                      label: AppStrings.get('navHome', languageCode),
                    ),
                    ModernNavItem(
                      id: 'cases',
                      icon: Icons.library_books_outlined,
                      label: AppStrings.get('navCases', languageCode),
                    ),
                    ModernNavItem(
                      id: 'courses',
                      icon: Icons.menu_book_outlined,
                      label: AppStrings.get('navCourses', languageCode),
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
      case 'courses':
        return _buildCoursesPage(languageCode);
      case 'cases':
        return _buildCaseStudiesPage(languageCode);
      case 'settings':
        return const StudentSettingsScreen();
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
                FutureBuilder<List<StudentTaskModel>>(
                  future: DashboardService.getStudentTasks(user?.id ?? ''),
                  builder: (context, snapshot) {
                    final tasks = snapshot.data ?? [];
                    final pendingTask = tasks.firstWhere(
                      (t) => t.status != 'completed',
                      orElse: () => StudentTaskModel(
                        id: 0,
                        title: AppStrings.get('pendingAssignment', languageCode),
                        description: AppStrings.get('assignmentDesc', languageCode),
                        status: 'none',
                        dueDate: '',
                      ),
                    );

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildTaskBannerLoading();
                    }

                    return _buildTaskBanner(
                      pendingTask.title,
                      pendingTask.dueDate.isNotEmpty 
                        ? '${AppStrings.get('labelDue', languageCode).split('{date}')[0]}${pendingTask.dueDate}'
                        : pendingTask.description,
                      Icons.assignment_late,
                      onTap: _showAssignmentsDialog,
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildAcademicInfoList(languageCode, user),
                const SizedBox(height: 120), // Height for nav bar
              ],
            ),
          ),
        ],
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
                end: Alignment.bottomRight,
                colors: [orangePrimary, orangeLight],
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 15, end: 15),
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
                              builder: (context) => const StudentProfileScreen(),
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
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.1) ?? Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                                ? Image.network(
                                    user.profilePicture!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [orangePrimary, orangeLight],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [orangePrimary, orangeLight],
                                      ),
                                    ),
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
                        user?.name ?? 'Alex Thompson',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: orangePrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.school,
                                  size: 14,
                                  color: orangePrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.get(
                                    'gpaLabel',
                                    languageCode,
                                  ).replaceAll('{value}', '3.82'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: orangePrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.get(
                              'idLabel',
                              languageCode,
                            ).replaceAll('{value}', '2024-88429'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
              AppStrings.get('universityTools', languageCode),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF282828),
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all tools
              },
              child: Row(
                children: [
                  Text(
                    AppStrings.get('seeAll', languageCode),
                    style: TextStyle(
                      color: orangePrimary.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: orangePrimary.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150, // Increased to accommodate square cards
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ), // Match screen side padding
            children: [
              _buildToolCard(
                AppStrings.get('toolHospital', languageCode),
                Icons.local_hospital_outlined,
                true,
                languageCode,
                onTap: () => _showHospitalInfo(languageCode),
                showImage: true,
                customImage:
                    'C:/Users/User/.gemini/antigravity/brain/ca0bd178-e7d3-4763-b245-8cbeb6400837/hospital_building_1767119126123.png',
                color: const Color(0xFFCBD77E),
              ),
              _buildToolCard(
                AppStrings.get('toolDoctors', languageCode),
                Icons.people_alt_outlined,
                true,
                languageCode,
                onTap: () => _showDoctorSelection(languageCode),
                showImage: true,
                color: const Color(0xFFE8C998),
              ),
              _buildToolCard(
                AppStrings.get('toolReports', languageCode),
                Icons.upload_file_outlined,
                true,
                languageCode,
                onTap: _showSubmitReportDialog,
                color: const Color(0xFF9B8FD9),
              ),
              _buildToolCard(
                AppStrings.get('toolTasks', languageCode),
                Icons.assignment_outlined,
                true,
                languageCode,
                onTap: _showAssignmentsDialog,
                color: const Color(0xFFE89B9B),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolCard(
    String name,
    IconData icon,
    bool isActive,
    String languageCode, {
    String? subtitle,
    VoidCallback? onTap,
    bool showImage = false,
    String? customImage,
    Color? color,
  }) {
    final cardColor = color ?? orangePrimary;
    String? displayImage = customImage;
    if (showImage && customImage == null && _selectedDoctor != null) {
      try {
        final doctor = _realDoctors.firstWhere((d) => d.name == _selectedDoctor);
        displayImage = doctor.profilePicture;
      } catch (_) {
        displayImage = null;
      }
    }

    return _InteractiveToolCard(
      name: name,
      icon: icon,
      subtitle: subtitle,
      onTap: onTap,
      cardColor: cardColor,
      displayImage: displayImage,
    );
  }

  Widget _buildTaskBanner(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: orangePrimary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: orangePrimary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: orangePrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
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
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF282828).withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: orangePrimary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskBannerLoading() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: orangePrimary),
        ),
      ),
    );
  }

  Widget _buildAcademicInfoList(String languageCode, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF282828).withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildAcademicCard(
                AppStrings.get('currentLevel', languageCode),
                AppStrings.get('year4', languageCode),
                AppStrings.get('modeClinical', languageCode),
                Icons.school_outlined,
                const Color(0xFFE8C998), // orangePrimary
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _showAttendanceDialog,
                borderRadius: BorderRadius.circular(12),
                child: _buildAttendanceCard(
                  AppStrings.get('labelAttendance', languageCode),
                  '94%',
                  Colors.green, // Success color for good attendance
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicCard(
    String label,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: (Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF282828))
                  .withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF282828),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 2.0),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(String label, String value, Color color) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 0.94, // 94%
                    backgroundColor: color.withOpacity(0.1),
                    color: color,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: (Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF282828))
                  .withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesPage(String languageCode) {
    return const MyCoursesScreen();
  }

  Widget _buildCaseStudiesPage(String languageCode) {
    return Column(
      children: [
        _buildGradientAppBar(
          title: AppStrings.get('caseStudyTitle', languageCode),
          subtitle: AppStrings.get('commonCases', languageCode),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final studies = _getCaseStudies(languageCode);
              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: studies.length + 1, // +1 for spacing at bottom
                itemBuilder: (context, index) {
                  if (index == studies.length) {
                    return const SizedBox(height: 100);
                  }
                  final study = studies[index];
                  return _buildCaseStudyCard(context, study, languageCode);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCaseStudyCard(BuildContext context, Map<String, String> study, String languageCode) {
    final hasImage = study['image'] != null && study['image']!.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showCaseStudyDetails(study),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Image or Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: orangePrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: orangePrimary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: hasImage
                            ? Image.asset(
                                study['image']!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.person,
                                  color: orangePrimary,
                                  size: 30,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: orangePrimary,
                                size: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Doctor Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            study['title']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF282828),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                AppStrings.get('labelBy', languageCode),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  study['doctorName']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: orangePrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            study['specialty']! + ' • ' + study['date']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? orangePrimary.withOpacity(0.15) : const Color(0xFFF9F3E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      AppStrings.get('actionViewCaseStudy', languageCode),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: orangePrimary,
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

  void _showCaseStudyDetails(Map<String, String> study) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientCaseStudy()),
    );
  }

  // Helper method for consistent Gradient AppBar
  Widget _buildGradientAppBar({
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.only(start: 24, end: 24, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: Alignment.bottomRight,
          colors: [orangePrimary, orangeLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF282828),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF282828).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDoctorSelection(String languageCode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.get('titleFindDoctor', languageCode),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (_isLoadingDoctors)
                const Center(child: CircularProgressIndicator(color: orangePrimary))
              else if (_realDoctors.isEmpty)
                const Text('No doctors available in the database.')
              else
                ..._realDoctors.map(
                  (doctor) => Container(
                    margin: const EdgeInsetsDirectional.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: _selectedDoctor == doctor.name
                          ? orangePrimary.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedDoctor == doctor.name
                            ? orangePrimary
                            : Colors.grey.withOpacity(0.2),
                        width: _selectedDoctor == doctor.name ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: orangePrimary, width: 2),
                        ),
                        child: ClipOval(
                          child: doctor.profilePicture != null && doctor.profilePicture!.isNotEmpty
                              ? Image.network(
                                  doctor.profilePicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildInitialsPlaceholder(doctor.name),
                                )
                              : _buildInitialsPlaceholder(doctor.name),
                        ),
                      ),
                      title: Text(
                        doctor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        doctor.department ?? 'General Physician',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      onTap: () {
                        setState(() => _selectedDoctor = doctor.name);
                        Navigator.pop(context);
                      },
                      trailing: _selectedDoctor == doctor.name
                          ? const Icon(
                              Icons.check_circle,
                              color: orangePrimary,
                              size: 28,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: Colors.grey[300],
                              size: 28,
                            ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitialsPlaceholder(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            orangePrimary,
            orangeLight,
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'D',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSubmitReportDialog({String? initialTitle}) {
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLanguage;
    showDialog(
      context: context,
      builder: (context) {
        String reportTitle = initialTitle ?? '';
        String reportDescription = '';
        int? selectedDoctorId;
        Uint8List? selectedFileBytes;
        String? selectedFileName;
        bool isSubmitting = false;
        final titleController = TextEditingController(text: reportTitle);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B8FD9).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.upload_file,
                          color: Color(0xFF9B8FD9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.get('labelSubmitReport', languageCode),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.grey),
                    tooltip: AppStrings.get('labelHistory', languageCode),
                    onPressed: () {
                      Navigator.pop(context);
                      _showSubmittedReportsHistory();
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('labelReportTitle', languageCode),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      onChanged: (value) => reportTitle = value,
                      decoration: InputDecoration(
                        hintText: AppStrings.get('hintReportTitle', languageCode),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.get('labelReportDesc', languageCode),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) => reportDescription = value,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: AppStrings.get('hintReportDesc', languageCode),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.get('labelSupervisorDoctor', languageCode),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: selectedDoctorId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      hint: Text(AppStrings.get('hintSelectDoctor', languageCode)),
                      items: _realDoctors.map((doc) {
                        return DropdownMenuItem<int>(
                          value: int.parse(doc.id),
                          child: Text(doc.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedDoctorId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B8FD9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF9B8FD9).withOpacity(0.3),
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file, color: const Color(0xFF9B8FD9)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedFileName != null ? AppStrings.get('labelFileAttached', languageCode) : AppStrings.get('labelAttachFile', languageCode),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  selectedFileName ?? AppStrings.get('msgFileFormat', languageCode),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                final bytes = await pickedFile.readAsBytes();
                                setDialogState(() {
                                  selectedFileBytes = bytes;
                                  selectedFileName = pickedFile.name;
                                });
                              }
                            },
                            child: Text(
                              AppStrings.get('actionBrowse', languageCode),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: Text(
                    AppStrings.get('actionCancel', languageCode),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (reportTitle.isEmpty || selectedDoctorId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppStrings.get('msgTitleDoctorRequired', languageCode))),
                            );
                            return;
                          }
                          setDialogState(() => isSubmitting = true);
                          final authService = Provider.of<AuthService>(context, listen: false);
                          final uid = authService.currentUser?.id;
                          if (uid != null) {
                            bool success = await DashboardService.submitStudentReport(
                              uid: uid,
                              doctorId: selectedDoctorId!,
                              title: reportTitle,
                              description: reportDescription,
                              fileBytes: selectedFileBytes,
                              fileName: selectedFileName,
                            );

                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppStrings.get('msgReportSubmitted', languageCode),
                                  ),
                                  backgroundColor: const Color(0xFF9B8FD9),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppStrings.get('msgReportSubmitError', languageCode))),
                              );
                            }
                          }
                          setDialogState(() => isSubmitting = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B8FD9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(AppStrings.get('actionSubmit', languageCode)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showSubmittedReportsHistory() {
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLanguage;
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.currentUser?.id ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(AppStrings.get('titleSubmittedReports', languageCode)),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<StudentReportModel>>(
              future: DashboardService.getStudentReports(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF9B8FD9)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      AppStrings.get('errorLoadReports', languageCode),
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }

                final reports = snapshot.data ?? [];

                  if (reports.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(AppStrings.get('msgNoReports', languageCode)),
                      ),
                    );
                  }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    DateTime? subDate;
                    try {
                      subDate = DateTime.parse(report.submittedAt);
                    } catch (_) {}

                    String formattedDate = subDate != null
                        ? DateFormat('MMM dd, yyyy').format(subDate)
                        : report.submittedAt;

                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(report.title),
                      subtitle: Text(AppStrings.get('msgSubmittedAt', languageCode)
                          .replaceAll('{date}', formattedDate)
                          .replaceAll('{id}', report.doctorId.toString())),
                      isThreeLine: true,
                      onTap: () {
                        // View report details if needed
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get('close', languageCode)),
            ),
          ],
        );
      },
    );
  }

  void _showAssignmentsDialog() {
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLanguage;
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.currentUser?.id ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(AppStrings.get('titleAssignments', languageCode)),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<StudentTaskModel>>(
              future: DashboardService.getStudentTasks(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFE89B9B)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading tasks',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }

                final tasks = snapshot.data ?? [];

                return ListView(
                  shrinkWrap: true,
                  children: [
                    if (tasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text(AppStrings.get('msgNoTasks', languageCode))),
                      ),
                    ...tasks.map((task) => _buildAssignmentItem(task, languageCode)),
                    const Divider(),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, color: Colors.black54),
                      ),
                      title: Text(
                        AppStrings.get('actionUploadAssignment', languageCode),
                      ),
                      subtitle: Text(
                        AppStrings.get('descUploadAssignment', languageCode),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showSubmitReportDialog(initialTitle: '[Assignment] ');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get('closeInfo', languageCode)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssignmentItem(
    StudentTaskModel task,
    String languageCode,
  ) {
    // Parse color from hex
    Color cardColor;
    try {
      cardColor = Color(int.parse("FF${task.colorHex}", radix: 16));
    } catch (_) {
      cardColor = Colors.orange;
    }

    bool isCompleted = task.status == 'completed';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isCompleted ? Icons.check_circle : Icons.assignment,
          color: isCompleted ? Colors.green : cardColor,
        ),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.dueDate.isNotEmpty
                ? '${AppStrings.get('labelDue', languageCode).split('{date}')[0]}${task.dueDate}'
                : task.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (task.fileUrl != null && task.fileUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 4),
              child: InkWell(
                onTap: () async {
                  final fullUrl = DashboardService.baseUrl + task.fileUrl!;
                  if (await canLaunchUrl(Uri.parse(fullUrl))) {
                    await launchUrl(Uri.parse(fullUrl));
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attach_file, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'View Document',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: isCompleted ? null : () async {
          final success = await DashboardService.completeStudentTask(task.id);
          if (success) {
            Navigator.pop(context); // Close dialog to refresh
            _showAssignmentsDialog(); // Reopen to show new state
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.grey : cardColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          isCompleted ? 'Done' : AppStrings.get('actionView', languageCode),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void _showAttendanceDialog() {
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLanguage;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('titleMarkAttendance', languageCode),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('descScanQR', languageCode),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.get('msgAttendanceMarked', languageCode),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppStrings.get('actionScanQR', languageCode)),
              ),
            ],
          ),
        );
      },
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

class _InteractiveToolCard extends StatefulWidget {
  final String name;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color cardColor;
  final String? displayImage;

  const _InteractiveToolCard({
    required this.name,
    required this.icon,
    this.subtitle,
    this.onTap,
    required this.cardColor,
    this.displayImage,
  });

  @override
  State<_InteractiveToolCard> createState() => _InteractiveToolCardState();
}

class _InteractiveToolCardState extends State<_InteractiveToolCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 16.0),
          child: Column(
            children: [
              // Square Card Container (Matching Patient Mode style)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.cardColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.cardColor.withOpacity(0.3),
                    width: 1.5,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: widget.displayImage != null
                          ? (widget.displayImage!.startsWith('http') ||
                                  widget.displayImage!.startsWith('https')
                              ? Image.network(
                                  widget.displayImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        widget.icon,
                                        color: widget.cardColor,
                                        size: 32,
                                      ),
                                )
                              : Image.asset(
                                  widget.displayImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        widget.icon,
                                        color: widget.cardColor,
                                        size: 32,
                                      ),
                                ))
                          : Icon(
                              widget.icon,
                              color: widget.cardColor,
                              size: 32,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold, // Bolder to match patient mode
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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



