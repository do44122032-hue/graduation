import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import 'package:intl/intl.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String experience;
  final String specialtyId;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.specialtyId,
    required this.imageUrl,
  });
}

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({Key? key}) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  String searchQuery = '';
  String selectedSpecialty = 'All';
  String? selectedDate;
  String? selectedTime;
  bool bookingConfirmed = false;
  bool isBooking = false;
  bool _isLoadingDoctors = true;
  List<Doctor> _doctors = [];
  List<Map<String, dynamic>> _doctorSchedule = [];
  bool _isLoadingSchedule = false;
  bool _hasFetchedSchedule = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    print('DEBUG: Loading doctors from ${DashboardService.baseUrl}/users/doctors');
    setState(() {
      _isLoadingDoctors = true;
      _errorMessage = null;
    });
    try {
      final userModels = await DashboardService.fetchDoctors();
      if (mounted) {
        setState(() {
          _doctors = userModels.map((u) {
            return Doctor(
              id: u.id,
              name: u.name,
              specialty: u.department ?? 'General Practitioner',
              experience: u.bio ?? 'Experienced Doctor',
              specialtyId: (u.department ?? 'General Practitioner').toLowerCase(),
              imageUrl: u.profilePicture ?? 'https://via.placeholder.com/150',
            );
          }).toList();
          _isLoadingDoctors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDoctors = false;
          _errorMessage = e.toString();
        });
      }
      print('Error loading doctors: $e');
    }
  }

  List<Map<String, dynamic>> getSpecialties(String languageCode) => [
    {
      'id': 'all',
      'name': AppStrings.get('specAll', languageCode),
      'icon': Icons.medical_services,
    },
    {
      'id': 'cardiology',
      'name': AppStrings.get('specCardiology', languageCode),
      'icon': Icons.favorite,
    },
    {
      'id': 'neurology',
      'name': AppStrings.get('specNeurology', languageCode),
      'icon': Icons.psychology,
    },
    {
      'id': 'ophthalmology',
      'name': AppStrings.get('specOphthalmology', languageCode),
      'icon': Icons.remove_red_eye,
    },
    {
      'id': 'orthopedics',
      'name': AppStrings.get('specOrthopedics', languageCode),
      'icon': Icons.accessibility_new,
    },
    {
      'id': 'pediatrics',
      'name': AppStrings.get('specPediatrics', languageCode),
      'icon': Icons.child_care,
    },
  ];

  int _getWeekdayFromStr(String day) {
    switch (day.toLowerCase()) {
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      case 'sunday': return DateTime.sunday;
      default: return -1;
    }
  }

  List<Map<String, String>> getAvailableDates(List<Map<String, dynamic>> schedule) {
    if (schedule.isEmpty) return [];

    final today = DateTime.now();
    // Start with today at 00:00 to accurately compare days
    final todayMidnight = DateTime(today.year, today.month, today.day);

    final availableDays = schedule
        .where((s) => (s['isBooked'] ?? false) == false)
        .map((s) => s['day'] as String)
        .toSet()
        .toList();

    List<DateTime> availableDates = [];

    for (String dayName in availableDays) {
      int targetWeekday = _getWeekdayFromStr(dayName);
      if (targetWeekday != -1) {
        int daysUntil = (targetWeekday - todayMidnight.weekday + 7) % 7;
        DateTime nextOccurrence = todayMidnight.add(Duration(days: daysUntil));
        availableDates.add(nextOccurrence);
        availableDates.add(nextOccurrence.add(const Duration(days: 7)));
      }
    }

    // Sort chronologically
    availableDates.sort((a, b) => a.compareTo(b));
    
    // Remove duplicates
    final formatted = <String, Map<String, String>>{};
    final formatter = DateFormat('yyyy-MM-dd');

    for (var date in availableDates) {
      final dateStr = formatter.format(date);
      if (!formatted.containsKey(dateStr)) {
         formatted[dateStr] = {
           'date': dateStr,
           'label': DateFormat('EEE, MMM d').format(date)
         };
      }
    }

    return formatted.values.toList();
  }


  Future<void> _loadDoctorSchedule(Doctor doctor) async {
    if (_hasFetchedSchedule || _isLoadingSchedule) return;
    
    print('DEBUG: Requesting schedule for Doctor ${doctor.name} (ID: ${doctor.id})');
    if (setModalState != null) setModalState!(() => _isLoadingSchedule = true);
    setState(() => _isLoadingSchedule = true);
    try {
      final schedule = await DashboardService.fetchDoctorSchedule(doctor.id.toString());
      
      print('DEBUG: SUCCESS! Received ${schedule.length} slots for doctor ${doctor.name}');
      if (schedule.isNotEmpty) {
        print('DEBUG: First Slot Data Structure: ${schedule[0]}');
      }
      if (mounted) {
        if (setModalState != null) {
          setModalState!(() {
            _doctorSchedule = schedule;
            _isLoadingSchedule = false;
            _hasFetchedSchedule = true;
          });
        }
        setState(() {
          _doctorSchedule = schedule;
          _isLoadingSchedule = false;
          _hasFetchedSchedule = true;
        });
      }
    } catch (e) {
      print('DEBUG: Error in _loadDoctorSchedule: $e');
      if (mounted) {
        if (setModalState != null) {
          setModalState!(() {
            _isLoadingSchedule = false;
            _hasFetchedSchedule = true;
          });
        }
        setState(() {
          _isLoadingSchedule = false;
          _hasFetchedSchedule = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load schedule: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  StateSetter? setModalState;

  List<Doctor> get filteredDoctors {
    if (_isLoadingDoctors) return [];
    return _doctors.where((doctor) {
      final matchesSearch =
          doctor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doctor.specialty.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesSpecialty =
          selectedSpecialty == 'All' ||
          selectedSpecialty == AppStrings.get('specAll', 'en') ||
          doctor.specialtyId == selectedSpecialty.toLowerCase() ||
          _doctors.any(
            (d) =>
                d.id == doctor.id &&
                d.specialtyId == selectedSpecialty.toLowerCase(),
          );
      return matchesSearch && matchesSpecialty;
    }).toList();
  }

  void showBookingBottomSheet(Doctor doctor) {
    setState(() {
      selectedDate = null;
      selectedTime = null;
      bookingConfirmed = false;
      isBooking = false;
      _doctorSchedule = [];
      _hasFetchedSchedule = false;
      _isLoadingSchedule = false;
    });

    // Start loading BEFORE showing the sheet
    _loadDoctorSchedule(doctor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setter) {
          setModalState = setter;
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: !bookingConfirmed
                ? _buildBookingForm(
                    doctor,
                    setter,
                    Provider.of<LanguageService>(
                      context,
                      listen: false,
                    ).currentLanguage,
                  )
                : _buildSuccessScreen(
                    doctor,
                    Provider.of<LanguageService>(
                      context,
                      listen: false,
                    ).currentLanguage,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBookingForm(
    Doctor doctor,
    StateSetter setModalState,
    String languageCode,
  ) {
    final activeDates = getAvailableDates(_doctorSchedule);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('selectDateTime', languageCode),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF282828),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF282828),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: doctor.imageUrl.startsWith('http')
                          ? Image.network(
                              doctor.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.medical_services,
                                size: 24,
                                color: Color(0xFF282828),
                              ),
                            )
                          : Image.asset(
                              doctor.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.medical_services,
                                size: 24,
                                color: Color(0xFF282828),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF282828),
                        ),
                      ),
                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF282828).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection
                Text(
                  AppStrings.get('labelSelectDate', languageCode),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _isLoadingSchedule
                    ? [const Padding(padding: EdgeInsets.all(8.0), child: Text('Loading doctor schedule...', style: TextStyle(color: Colors.grey)))]
                    : activeDates.isEmpty 
                        ? [const Text('No available dates found.', style: TextStyle(color: Colors.grey))]
                        : activeDates.map((day) {
                        final isSelected = selectedDate == day['date'];
                    // Check if doctor has schedule for this day
                    final dayName = DateFormat('EEEE', 'en_US').format(DateTime.parse(day['date']!));
                    final hasSlots = _doctorSchedule.any((s) => s['day'] == dayName && (s['isBooked'] ?? false) == false);
                    
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: hasSlots ? () {
                            setModalState(() {
                              selectedDate = day['date'];
                              selectedTime = null; // Reset time when date changes
                            });
                            setState(() {
                              selectedDate = day['date'];
                              selectedTime = null;
                            });
                          } : null,
                          child: Opacity(
                            opacity: 1.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFCBD77E).withOpacity(0.2)
                                    : const Color(0xFFF7F7F7),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFCBD77E)
                                      : const Color(0xFFE6CA9A).withOpacity(0.25),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    day['label']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    day['date']!.split('-')[2],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFFCBD77E)
                                          : const Color(0xFF282828),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Time Selection
                Text(
                  AppStrings.get('labelSelectTime', languageCode),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoadingSchedule)
                  const Center(child: CircularProgressIndicator(color: Color(0xFFCBD77E)))
                else if (selectedDate == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Please select a date first',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else ...[
                  Builder(builder: (context) {
                    final dayName = DateFormat('EEEE', 'en_US').format(DateTime.parse(selectedDate!));
                    final availableSlots = _doctorSchedule
                        .where((s) => s['day'] == dayName && (s['isBooked'] ?? false) == false)
                        .map((s) => s['startTime'] as String)
                        .toList();

                    if (availableSlots.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No available slots for this day',
                            style: TextStyle(color: Colors.red[300]),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: availableSlots.length,
                      itemBuilder: (context, index) {
                        final time = availableSlots[index];
                        final isSelected = selectedTime == time;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedTime = time;
                            });
                            setState(() {
                              selectedTime = time;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFCBD77E).withOpacity(0.2)
                                  : const Color(0xFFF7F7F7),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFCBD77E)
                                    : const Color(0xFFE6CA9A).withOpacity(0.25),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFFCBD77E)
                                      : const Color(0xFF282828),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
                const SizedBox(height: 24),
                // Confirm Button
                GestureDetector(
                  onTap: (selectedDate != null && selectedTime != null && !isBooking)
                      ? () async {
                          setModalState(() {
                            isBooking = true;
                          });
                          setState(() {
                            isBooking = true;
                          });
                          
                          final authService = Provider.of<AuthService>(context, listen: false);
                          final user = authService.currentUser;
                          
                          if (user == null) {
                            setModalState?.call(() => isBooking = false);
                            setState(() => isBooking = false);
                            return;
                          }

                          if (user.id == null) {
                            setModalState?.call(() => isBooking = false);
                            setState(() => isBooking = false);
                            return;
                          }

                          bool success = await DashboardService.bookAppointment(
                            uid: user.id!,
                            patientName: user.name,
                            doctorId: doctor.id.toString(),
                            doctorName: doctor.name,
                            specialty: doctor.specialty,
                            date: selectedDate!,
                            time: selectedTime!,
                            type: 'In-Person Visit',
                          );

                          if (success) {
                            setModalState(() {
                              bookingConfirmed = true;
                              isBooking = false;
                            });
                            setState(() {
                              bookingConfirmed = true;
                              isBooking = false;
                            });
                          } else {
                            setModalState(() => isBooking = false);
                            setState(() => isBooking = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to book appointment'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: (selectedDate != null && selectedTime != null)
                          ? const LinearGradient(
                              colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
                            )
                          : null,
                      color: (selectedDate == null || selectedTime == null)
                          ? const Color(0xFFE6CA9A).withOpacity(0.25)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: (selectedDate != null && selectedTime != null)
                          ? [
                              BoxShadow(
                                color: const Color(0xFFCBD77E).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: isBooking
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFF282828),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: Color(0xFF282828),
                            ),
                            SizedBox(width: 8),
                            Text(
                              AppStrings.get('confirmAppt', languageCode),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF282828),
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(Doctor doctor, String languageCode) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 40,
              color: Color(0xFF282828),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.get('apptSuccessTitle', languageCode),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF282828),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.get('apptSuccessDesc', languageCode),
            style: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('labelDoctorInfo', languageCode),
                  style: TextStyle(fontSize: 12, color: Color(0xFF4A4A4A)),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF282828),
                  ),
                ),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFFCBD77E),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.get('labelDate', languageCode),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              Text(
                                selectedDate ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF282828),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFFCBD77E),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.get('labelTime', languageCode),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              Text(
                                selectedTime ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF282828),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCBD77E).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  AppStrings.get('labelDone', languageCode),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF282828),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;
    final specialties = getSpecialties(languageCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Color(0xFF282828),
                            ),
                          ),
                        ),
                        Text(
                          AppStrings.get('bookingTitle', languageCode),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF282828),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            size: 20,
                            color: Color(0xFF282828),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0xFF4A4A4A),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: AppStrings.get(
                                  'searchDoctor',
                                  languageCode,
                                ),
                                border: InputBorder.none,
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF282828),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Specialty Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: specialties.map((specialty) {
                  final isActive = selectedSpecialty == specialty['name'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSpecialty = specialty['name'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFCBD77E).withOpacity(0.2)
                              : Colors.white,
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFCBD77E)
                                : const Color(0xFFE6CA9A).withOpacity(0.25),
                            width: isActive ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              specialty['icon'],
                              size: 16,
                              color: isActive
                                  ? const Color(0xFFCBD77E)
                                  : const Color(0xFF4A4A4A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              specialty['name'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isActive
                                    ? const Color(0xFFCBD77E)
                                    : const Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Results Count
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppStrings.get(
                  'labelDoctorCount',
                  languageCode,
                ).replaceAll('{count}', filteredDoctors.length.toString()),
                style: const TextStyle(fontSize: 13, color: Color(0xFF4A4A4A)),
              ),
            ),
          ),
          // Doctors List
          Expanded(
            child: _isLoadingDoctors
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFFCBD77E)),
                        const SizedBox(height: 24),
                        const Text("Loading doctors..."),
                        const SizedBox(height: 8),
                        Text(
                          "URL: ${DashboardService.baseUrl}",
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _loadDoctors,
                          child: const Text("Retry Now"),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                              const SizedBox(height: 16),
                              Text(
                                "Error: $_errorMessage",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF4A4A4A)),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _loadDoctors,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCBD77E),
                                  foregroundColor: const Color(0xFF282828),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Retry Connection"),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF7F7F7)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFCBD77E),
                                    Color(0xFFE6CA9A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFCBD77E,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: doctor.imageUrl.startsWith('http')
                                    ? Image.network(
                                        doctor.imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(
                                              Icons.medical_services,
                                              size: 32,
                                              color: Color(0xFF282828),
                                            ),
                                      )
                                    : Image.asset(
                                        doctor.imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(
                                              Icons.medical_services,
                                              size: 32,
                                              color: Color(0xFF282828),
                                            ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF282828),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor.specialty,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    doctor.experience,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Book Button
                        GestureDetector(
                          onTap: () => showBookingBottomSheet(doctor),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFCBD77E,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Color(0xFF282828),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.get('bookingTitle', languageCode),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF282828),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Color(0xFF282828),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
