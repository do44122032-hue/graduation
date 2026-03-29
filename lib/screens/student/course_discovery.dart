import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import 'package:provider/provider.dart';

class CourseDiscoveryScreen extends StatefulWidget {
  const CourseDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<CourseDiscoveryScreen> createState() => _CourseDiscoveryScreenState();
}

class _CourseDiscoveryScreenState extends State<CourseDiscoveryScreen> {
  static const Color bgColor = Color(0xFFF7F7F7);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color charcoalColor = Color(0xFF282828);
  static const Color secondaryTextColor = Color(0xFF4A4A4A);
  static const Color accentOliveColor = Color(0xFFCBD77E);

  Future<List<Course>>? _availableCoursesFuture;

  @override
  void initState() {
    super.initState();
    _loadAvailableCourses();
  }

  void _loadAvailableCourses() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      setState(() {
        _availableCoursesFuture = DashboardService.getAvailableCourses(user.id);
      });
    }
  }

  Future<void> _enroll(int courseId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null) return;

    final success = await DashboardService.enrollInCourse(user.id, courseId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the course!')),
      );
      _loadAvailableCourses(); // Refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join course.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context).currentLanguage;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('titleJoinNewCourse', lang),
          style: const TextStyle(color: charcoalColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: charcoalColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Course>>(
        future: _availableCoursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accentOliveColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.get('labelNoAvailableCourses', lang),
                      style: const TextStyle(color: secondaryTextColor, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final success = await DashboardService.seedCourses();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sample courses seeded successfully!')),
                          );
                          _loadAvailableCourses();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Courses already exist or failed to seed.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Seed Sample Courses'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOliveColor,
                        foregroundColor: charcoalColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final courses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildDiscoveryCard(course, lang);
            },
          );
        },
      ),
    );
  }

  Widget _buildDiscoveryCard(Course course, String lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: course.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(course.icon, color: course.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: charcoalColor),
                      ),
                      const SizedBox(height: 4),
                      Text(course.instructor, style: const TextStyle(fontSize: 13, color: secondaryTextColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _enroll(int.parse(course.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: course.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  AppStrings.get('actionJoinCourse', lang),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
