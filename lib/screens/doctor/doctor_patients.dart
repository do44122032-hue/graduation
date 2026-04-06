import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../services/dashboard_service.dart';
import '../../models/user_model.dart';
import 'doctor_patient_details.dart';
import '../patinte.dart/chat_screen.dart';

class DoctorPatientsPage extends StatefulWidget {
  const DoctorPatientsPage({super.key});

  @override
  State<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  List<UserModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await DashboardService.fetchPatients();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;


    void _showAddPatientDialog() {
      final nameController = TextEditingController();
      final ageController = TextEditingController();
      final conditionController = TextEditingController();
      final languageCode = Provider.of<LanguageService>(
        context,
        listen: false,
      ).currentLanguage;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            AppStrings.get('doctorAddPatientTitle', languageCode),
            style: AppTextStyles.h3(languageCode: languageCode).copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('labelPatientName', languageCode),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('labelAge', languageCode),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: conditionController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('labelCondition', languageCode),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.get('actionCancel', languageCode),
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty &&
                    conditionController.text.isNotEmpty) {
                  setState(() {
                    // No static list insertion as we rebuilt list in build
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.get('msgPatientAdded', languageCode),
                      ),
                      backgroundColor: AppColors.doctorPrimary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.doctorPrimary,
                foregroundColor: Colors.white,
              ),
              child: Text(AppStrings.get('actionAddPatient', languageCode)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('doctorMyPatientsTitle', languageCode),
          style: AppTextStyles.h3(
            languageCode: languageCode,
          ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.doctorPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          100,
        ),
        itemCount: _isLoading ? 5 : _patients.length,
        itemBuilder: (context, index) {
          if (_isLoading) {
            return _buildShimmerLoading();
          }
          final patient = _patients[index];
          final condition = (patient.chronicConditions != null &&
                  patient.chronicConditions!.isNotEmpty)
              ? patient.chronicConditions!.join(', ')
              : AppStrings.get('condHealthy', languageCode);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorPatientDetailsPage(
                    patientName: patient.name,
                    patientAge: patient.age ?? 'N/A',
                    condition: condition,
                    patientId: patient.id,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
              ),
              child: Row(
                children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.doctorPrimary.withOpacity(0.1),
                        backgroundImage: patient.profilePicture != null
                            ? NetworkImage(patient.profilePicture!)
                            : null,
                        child: patient.profilePicture == null
                            ? Text(
                                patient.name.isNotEmpty ? patient.name[0] : '?',
                                style: AppTextStyles.h2(
                                  languageCode: languageCode,
                                ).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.doctorPrimary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.name,
                              style: AppTextStyles.body(languageCode: languageCode)
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${patient.age ?? "--"} ${AppStrings.get('labelYears', languageCode)} • $condition',
                              style: AppTextStyles.caption(
                                languageCode: languageCode,
                              ).copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${AppStrings.get('labelLastVisit', languageCode)}: ${AppStrings.get('timeAgo_today', languageCode)}', // Mocking last visit for now
                              style: AppTextStyles.caption(
                                languageCode: languageCode,
                              ).copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.message_outlined,
                          color: AppColors.doctorPrimary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverId: patient.id,
                                receiverName: patient.name,
                                imageUrl: patient.profilePicture ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: _showAddPatientDialog,
          backgroundColor: AppColors.doctorPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.secondaryBackground,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 15, width: 150, color: AppColors.secondaryBackground),
                const SizedBox(height: 8),
                Container(height: 12, width: 200, color: AppColors.secondaryBackground),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



