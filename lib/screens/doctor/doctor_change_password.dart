import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';

class DoctorChangePasswordScreen extends StatefulWidget {
  const DoctorChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<DoctorChangePasswordScreen> createState() =>
      _DoctorChangePasswordScreenState();
}

class _DoctorChangePasswordScreenState
    extends State<DoctorChangePasswordScreen> {
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

  void _handleChangePassword() {
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLanguage;
    if (_formKey.currentState!.validate()) {
      // Simulate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('msgPasswordUpdated', languageCode)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageService>(context).currentLanguage;
    final isRTL = languageCode == 'ar' || languageCode == 'ku';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppStrings.get('optChangePassword', languageCode),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.doctorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                AppStrings.get('sectSecurityUpdate', languageCode),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF282828),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('subSecurityUpdate', languageCode),
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF282828).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              _buildPasswordField(
                label: AppStrings.get('labelCurrentPassword', languageCode),
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                onToggle: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                languageCode: languageCode,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: AppStrings.get('labelNewPassword', languageCode),
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return AppStrings.get('errorRequired', languageCode);
                  if (val.length < 6)
                    return AppStrings.get('errorPasswordShort', languageCode);
                  return null;
                },
                languageCode: languageCode,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: AppStrings.get('labelConfirmNewPassword', languageCode),
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (val) {
                  if (val != _newPasswordController.text)
                    return AppStrings.get(
                      'errorPasswordsMismatch',
                      languageCode,
                    );
                  return null;
                },
                languageCode: languageCode,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.doctorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.doctorPrimary.withOpacity(0.4),
                  ),
                  child: Text(
                    AppStrings.get('actionUpdatePassword', languageCode),
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
    String? Function(String?)? validator,
    required String languageCode,
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
                  ? AppStrings.get('errorRequired', languageCode)
                  : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.doctorPrimary,
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
                color: AppColors.doctorPrimary,
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



