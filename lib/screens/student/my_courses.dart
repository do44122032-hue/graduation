import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import 'course_details.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  // Color constants
  static const Color bgColor = Color(0xFFF7F7F7);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color charcoalColor = Color(0xFF282828);
  static const Color secondaryTextColor = Color(0xFF4A4A4A);
  static const Color accentOliveColor = Color(0xFFCBD77E);
  static const Color accentBeigeColor = Color(0xFFE8C998);

  final List<Course> courses = [
    Course(
      id: 'c1',
      title: 'Clinical Medicine III',
      instructor: 'Dr. Sarah Williams',
      progress: 0.75,
      nextClass: 'Mon, 9:00 AM', // Data - kept as is
      imageAsset: 'assets/images/course_medical.jpg', // Placeholder
      color: accentOliveColor,
      icon: Icons.monitor_heart_outlined,
      grade: 'A-',
    ),
    Course(
      id: 'c2',
      title: 'Surgical Techniques',
      instructor: 'Dr. James Wilson',
      progress: 0.45,
      nextClass: 'Tue, 2:00 PM',
      color: accentBeigeColor,
      icon: Icons.medical_services,
      grade: 'B+',
    ),
    Course(
      id: 'c3',
      title: 'Medical Ethics',
      instructor: 'Dr. Emily Rodriguez',
      progress: 0.90,
      nextClass: 'Completed',
      color: const Color(0xFF82C4E6),
      icon: Icons.gavel,
      grade: 'A',
    ),
    Course(
      id: 'c4',
      title: 'Clinical Pathology',
      instructor: 'Dr. Michael Chen',
      progress: 0.30,
      nextClass: 'Thu, 10:00 AM',
      color: const Color(0xFFFFB74D),
      icon: Icons.science,
      grade: 'Pending',
    ),
    Course(
      id: 'c5',
      title: 'Pharmacology',
      instructor: 'Dr. Lisa Chang',
      progress: 0.60,
      nextClass: 'Fri, 9:00 AM',
      color: const Color(0xFFB39DDB),
      icon: Icons.medication,
      grade: 'B',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentBeigeColor, Color(0xFFF5DDB8)],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('titleMyCourses', lang),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: charcoalColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.get('labelSemester1_2026', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: charcoalColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Featured/Last Accessed Course
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentOliveColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.play_circle_fill,
                          color: accentOliveColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get('labelResumeLearning', lang),
                              style: const TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Clinical Medicine III', // Data
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: charcoalColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: secondaryTextColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Course List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: courses.length + 1, // +1 for spacing
              itemBuilder: (context, index) {
                if (index == courses.length) {
                  return const SizedBox(height: 80); // Bottom padding
                }
                final course = courses[index];
                return _buildCourseCard(course, lang);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course, String lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailsScreen(course: course),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                course.grade == 'Pending'
                                    ? AppStrings.get('labelInProgress', lang)
                                    : AppStrings.get(
                                        'labelGrade',
                                        lang,
                                      ).replaceAll('{grade}', course.grade),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: course.grade == 'Pending'
                                      ? course.color
                                      : accentOliveColor,
                                ),
                              ),
                              Icon(Icons.more_horiz, color: Colors.grey[400]),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: charcoalColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.instructor,
                            style: const TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.get('labelProgress', lang),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                              ),
                              Text(
                                '${(course.progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: charcoalColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: course.progress,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF0F0F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                course.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.get(
                          'labelNext',
                          lang,
                        ).replaceAll('{time}', course.nextClass),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        AppStrings.get('actionViewDetails', lang),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: course.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: course.color),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
