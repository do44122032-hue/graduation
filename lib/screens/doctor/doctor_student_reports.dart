import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import '../../models/student_report_model.dart';
import '../../models/student_task_model.dart';
import '../../models/user_model.dart';
import '../../constants/api_config.dart';

class DoctorStudentReportsPage extends StatefulWidget {
  final bool showAssignTask;
  const DoctorStudentReportsPage({Key? key, this.showAssignTask = false}) : super(key: key);

  @override
  State<DoctorStudentReportsPage> createState() => _DoctorStudentReportsPageState();
}

class _DoctorStudentReportsPageState extends State<DoctorStudentReportsPage> with TickerProviderStateMixin {
  List<StudentReportModel> _reports = [];
  List<StudentTaskModel> _tasks = [];
  List<UserModel> _allStudents = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    if (widget.showAssignTask) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAssignTaskDialog();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAssignTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7))),
    );
    
    Uint8List? selectedFileBytes;
    String? selectedFileName;
    bool isSaving = false;

    int? selectedStudentId;
    final uniqueStudents = <int, String>{};
    for (var student in _allStudents) {
      final id = int.tryParse(student.id);
      if (id != null) {
        uniqueStudents[id] = student.name;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Assign New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedStudentId,
                  decoration: const InputDecoration(
                    labelText: 'Select Student',
                    border: OutlineInputBorder(),
                  ),
                  items: uniqueStudents.entries.map((e) {
                    return DropdownMenuItem<int>(
                      value: e.key,
                      child: Text(e.value),
                    );
                  }).toList(),
                  onChanged: (val) => setDialogState(() => selectedStudentId = val),
                  hint: const Text('Choose a student'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g., Clinical Observation',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What should the student do?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Due Date (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.calendar_today, size: 20),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // File Attachment UI
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedFileName ?? 'Attach Document (Optional)',
                          style: TextStyle(
                            fontSize: 12,
                            color: selectedFileName != null ? Colors.black87 : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo, size: 20),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a task title')),
                  );
                  return;
                }
                
                final authService = Provider.of<AuthService>(context, listen: false);
                final doctorId = int.tryParse(authService.currentUser?.id ?? '');

                setDialogState(() => isSaving = true);
                bool success = await DashboardService.assignStudentTask(
                  studentId: selectedStudentId,
                  doctorId: doctorId,
                  title: title,
                  description: descController.text.trim(),
                  dueDate: dateController.text.trim(),
                  fileBytes: selectedFileBytes,
                  fileName: selectedFileName,
                );
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task assigned successfully!')),
                  );
                } else {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to assign task. Check if backend is deployed.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.currentUser?.id;

    if (uid != null) {
      try {
        final reports = await DashboardService.getDoctorStudentReports(uid);
        final tasks = await DashboardService.getDoctorAssignedTasks(uid);
        final students = await DashboardService.getAllStudents();
        
        if (mounted) {
          setState(() {
            _reports = reports;
            _tasks = tasks;
            _allStudents = students;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading doctor data: $e');
        setState(() {
          _reports = [];
          _tasks = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadOrViewFile(String? fileUrl) async {
    if (fileUrl == null || fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file attached to this report.')),
      );
      return;
    }
    
    final fullUrl = "${ApiConfig.baseUrl}$fileUrl";
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Academic Management', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.doctorPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.doctorPrimary,
          tabs: const [
            Tab(text: 'Submissions'),
            Tab(text: 'Tasks'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.doctorPrimary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSubmissionsTab(),
                _buildTasksTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAssignTaskDialog,
        backgroundColor: AppColors.doctorPrimary,
        child: const Icon(Icons.add_task, color: Colors.white),
      ),
    );
  }

  Widget _buildSubmissionsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.doctorPrimary,
      child: _reports.isEmpty
          ? const Center(child: Text('No student reports found.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                DateTime? subDate;
                try {
                  subDate = DateTime.parse(report.submittedAt);
                } catch (_) {}

                String formattedDate = subDate != null
                    ? DateFormat('MMM dd, yyyy - hh:mm a').format(subDate)
                    : report.submittedAt;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: AppColors.cardBackground,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                report.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                report.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'From: ${report.studentName ?? 'Unknown Student'}',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.doctorPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(report.description),
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            TextButton.icon(
                              onPressed: () => _downloadOrViewFile(report.fileUrl),
                              icon: const Icon(Icons.attachment),
                              label: const Text('View Attachment'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.doctorPrimary,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTasksTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.doctorPrimary,
      child: _tasks.isEmpty
          ? const Center(child: Text('No tasks assigned yet.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: AppColors.cardBackground,
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Due: ${task.dueDate}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: task.status == 'completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: task.status == 'completed' ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
