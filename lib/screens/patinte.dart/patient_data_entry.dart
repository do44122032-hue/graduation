import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../medical/dashboard_screen.dart';
import 'package:graduation_project/models/medical_models.dart';

class PatientDataEntryPage extends StatefulWidget {
  const PatientDataEntryPage({Key? key}) : super(key: key);

  @override
  State<PatientDataEntryPage> createState() => _PatientDataEntryPageState();
}

class _PatientDataEntryPageState extends State<PatientDataEntryPage> {
  // Controllers for Personal Info
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _dobController = TextEditingController();
  final _socialStatusController = TextEditingController();

  // Local State for Lists
  List<ChronicCondition> _conditions = [];

  // Colors (matching dashboard)
  static const Color colorSecondaryBg = Color(0xFFF7F7F7);
  static const Color colorCharcoal = Color(0xFF282828);
  static const Color colorSecondaryText = Color(0xFF4A4A4A);
  static const Color colorAccentOlive = Color(0xFFCBD77E);
  static const Color colorAccentBeige = Color(0xFFE6CA9A);
  static const Color colorWhite = Colors.white;
  static const Color colorMainButton = Color(0xFFCBD77E);
  static const Color colorSecondaryButton = Color(0xFFE6CA9A);

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final languageCode = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: colorSecondaryBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorMainButton, colorSecondaryButton],
            ),
          ),
        ),
        title: Text(
          AppStrings.get('actionEditMedicalProfile', languageCode),
          style: const TextStyle(
            color: colorCharcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: colorCharcoal),
        actions: [
          TextButton.icon(
            onPressed: () => _saveData(languageCode),
            icon: const Icon(Icons.save, color: colorCharcoal),
            label: Text(
              AppStrings.get('actionSave', languageCode),
              style: const TextStyle(
                color: colorCharcoal,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              AppStrings.get('sectPersonalInfo', languageCode),
              Icons.person,
            ),
            const SizedBox(height: 16),
            _buildPersonalInfoForm(languageCode),
            const SizedBox(height: 32),
            _buildSectionHeader(
              AppStrings.get('sectChronicConditions', languageCode),
              Icons.favorite,
            ),
            const SizedBox(height: 16),
            _buildConditionsList(languageCode),
            const SizedBox(height: 32),

            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorAccentOlive.withOpacity(0.2),
            colorAccentBeige.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: colorAccentOlive, width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorCharcoal, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm(String languageCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            AppStrings.get('labelFullName', languageCode),
            _nameController,
            Icons.person,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  AppStrings.get('labelAgeNormal', languageCode),
                  _ageController,
                  Icons.calendar_today,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  AppStrings.get('labelBloodType', languageCode),
                  _bloodTypeController,
                  Icons.bloodtype,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  AppStrings.get('labelHeight', languageCode),
                  _heightController,
                  Icons.height,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  AppStrings.get('labelWeight', languageCode),
                  _weightController,
                  Icons.monitor_weight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            AppStrings.get('labelDOBShort', languageCode),
            _dobController,
            Icons.cake,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            AppStrings.get('labelSocialStatus', languageCode),
            _socialStatusController,
            Icons.family_restroom,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorAccentOlive),
        filled: true,
        fillColor: colorSecondaryBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildConditionsList(String languageCode) {
    return Column(
      children: [
        if (_conditions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                AppStrings.get('msgNoConditions', languageCode),
                style: const TextStyle(color: colorSecondaryText),
              ),
            ),
          ),
        ..._conditions.map(
          (condition) => _buildConditionItem(condition, languageCode),
        ),
        const SizedBox(height: 12),
        _buildAddButton(
          AppStrings.get('actionAddCondition', languageCode),
          () => _showAddConditionDialog(languageCode),
        ),
      ],
    );
  }

  Widget _buildConditionItem(ChronicCondition condition, String languageCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorSecondaryBg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition.diseaseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${AppStrings.get('labelStatus', languageCode)} ${condition.currentStatus}',
                  style: const TextStyle(
                    color: colorSecondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              setState(() {
                _conditions.remove(condition);
              });
            },
          ),
        ],
      ),
    );
  }



  Widget _buildAddButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: colorAccentOlive),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: colorAccentOlive,
        ),
        icon: const Icon(Icons.add),
        label: Text(label),
      ),
    );
  }

  void _showAddConditionDialog(String languageCode) {
    final nameController = TextEditingController();
    final statusController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('actionAddCondition', languageCode)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppStrings.get('labelConditionName', languageCode),
              ),
            ),
            TextField(
              controller: statusController,
              decoration: InputDecoration(
                labelText: AppStrings.get('labelStatusHint', languageCode),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('actionCancel', languageCode)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _conditions.add(
                  ChronicCondition(
                    id: DateTime.now().millisecondsSinceEpoch,
                    diseaseName: nameController.text,
                    currentStatus: statusController.text,
                    // Mocking other required fields for now
                    icdCode: 'N/A',
                    diagnosedDate: 'Just now',
                    severityLevel: 'Unknown',
                    treatingPhysician: 'Self-reported',
                    lastUpdated: 'Just now',
                    managementPlan: 'N/A',
                  ),
                );
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorAccentOlive),
            child: Text(AppStrings.get('actionAdd', languageCode)),
          ),
        ],
      ),
    );
  }



  void _saveData(String languageCode) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final result = await authService.updatePatientProfile(
      age: _ageController.text,
      bloodType: _bloodTypeController.text,
      height: _heightController.text,
      weight: _weightController.text,
      dateOfBirth: _dobController.text,
      socialStatus: _socialStatusController.text,
      // Convert proper objects to strings if needed for storage, or store simple strings
      // For this implementation, we will just store the disease names as strings
      chronicConditions: _conditions.map((e) => e.diseaseName).toList(),
    );

    if (result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('msgMedicalProfileUpdated', languageCode),
          ),
          backgroundColor: colorAccentOlive,
        ),
      );
      // Navigate to dashboard and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ModernDashboardScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Update failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
