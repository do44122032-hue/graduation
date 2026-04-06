import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';

class StudentChangePasswordScreen extends StatefulWidget {
  const StudentChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<StudentChangePasswordScreen> createState() =>
      _StudentChangePasswordScreenState();
}

class _StudentChangePasswordScreenState
    extends State<StudentChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword(String lang) {
    if (_formKey.currentState!.validate()) {
      // Simulate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('msgPasswordUpdated', lang)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFE8C998);
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppStrings.get('optChangePassword', lang),
          style: const TextStyle(
            color: Color(0xFF282828),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF282828)),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: Alignment.bottomRight,
              colors: [primaryGold, Color(0xFFF5DDB8)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('sectSecurityUpdate', lang),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF282828),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('subSecurityUpdate', lang),
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF282828).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              _buildPasswordField(
                label: AppStrings.get('labelCurrentPassword', lang),
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                onToggle: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                lang: lang,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: AppStrings.get('labelNewPassword', lang),
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return AppStrings.get('errorRequired', lang);
                  if (val.length < 6)
                    return AppStrings.get('errorPasswordShort', lang);
                  return null;
                },
                lang: lang,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: AppStrings.get('labelConfirmPassword', lang),
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (val) {
                  if (val != _newPasswordController.text)
                    return AppStrings.get('errorPasswordsMismatch', lang);
                  return null;
                },
                lang: lang,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleChangePassword(lang),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: primaryGold.withOpacity(0.4),
                  ),
                  child: Text(
                    AppStrings.get('actionUpdatePassword', lang),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required String lang,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF282828),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator:
              validator ??
              (val) => val == null || val.isEmpty
                  ? AppStrings.get('errorRequired', lang)
                  : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFFE8C998),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE8C998),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}



