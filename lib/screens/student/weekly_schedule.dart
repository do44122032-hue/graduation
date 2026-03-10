import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

// Event model
class ScheduleEvent {
  final int id;
  final String title;
  final String
  type; // 'class', 'rotation', 'study', 'appointment', 'break', 'exam', 'meeting'
  final String startTime;
  final String endTime;
  final String location;
  final String? instructor;
  final int dayIndex; // 0 = Monday, 1 = Tuesday, etc.
  final Color color;
  final bool important;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.instructor,
    required this.dayIndex,
    required this.color,
    this.important = false,
  });
}

class WeeklySchedule extends StatefulWidget {
  const WeeklySchedule({Key? key}) : super(key: key);

  @override
  State<WeeklySchedule> createState() => _WeeklyScheduleState();
}

class _WeeklyScheduleState extends State<WeeklySchedule> {
  int? selectedDay;
  bool showFilters = false;

  // Color constants
  static const Color bgColor = Color(0xFFF7F7F7);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color charcoalColor = Color(0xFF282828);
  static const Color secondaryTextColor = Color(0xFF4A4A4A);
  static const Color accentOliveColor = Color(0xFFCBD77E);
  static const Color accentBeigeColor = Color(0xFFE8C998);

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> fullDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final List<int> dates = [5, 6, 7, 8, 9, 10, 11];

  List<ScheduleEvent> get scheduleEvents => [
    // Monday
    ScheduleEvent(
      id: 1,
      title: 'Clinical Medicine III',
      type: 'class',
      startTime: '9:00 AM',
      endTime: '11:00 AM',
      location: 'Lecture Hall A',
      instructor: 'Dr. Sarah Williams',
      dayIndex: 0,
      color: accentOliveColor,
    ),
    ScheduleEvent(
      id: 2,
      title: 'Internal Medicine Rounds',
      type: 'rotation',
      startTime: '1:00 PM',
      endTime: '4:00 PM',
      location: 'Ward 3B',
      instructor: 'Dr. Michael Chen',
      dayIndex: 0,
      color: accentBeigeColor,
      important: true,
    ),
    ScheduleEvent(
      id: 3,
      title: 'Study Group - Cardiology',
      type: 'study',
      startTime: '5:00 PM',
      endTime: '7:00 PM',
      location: 'Library Room 204',
      dayIndex: 0,
      color: const Color(0xFF82C4E6),
    ),
    // Tuesday
    ScheduleEvent(
      id: 4,
      title: 'Pharmacology Lecture',
      type: 'class',
      startTime: '8:00 AM',
      endTime: '10:00 AM',
      location: 'Lecture Hall B',
      instructor: 'Dr. Michael Chen',
      dayIndex: 1,
      color: accentOliveColor,
    ),
    ScheduleEvent(
      id: 5,
      title: 'Patient Case Review',
      type: 'appointment',
      startTime: '10:30 AM',
      endTime: '12:00 PM',
      location: 'Conference Room 2',
      instructor: 'Dr. Emily Rodriguez',
      dayIndex: 1,
      color: const Color(0xFFFFB74D),
    ),
    ScheduleEvent(
      id: 6,
      title: 'Lunch Break',
      type: 'break',
      startTime: '12:00 PM',
      endTime: '1:00 PM',
      location: 'Cafeteria',
      dayIndex: 1,
      color: const Color(0xFFE0E0E0),
    ),
    ScheduleEvent(
      id: 7,
      title: 'Clinical Skills Lab',
      type: 'rotation',
      startTime: '2:00 PM',
      endTime: '5:00 PM',
      location: 'Skills Lab - Building C',
      instructor: 'Dr. James Wilson',
      dayIndex: 1,
      color: accentBeigeColor,
    ),
    // Wednesday
    ScheduleEvent(
      id: 8,
      title: 'Pathophysiology',
      type: 'class',
      startTime: '10:30 AM',
      endTime: '12:30 PM',
      location: 'Lecture Hall A',
      instructor: 'Dr. Emily Rodriguez',
      dayIndex: 2,
      color: accentOliveColor,
    ),
    ScheduleEvent(
      id: 9,
      title: 'Cardiovascular Exam',
      type: 'exam',
      startTime: '2:00 PM',
      endTime: '4:00 PM',
      location: 'Testing Center',
      dayIndex: 2,
      color: const Color(0xFFE57373),
      important: true,
    ),
    ScheduleEvent(
      id: 10,
      title: 'Study Session',
      type: 'study',
      startTime: '6:00 PM',
      endTime: '8:00 PM',
      location: 'Home',
      dayIndex: 2,
      color: const Color(0xFF82C4E6),
    ),
    // Thursday
    ScheduleEvent(
      id: 11,
      title: 'Morning Rounds',
      type: 'rotation',
      startTime: '7:00 AM',
      endTime: '9:00 AM',
      location: 'Ward 3B',
      instructor: 'Dr. Michael Chen',
      dayIndex: 3,
      color: accentBeigeColor,
    ),
    ScheduleEvent(
      id: 12,
      title: 'Clinical Medicine III',
      type: 'class',
      startTime: '10:00 AM',
      endTime: '12:00 PM',
      location: 'Lecture Hall A',
      instructor: 'Dr. Sarah Williams',
      dayIndex: 3,
      color: accentOliveColor,
    ),
    ScheduleEvent(
      id: 13,
      title: 'Department Meeting',
      type: 'meeting',
      startTime: '1:00 PM',
      endTime: '2:00 PM',
      location: 'Conference Room 1',
      dayIndex: 3,
      color: const Color(0xFFB39DDB),
    ),
    ScheduleEvent(
      id: 14,
      title: 'Patient Consultations',
      type: 'appointment',
      startTime: '2:30 PM',
      endTime: '5:30 PM',
      location: 'Clinic - Building A',
      instructor: 'Dr. Emily Rodriguez',
      dayIndex: 3,
      color: const Color(0xFFFFB74D),
    ),
    // Friday
    ScheduleEvent(
      id: 15,
      title: 'Pharmacology',
      type: 'class',
      startTime: '9:00 AM',
      endTime: '11:00 AM',
      location: 'Lecture Hall B',
      instructor: 'Dr. Michael Chen',
      dayIndex: 4,
      color: accentOliveColor,
    ),
    ScheduleEvent(
      id: 16,
      title: 'Case Presentation Prep',
      type: 'study',
      startTime: '11:30 AM',
      endTime: '1:30 PM',
      location: 'Study Room 305',
      dayIndex: 4,
      color: const Color(0xFF82C4E6),
    ),
    ScheduleEvent(
      id: 17,
      title: 'Grand Rounds',
      type: 'meeting',
      startTime: '2:00 PM',
      endTime: '3:30 PM',
      location: 'Main Auditorium',
      instructor: 'Various Speakers',
      dayIndex: 4,
      color: const Color(0xFFB39DDB),
      important: true,
    ),
    // Saturday
    ScheduleEvent(
      id: 18,
      title: 'Weekend Rotation',
      type: 'rotation',
      startTime: '8:00 AM',
      endTime: '2:00 PM',
      location: 'Emergency Department',
      instructor: 'Dr. Sarah Williams',
      dayIndex: 5,
      color: accentBeigeColor,
    ),
    ScheduleEvent(
      id: 19,
      title: 'Self-Study',
      type: 'study',
      startTime: '3:00 PM',
      endTime: '6:00 PM',
      location: 'Home',
      dayIndex: 5,
      color: const Color(0xFF82C4E6),
    ),
    // Sunday
    ScheduleEvent(
      id: 20,
      title: 'Exam Review',
      type: 'study',
      startTime: '10:00 AM',
      endTime: '1:00 PM',
      location: 'Library',
      dayIndex: 6,
      color: const Color(0xFF82C4E6),
    ),
  ];

  List<ScheduleEvent> getEventsForDay(int dayIndex) {
    return scheduleEvents.where((event) => event.dayIndex == dayIndex).toList()
      ..sort((a, b) {
        int timeA = int.parse(a.startTime.split(':')[0]);
        int timeB = int.parse(b.startTime.split(':')[0]);
        return timeA.compareTo(timeB);
      });
  }

  IconData getEventIcon(String type) {
    switch (type) {
      case 'class':
        return Icons.school;
      case 'rotation':
        return Icons.local_hospital;
      case 'study':
        return Icons.menu_book;
      case 'appointment':
        return Icons.people;
      case 'break':
        return Icons.local_cafe;
      case 'exam':
        return Icons.warning_amber;
      case 'meeting':
        return Icons.video_call;
      default:
        return Icons.calendar_today;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;
    final dateLang = lang == 'ku' ? 'ar' : lang;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accentOliveColor, accentBeigeColor],
                ),
              ),
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderButton(Icons.arrow_back),
                        Text(
                          AppStrings.get('titleWeeklySchedule', lang),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: charcoalColor,
                          ),
                        ),
                        _buildHeaderButton(Icons.filter_list),
                      ],
                    ),
                  ),
                  // Week navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildNavButton(Icons.chevron_left),
                          Column(
                            children: [
                              Text(
                                '${DateFormat("MMM d", dateLang).format(DateTime(2026, 1, 5))} - ${DateFormat("d, y", dateLang).format(DateTime(2026, 1, 11))}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: charcoalColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${AppStrings.get("labelWeek", lang)} 1 • ${scheduleEvents.length} ${AppStrings.get("labelEvents", lang)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          _buildNavButton(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  // Days of week
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: List.generate(7, (index) {
                        bool isToday = index == 0;
                        bool isSelected = selectedDay == index;
                        List<ScheduleEvent> dayEvents = getEventsForDay(index);

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDay = isSelected ? null : index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? whiteColor
                                    : isToday
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? charcoalColor
                                      : isToday
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.4),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    DateFormat(
                                      "E",
                                      dateLang,
                                    ).format(DateTime(2026, 1, dates[index])),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: charcoalColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${dates[index]}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: charcoalColor,
                                    ),
                                  ),
                                  if (dayEvents.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        dayEvents.length > 3
                                            ? 3
                                            : dayEvents.length,
                                        (i) => Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accentOliveColor,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildActionButton(
                    AppStrings.get('actionAddEvent', lang),
                    Icons.add,
                    accentOliveColor,
                    charcoalColor,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    AppStrings.get('actionExport', lang),
                    Icons.download,
                    whiteColor,
                    secondaryTextColor,
                    borderColor: const Color(0xFFE0E0E0),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    AppStrings.get('actionShare', lang),
                    Icons.share,
                    whiteColor,
                    secondaryTextColor,
                    borderColor: const Color(0xFFE0E0E0),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: selectedDay != null
                  ? _buildSingleDayView(lang, dateLang)
                  : _buildWeekOverview(lang, dateLang),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 20, color: charcoalColor),
    );
  }

  Widget _buildNavButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Icon(icon, size: 18, color: charcoalColor),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color bgColor,
    Color textColor, {
    Color? borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleDayView(String lang, String dateLang) {
    List<ScheduleEvent> dayEvents = getEventsForDay(selectedDay!);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat(
                'EEEE, MMMM d',
                dateLang,
              ).format(DateTime(2026, 1, dates[selectedDay!])),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: charcoalColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${dayEvents.length} ${AppStrings.get('labelEvents', lang)}',
              style: const TextStyle(fontSize: 12, color: secondaryTextColor),
            ),
            const SizedBox(height: 16),
            ...dayEvents.map((event) => _buildEventCard(event, detailed: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekOverview(String lang, String dateLang) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
      children: [
        ...List.generate(7, (dayIndex) {
          List<ScheduleEvent> dayEvents = getEventsForDay(dayIndex);
          if (dayEvents.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat(
                        'EEEE, MMM d',
                        dateLang,
                      ).format(DateTime(2026, 1, dates[dayIndex])),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: charcoalColor,
                      ),
                    ),
                    Text(
                      '${dayEvents.length} event${dayEvents.length != 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 11, color: secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...dayEvents.map(
                  (event) => _buildEventCard(event, dayIndex: dayIndex),
                ),
              ],
            ),
          );
        }),
        _buildLegend(lang),
      ],
    );
  }

  Widget _buildEventCard(
    ScheduleEvent event, {
    bool detailed = false,
    int? dayIndex,
  }) {
    if (detailed) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: event.important ? event.color : const Color(0xFFE0E0E0),
            width: event.important ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: event.color, width: 2),
              ),
              child: Icon(
                getEventIcon(event.type),
                size: 14,
                color: charcoalColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: charcoalColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${event.startTime} - ${event.endTime}',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (event.instructor != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 12, color: secondaryTextColor),
                        const SizedBox(width: 6),
                        Text(
                          event.instructor!,
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (event.important)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (dayIndex != null) {
            setState(() {
              selectedDay = dayIndex;
            });
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: event.color, width: 4)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(getEventIcon(event.type), size: 14, color: event.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: charcoalColor,
                      ),
                    ),
                  ),
                  if (event.important)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE57373),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${event.startTime} - ${event.endTime}',
                    style: TextStyle(fontSize: 11, color: secondaryTextColor),
                  ),
                  Text(
                    event.location,
                    style: TextStyle(fontSize: 10, color: secondaryTextColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLegend(String lang) {
    final legendItems = [
      {'type': AppStrings.get('labelClass', lang), 'color': accentOliveColor},
      {
        'type': AppStrings.get('labelRotation', lang),
        'color': accentBeigeColor,
      },
      {
        'type': AppStrings.get('labelStudy', lang),
        'color': const Color(0xFF82C4E6),
      },
      {
        'type': AppStrings.get('labelAppointment', lang),
        'color': const Color(0xFFFFB74D),
      },
      {
        'type': AppStrings.get('labelExam', lang),
        'color': const Color(0xFFE57373),
      },
      {
        'type': AppStrings.get('labelMeeting', lang),
        'color': const Color(0xFFB39DDB),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('labelLegend', lang),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: charcoalColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: legendItems.map((item) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 88) / 2,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['type'] as String,
                      style: TextStyle(fontSize: 11, color: secondaryTextColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
