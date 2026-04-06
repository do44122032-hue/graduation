import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class StudentEditProfileScreen extends StatefulWidget {
  const StudentEditProfileScreen({Key? key}) : super(key: key);

  @override
  State<StudentEditProfileScreen> createState() =>
      _StudentEditProfileScreenState();
}

class _StudentEditProfileScreenState extends State<StudentEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  String? _selectedSemester;

  static const Color studentThemeColor = Color(0xFFE8C998);
  static const Color charcoal = Color(0xFF282828);

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    _nameController = TextEditingController(
      text: user?.name ?? 'Alex Thompson',
    );
    _emailController = TextEditingController(
      text: user?.email ?? 'alex.thompson@university.edu',
    );
    _phoneController = TextEditingController(
      text: user?.phoneNumber ?? '+1 234 567 890',
    );
    _bioController = TextEditingController(
      text:
          'Medical student passionate about clinical research and patient care.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;
    // Set default value if null, using localized string would require logic inside build or init
    if (_selectedSemester == null) {
      _selectedSemester = AppStrings.get('labelSemester1_2026', lang);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppStrings.get('titleEditProfile', lang),
          style: const TextStyle(color: charcoal, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: charcoal),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: Alignment.bottomRight,
              colors: [studentThemeColor, Color(0xFFF5DDB8)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            onPressed: () => _saveProfile(lang),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(AppStrings.get('sectPersonalInfo', lang)),
              const SizedBox(height: 16),
              _buildTextField(
                AppStrings.get('labelFullName', lang),
                _nameController,
                Icons.person_outline,
                validationMsg: AppStrings.get('hintEnterName', lang),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                AppStrings.get('labelEmailAddress', lang),
                _emailController,
                Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validationMsg: AppStrings.get('errorEnterEmail', lang),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                AppStrings.get('labelPhoneNumber', lang),
                _phoneController,
                Icons.phone_android,
                keyboardType: TextInputType.phone,
                validationMsg: AppStrings.get('errorRequired', lang),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader(AppStrings.get('labelAcademicDetails', lang)),
              const SizedBox(height: 16),
              _buildSemesterDropdown(lang),

              const SizedBox(height: 32),
              _buildSectionHeader(AppStrings.get('labelAboutMe', lang)),
              const SizedBox(height: 16),
              _buildTextField(
                AppStrings.get('labelBio', lang),
                _bioController,
                Icons.info_outline,
                maxLines: 4,
                validationMsg: AppStrings.get('errorRequired', lang),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveProfile(lang),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: studentThemeColor,
                    foregroundColor: charcoal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.get('actionSave', lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: charcoal,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? validationMsg,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: studentThemeColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: studentThemeColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMsg ?? 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildSemesterDropdown(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value:
              _selectedSemester ?? AppStrings.get('labelSemester1_2026', lang),
          decoration: InputDecoration(
            labelText: AppStrings.get('labelSemester', lang),
            prefixIcon: const Icon(
              Icons.school_outlined,
              color: studentThemeColor,
            ),
            border: InputBorder.none,
          ),
          items: [
            AppStrings.get('labelSemester1_2026', lang),
            'Spring 2025', // These can be added to AppStrings if needed, but for now leave or add them
            'Summer 2025',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) {
            setState(() {
              _selectedSemester = val!;
            });
          },
        ),
      ),
    );
  }

  void _saveProfile(String lang) {
    if (_formKey.currentState!.validate()) {
      // In a real app, you'd call a service to save data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('msgMedicalProfileUpdated', lang)),
          backgroundColor: studentThemeColor,
        ),
      );
      Navigator.pop(context);
    }
  }
}



