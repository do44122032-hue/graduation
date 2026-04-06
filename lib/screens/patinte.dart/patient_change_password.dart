import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../services/auth_service.dart';
import '../../constants/app_strings.dart';
import '../../services/theme_service.dart';

class PatientChangePasswordScreen extends StatefulWidget {
  const PatientChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<PatientChangePasswordScreen> createState() =>
      _PatientChangePasswordScreenState();
}

class _PatientChangePasswordScreenState
    extends State<PatientChangePasswordScreen> {
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

  void _handleChangePassword() async {
    final languageCode = Provider.of<LanguageService>(
      context,
      listen: false,
    ).currentLanguage;
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (_formKey.currentState!.validate()) {
      final user = authService.currentUser;
      if (user == null) return;

      final result = await authService.changePassword(
        uid: user.id,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.get('msgPasswordUpdated', languageCode)),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final authService = Provider.of<AuthService>(context);
    final languageCode = languageService.currentLanguage;
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          AppStrings.get('optChangePassword', languageCode),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF282828),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : const Color(0xFF282828)),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: Alignment.bottomRight,
              colors: [Color(0xFFCBD77E), Color(0xFFE6CA9A)],
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
                AppStrings.get('sectSecurityUpdate', languageCode),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF282828),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('subSecurityUpdate', languageCode),
                style: TextStyle(
                  fontSize: 14,
                  color: (isDark ? Colors.white : const Color(0xFF282828)).withOpacity(0.6),
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
                isDark: isDark,
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
                isDark: isDark,
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
                isDark: isDark,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCBD77E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: authService.isLoading 
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
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
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF282828),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          validator:
              validator ??
              (val) => val == null || val.isEmpty
                  ? AppStrings.get('errorRequired', languageCode)
                  : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFFCBD77E),
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
                color: Color(0xFFCBD77E),
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



