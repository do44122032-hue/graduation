import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class DoctorPatientsPage extends StatefulWidget {
  const DoctorPatientsPage({super.key});

  @override
  State<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;

    final List<Map<String, dynamic>> patients = [
      {
        'name': AppStrings.get('patAhmed', languageCode),
        'age': '45',
        'condition': AppStrings.get('condHypertension', languageCode),
        'lastVisit': '2 ${AppStrings.get('timeAgo_daysAgo', languageCode)}',
        'image': null,
      },
      {
        'name': AppStrings.get('patSara', languageCode),
        'age': '32',
        'condition': AppStrings.get('condPostSurgery', languageCode),
        'lastVisit': AppStrings.get('timeAgo_yesterday', languageCode),
        'image': null,
      },
      {
        'name': AppStrings.get('patMohamed', languageCode),
        'age': '28',
        'condition': AppStrings.get('condInfluenza', languageCode),
        'lastVisit': '1 ${AppStrings.get('timeAgo_weekAgo', languageCode)}',
        'image': null,
      },
      {
        'name': AppStrings.get('patLaila', languageCode),
        'age': '55',
        'condition': AppStrings.get('condDiabetes2', languageCode),
        'lastVisit': '3 ${AppStrings.get('timeAgo_daysAgo', languageCode)}',
        'image': null,
      },
      {
        'name': AppStrings.get('patYoussef', languageCode),
        'age': '41',
        'condition': AppStrings.get('condCardiology', languageCode),
        'lastVisit': AppStrings.get('timeAgo_today', languageCode),
        'image': null,
      },
    ];

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
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          title: Text(
            AppStrings.get('doctorAddPatientTitle', languageCode),
            style: AppTextStyles.h3(languageCode: languageCode).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
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
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.get('doctorMyPatientsTitle', languageCode),
          style: AppTextStyles.h3(
            languageCode: languageCode,
          ).copyWith(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          100,
        ),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.doctorPrimary.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    (patient['name'] as String)[0],
                    style: AppTextStyles.h2(languageCode: languageCode)
                        .copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.doctorPrimary,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name'] as String,
                        style: AppTextStyles.body(languageCode: languageCode)
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${patient['age']} ${AppStrings.get('labelYears', languageCode)} • ${patient['condition']}',
                        style: AppTextStyles.caption(
                          languageCode: languageCode,
                        ).copyWith(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppStrings.get('labelLastVisit', languageCode)}: ${patient['lastVisit']}',
                        style: AppTextStyles.caption(languageCode: languageCode)
                            .copyWith(
                              color: AppColors.secondaryText,
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.secondaryText,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: _showAddPatientDialog,
          backgroundColor: AppColors.doctorPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
