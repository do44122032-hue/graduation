import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../services/language_service.dart';

class DoctorScheduleManagementScreen extends StatefulWidget {
  const DoctorScheduleManagementScreen({Key? key}) : super(key: key);

  @override
  State<DoctorScheduleManagementScreen> createState() => _DoctorScheduleManagementScreenState();
}

class _DoctorScheduleManagementScreenState extends State<DoctorScheduleManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];

  String _selectedDay = 'Monday';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    try {
      final schedules = await DashboardService.fetchDoctorSchedule(user.id);
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load schedule')),
        );
      }
    }
  }

  Future<void> _addSchedule() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    if (_startTime.hour > _endTime.hour || (_startTime.hour == _endTime.hour && _startTime.minute >= _endTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start time must be before end time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final startStr = _timeOfDayToString(_startTime);
    final endStr = _timeOfDayToString(_endTime);

    final success = await DashboardService.addDoctorSchedule(
      doctorId: user.id,
      day: _selectedDay,
      startTime: startStr,
      endTime: endStr,
    );

    if (success) {
      await _loadSchedule(); // reload
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot added successfully')),
        );
        Navigator.pop(context); // Close bottom sheet
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add schedule')),
        );
      }
    }
  }

  Future<void> _seedDefaultSchedule() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    
    final slots = [
      {'day': 'Monday', 'start': '09:00 AM', 'end': '10:00 AM'},
      {'day': 'Monday', 'start': '10:00 AM', 'end': '11:00 AM'},
      {'day': 'Tuesday', 'start': '02:00 PM', 'end': '03:00 PM'},
      {'day': 'Wednesday', 'start': '11:00 AM', 'end': '12:00 PM'},
    ];

    int successCount = 0;
    for (var slot in slots) {
      final success = await DashboardService.addDoctorSchedule(
        doctorId: user.id,
        day: slot['day']!,
        startTime: slot['start']!,
        endTime: slot['end']!,
      );
      if (success) successCount++;
    }

    await _loadSchedule();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $successCount default slots successfully')),
      );
    }
  }

  String _timeOfDayToString(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  void _showAddScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Available Slot', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Select Day',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                    onChanged: (val) {
                      setModalState(() => _selectedDay = val!);
                      setState(() => _selectedDay = val!);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: _startTime);
                            if (time != null) {
                              setModalState(() => _startTime = time);
                              setState(() => _startTime = time);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Start Time',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_timeOfDayToString(_startTime)),
                                const Icon(Icons.access_time, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: _endTime);
                            if (time != null) {
                              setModalState(() => _endTime = time);
                              setState(() => _endTime = time);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'End Time',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_timeOfDayToString(_endTime)),
                                const Icon(Icons.access_time, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.doctorPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add Slot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Schedule',
          style: AppTextStyles.h3(languageCode: languageCode)
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.doctorPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.secondaryBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.doctorPrimary))
          : _schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No available slots added yet.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddScheduleSheet,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Slot'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.doctorPrimary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _seedDefaultSchedule,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Auto-generate Test Slots'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.doctorPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _schedules.length + 1, // +1 for the add button at top
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: _showAddScheduleSheet,
                                icon: const Icon(Icons.add),
                                label: const Text('Add New Slot'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.doctorPrimary,
                                  elevation: 0,
                                  side: const BorderSide(color: AppColors.doctorPrimary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _seedDefaultSchedule,
                                icon: const Icon(Icons.auto_awesome, size: 16),
                                label: const Text('Seed'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.doctorPrimary,
                                  side: const BorderSide(color: AppColors.doctorPrimary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final slot = _schedules[index - 1];
                    final isBooked = slot['isBooked'] ?? false;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        border: Border.all(
                          color: isBooked ? Colors.orange.withOpacity(0.5) : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.doctorPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event, color: AppColors.doctorPrimary),
                        ),
                        title: Text(slot['day'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${slot['startTime']} - ${slot['endTime']}'),
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isBooked ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isBooked ? 'Booked' : 'Available',
                            style: TextStyle(
                              color: isBooked ? Colors.orange[800] : Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
