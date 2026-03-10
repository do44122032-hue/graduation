import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../services/language_service.dart';

class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String credentials;
  final double rating;
  final int reviews;
  final String experience;
  final String location;
  final String nextAvailable;
  final String specialtyId;

  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.credentials,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.location,
    required this.nextAvailable,
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

  List<Map<String, String>> getNextThreeDays(String languageCode) => [
    {'date': '2024-12-23', 'label': AppStrings.get('labelToday', languageCode)},
    {
      'date': '2024-12-24',
      'label': AppStrings.get('labelTomorrow', languageCode),
    },
    {'date': '2024-12-25', 'label': 'Wed, Dec 25'},
  ];

  final List<Doctor> doctors = [
    Doctor(
      id: 1,
      name: 'Dr. Michael Chen',
      specialty: 'Cardiology',
      credentials: 'MD, FACC',
      rating: 4.9,
      reviews: 342,
      experience: '15 years',
      location: 'Medical Plaza - Building A',
      nextAvailable: 'Today, 2:30 PM',
      specialtyId: 'cardiology',
      imageUrl: 'assets/images/doctors/dr_michael_chen.png',
    ),
    Doctor(
      id: 2,
      name: 'Dr. Sarah Williams',
      specialty: 'Neurology',
      credentials: 'MD, PhD',
      rating: 4.8,
      reviews: 287,
      experience: '12 years',
      location: 'Medical Plaza - Building B',
      nextAvailable: 'Tomorrow, 9:00 AM',
      specialtyId: 'neurology',
      imageUrl: 'assets/images/doctors/dr_sarah_williams.png',
    ),
    Doctor(
      id: 3,
      name: 'Dr. James Martinez',
      specialty: 'Orthopedics',
      credentials: 'MD, FAAOS',
      rating: 4.9,
      reviews: 421,
      experience: '18 years',
      location: 'Medical Plaza - Building A',
      nextAvailable: 'Today, 4:00 PM',
      specialtyId: 'orthopedics',
      imageUrl: 'assets/images/doctors/dr_james_martinez.png',
    ),
    Doctor(
      id: 4,
      name: 'Dr. Emily Rodriguez',
      specialty: 'Pediatrics',
      credentials: 'MD, FAAP',
      rating: 5.0,
      reviews: 512,
      experience: '10 years',
      location: 'Medical Plaza - Building C',
      nextAvailable: 'Dec 24, 10:00 AM',
      specialtyId: 'pediatrics',
      imageUrl: 'assets/images/doctors/dr_emily_rodriguez.png',
    ),
    Doctor(
      id: 5,
      name: 'Dr. David Kim',
      specialty: 'Ophthalmology',
      credentials: 'MD, FACS',
      rating: 4.7,
      reviews: 198,
      experience: '8 years',
      location: 'Medical Plaza - Building B',
      nextAvailable: 'Dec 24, 11:30 AM',
      specialtyId: 'ophthalmology',
      imageUrl: 'assets/images/doctors/dr_david_kim.png',
    ),
    Doctor(
      id: 6,
      name: 'Dr. Lisa Thompson',
      specialty: 'Cardiology',
      credentials: 'MD, FACC',
      rating: 4.8,
      reviews: 356,
      experience: '14 years',
      location: 'Medical Plaza - Building A',
      nextAvailable: 'Tomorrow, 1:00 PM',
      specialtyId: 'cardiology',
      imageUrl: 'assets/images/doctors/dr_sarah_williams.png',
    ),
  ];

  final List<String> availableTimeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
  ];

  List<Doctor> get filteredDoctors {
    return doctors.where((doctor) {
      final matchesSearch =
          doctor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doctor.specialty.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesSpecialty =
          selectedSpecialty == 'All' ||
          selectedSpecialty == AppStrings.get('specAll', 'en') ||
          doctor.specialtyId == selectedSpecialty.toLowerCase() ||
          doctors.any(
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
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
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
                    setModalState,
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
    final nextThreeDays = getNextThreeDays(languageCode);
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
                      child: Image.asset(
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
                  children: nextThreeDays.map((day) {
                    final isSelected = selectedDate == day['date'];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedDate = day['date'];
                            });
                            setState(() {
                              selectedDate = day['date'];
                            });
                          },
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: availableTimeSlots.length,
                  itemBuilder: (context, index) {
                    final time = availableTimeSlots[index];
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
                ),
                const SizedBox(height: 24),
                // Confirm Button
                GestureDetector(
                  onTap: (selectedDate != null && selectedTime != null)
                      ? () {
                          setModalState(() {
                            bookingConfirmed = true;
                          });
                          setState(() {
                            bookingConfirmed = true;
                          });
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
                    child: Row(
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
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF4A4A4A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('labelLocation', languageCode),
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          Text(
                            doctor.location,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF282828),
                            ),
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
            child: ListView.builder(
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
                                child: Image.asset(
                                  doctor.imageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
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
                                    '${doctor.specialty} • ${doctor.credentials}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Color(0xFFCBD77E),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        doctor.rating.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF282828),
                                        ),
                                      ),
                                      Text(
                                        ' (${doctor.reviews})',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4A4A4A),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 12,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        color: const Color(
                                          0xFFE6CA9A,
                                        ).withOpacity(0.25),
                                      ),
                                      Text(
                                        doctor.experience,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4A4A4A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Location & Next Available
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Color(0xFF4A4A4A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      doctor.location,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF282828),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Color(0xFFCBD77E),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.get(
                                      'labelNextAvailable',
                                      languageCode,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF282828),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    doctor.nextAvailable,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFCBD77E),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
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
