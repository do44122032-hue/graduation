import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import 'chat_screen.dart';

class DoctorSelectionScreen extends StatefulWidget {
  const DoctorSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  bool _isLoading = true;
  List<UserModel> _activeDoctors = [];

  @override
  void initState() {
    super.initState();
    _loadActiveDoctors();
  }

  Future<void> _loadActiveDoctors() async {
    try {
      final doctors = await DashboardService.fetchActiveDoctors();
      if (mounted) {
        setState(() {
          _activeDoctors = doctors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load active doctors')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context).currentLanguage;
    final isRtl = Provider.of<LanguageService>(context).isRTL;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('callMyDoctors', lang).isEmpty ? 'Active Doctors' : AppStrings.get('callMyDoctors', lang)),
        backgroundColor: const Color(0xFFE8F1BD),
        foregroundColor: const Color(0xFF282828),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.mainButton))
          : _activeDoctors.isEmpty
              ? Center(child: Text('No active doctors found.', style: TextStyle(fontSize: 16, color: Colors.grey[600])))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _activeDoctors[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF6AB5D8).withOpacity(0.2),
                          backgroundImage: doctor.profilePicture != null ? NetworkImage(doctor.profilePicture!) : null,
                          child: doctor.profilePicture == null 
                              ? const Icon(Icons.person, color: Color(0xFF6AB5D8), size: 30) 
                              : null,
                        ),
                        title: Text(
                          doctor.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            doctor.department ?? 'General',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                        ),
                        trailing: Icon(isRtl ? Icons.chevron_left : Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorProfileScreen(doctor: doctor),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class DoctorProfileScreen extends StatefulWidget {
  final UserModel doctor;

  const DoctorProfileScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final schedules = await DashboardService.fetchDoctorSchedule(widget.doctor.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: const Color(0xFF6AB5D8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6AB5D8)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF6AB5D8).withOpacity(0.2),
                      backgroundImage: widget.doctor.profilePicture != null ? NetworkImage(widget.doctor.profilePicture!) : null,
                      child: widget.doctor.profilePicture == null 
                          ? const Icon(Icons.person, color: Color(0xFF6AB5D8), size: 50) 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      widget.doctor.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF282828)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6AB5D8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.doctor.department ?? 'General Department',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF6AB5D8), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              doctorId: widget.doctor.id,
                              doctorName: widget.doctor.name,
                              imageUrl: widget.doctor.profilePicture ?? '',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat with Doctor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCBD77E),
                        foregroundColor: const Color(0xFF282828),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Bio section
                  const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.doctor.bio?.isNotEmpty == true ? widget.doctor.bio! : 'No biography provided.',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Schedule section
                  const Text('Available Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  _schedules.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.event_busy, color: Colors.grey),
                              SizedBox(width: 12),
                              Text('No available slots currently.', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final slot = _schedules[index];
                            final isBooked = slot['isBooked'] ?? false;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isBooked ? Colors.grey[100] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isBooked ? Colors.grey[300]! : const Color(0xFF6AB5D8).withOpacity(0.5)
                                ),
                                boxShadow: isBooked ? [] : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 18, color: isBooked ? Colors.grey : const Color(0xFF6AB5D8)),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            slot['day'] ?? 'Day',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isBooked ? Colors.grey : const Color(0xFF282828),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${slot['startTime']} - ${slot['endTime']}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isBooked ? Colors.grey : Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (!isBooked)
                                    ElevatedButton(
                                      onPressed: () {
                                        // TODO: Implement booking specific slot logically
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Selecting this time slot...'))
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6AB5D8),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Book'),
                                    )
                                  else
                                    const Text('Booked', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
