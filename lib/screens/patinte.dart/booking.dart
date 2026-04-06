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

    availableDates.sort((a, b) => a.compareTo(b));
    
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
    
    setState(() => _isLoadingSchedule = true);
    if (setModalState != null) {
      setModalState!(() {});
    }

    try {
      final schedule = await DashboardService.fetchDoctorSchedule(doctor.id.toString());
      if (mounted) {
        setState(() {
          _doctorSchedule = schedule;
          _isLoadingSchedule = false;
          _hasFetchedSchedule = true;
        });
        if (setModalState != null) {
          setModalState!(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSchedule = false;
          _hasFetchedSchedule = true;
        });
        if (setModalState != null) {
          setModalState!(() {});
        }
        
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
          doctor.specialtyId == selectedSpecialty.toLowerCase();
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

    _loadDoctorSchedule(doctor);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setter) {
          setModalState = setter;
          final lang = Provider.of<LanguageService>(context).currentLanguage;
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: !bookingConfirmed
                ? _buildBookingForm(doctor, setter, lang)
                : _buildSuccessScreen(doctor, lang),
          );
        },
      ),
    );
  }

  Widget _buildBookingForm(Doctor doctor, StateSetter setModalState, String languageCode) {
    final activeDates = getAvailableDates(_doctorSchedule);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF282828)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF282828)),
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
                          ? Image.network(doctor.imageUrl, width: 48, height: 48, fit: BoxFit.cover)
                          : Image.asset(doctor.imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF282828))),
                      Text(doctor.specialty, style: TextStyle(fontSize: 13, color: const Color(0xFF282828).withOpacity(0.8))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('labelSelectDate', languageCode),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 12),
                if (_isLoadingSchedule)
                  const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: Color(0xFFCBD77E))))
                else if (activeDates.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('No available dates for this doctor', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: activeDates.map((day) {
                        final isSelected = selectedDate == day['date'];
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedDate = day['date'];
                                selectedTime = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFCBD77E).withOpacity(0.2) : Theme.of(context).cardColor,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFCBD77E) : Theme.of(context).dividerColor.withOpacity(0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(day['label']!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                                  const SizedBox(height: 4),
                                  Text(day['date']!.split('-')[2], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFFCBD77E) : Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.get('labelSelectTime', languageCode),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 12),
                if (selectedDate == null)
                  Center(child: Text('Select a date first', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))))
                else
                  Builder(builder: (context) {
                    final dayName = DateFormat('EEEE', 'en_US').format(DateTime.parse(selectedDate!));
                    final slots = _doctorSchedule.where((s) => s['day'] == dayName && !(s['isBooked'] ?? false)).map((s) => s['startTime'] as String).toList();
                    if (slots.isEmpty) return const Center(child: Text('No slots available'));
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.5),
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        final time = slots[index];
                        final isSelected = selectedTime == time;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedTime = time),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFCBD77E).withOpacity(0.2) : Theme.of(context).cardColor,
                              border: Border.all(color: isSelected ? const Color(0xFFCBD77E) : Theme.of(context).dividerColor.withOpacity(0.1), width: isSelected ? 2 : 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text(time, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFFCBD77E) : Theme.of(context).colorScheme.onSurface))),
                          ),
                        );
                      },
                    );
                  }),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: (selectedDate != null && selectedTime != null && !isBooking) ? () async {
                    setModalState(() => isBooking = true);
                    final auth = Provider.of<AuthService>(context, listen: false);
                    if (auth.currentUser?.id == null) return;
                    bool success = await DashboardService.bookAppointment(
                      uid: auth.currentUser!.id, patientName: auth.currentUser!.name,
                      doctorId: doctor.id, doctorName: doctor.name, specialty: doctor.specialty,
                      date: selectedDate!, time: selectedTime!, type: 'In-Person Visit'
                    );
                    if (success) setModalState(() { bookingConfirmed = true; isBooking = false; });
                    else setModalState(() => isBooking = false);
                  } : null,
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: (selectedDate != null && selectedTime != null) ? const LinearGradient(colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)]) : null,
                      color: (selectedDate == null || selectedTime == null) ? Colors.grey.withOpacity(0.2) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isBooking ? const Center(child: CircularProgressIndicator(color: Colors.black)) : Center(child: Text(AppStrings.get('confirmAppt', languageCode), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF282828)))),
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
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Color(0xFFCBD77E)),
          const SizedBox(height: 24),
          Text(AppStrings.get('apptSuccessTitle', languageCode), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(AppStrings.get('apptSuccessDesc', languageCode), style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.get('labelDoctorInfo', languageCode), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                const SizedBox(height: 4),
                Text(doctor.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                Text(doctor.specialty, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(AppStrings.get('labelDate', languageCode), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                      Text(selectedDate ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    ])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(AppStrings.get('labelTime', languageCode), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                      Text(selectedTime ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    ])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCBD77E), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(AppStrings.get('labelDone', languageCode)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;
    final isRTL = languageCode == 'ar' || languageCode == 'ku';
    final specialties = getSpecialties(languageCode);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: LinearGradient(begin: AlignmentDirectional.topStart, end: Alignment.bottomRight, colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)])),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(onPressed: () => Navigator.pop(context), icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back, color: const Color(0xFF282828))),
                        Text(AppStrings.get('bookingTitle', languageCode), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF282828))),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        onChanged: (v) => setState(() => searchQuery = v),
                        decoration: InputDecoration(hintText: AppStrings.get('searchDoctor', languageCode), border: InputBorder.none, icon: const Icon(Icons.search)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: specialties.map((s) {
                final active = selectedSpecialty == s['name'];
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedSpecialty = s['name']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: active ? const Color(0xFFCBD77E).withOpacity(0.2) : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: active ? const Color(0xFFCBD77E) : Theme.of(context).dividerColor.withOpacity(0.1))),
                      child: Row(children: [Icon(s['icon'], size: 16, color: active ? const Color(0xFFCBD77E) : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), const SizedBox(width: 6), Text(s['name'], style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? const Color(0xFFCBD77E) : Theme.of(context).colorScheme.onSurface))]),
                    ),
                  ),
                );
              }).toList()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(alignment: AlignmentDirectional.centerStart, child: Text(AppStrings.get('labelDoctorCount', languageCode).replaceAll('{count}', filteredDoctors.length.toString()), style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))),
          ),
          Expanded(
            child: _isLoadingDoctors ? const Center(child: CircularProgressIndicator(color: Color(0xFFCBD77E))) : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final d = filteredDoctors[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 60, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFFCBD77E).withOpacity(0.1)), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: d.imageUrl.startsWith('http') ? Image.network(d.imageUrl, fit: BoxFit.cover) : Image.asset(d.imageUrl, fit: BoxFit.cover))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(d.specialty, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))]))
                      ]),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => showBookingBottomSheet(d), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCBD77E), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(AppStrings.get('bookingTitle', languageCode)))
                    ],
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
