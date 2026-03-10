import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../enums/user_role.dart';
// import 'role_selection.dart'; // Removed or commented out
import '../../services/auth_service.dart';
import '../medical/dashboard_screen.dart';
import '../student/student_dashboard.dart';
import '../patinte.dart/patient_data_entry.dart';

class SignUpScreen extends StatefulWidget {
  final UserRole userRole;

  const SignUpScreen({Key? key, this.userRole = UserRole.patient})
    : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final authService = Provider.of<AuthService>(context);
    final lang = languageService.currentLanguage;
    final isRTL = languageService.isRTL;

    Color roleColor;
    String roleName;

    switch (widget.userRole) {
      case UserRole.doctor:
        roleColor = const Color(0xFF6AB5D8);
        roleName = AppStrings.get('roleDoctor', lang);
        break;
      case UserRole.student:
        roleColor = const Color(0xFFE8C998);
        roleName = AppStrings.get('roleStudent', lang);
        break;
      case UserRole.patient:
      default:
        roleColor = const Color(0xFFCBD77E);
        roleName = AppStrings.get('rolePatient', lang);
        break;
    }

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [roleColor, roleColor.withOpacity(0.7)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          isRTL
                              ? Icons.arrow_forward_ios
                              : Icons.arrow_back_ios,
                          color: const Color(0xFF285430),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                roleName,
                                style: const TextStyle(
                                  color: const Color(0xFF285430),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.get('signUpTitle', lang),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF285430),
                                height: 1.1,
                                fontFamily: isRTL ? 'Cairo' : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.get('signUpSubtitle', lang),
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF285430).withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sign Up Form Card
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                AppStrings.get('fullNameLabel', lang),
                              ),
                              _buildTextField(
                                controller: _nameController,
                                hintText: AppStrings.get('fullNameHint', lang),
                                icon: Icons.person_outline,
                                roleColor: roleColor,
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),

                              _buildLabel(AppStrings.get('emailLabel', lang)),
                              _buildTextField(
                                controller: _emailController,
                                hintText: AppStrings.get('emailHint', lang),
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                roleColor: roleColor,
                                validator: _validateEmail,
                              ),

                              _buildLabel(AppStrings.get('phoneLabel', lang)),
                              _buildTextField(
                                controller: _phoneController,
                                hintText: AppStrings.get('phoneHint', lang),
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                roleColor: roleColor,
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),

                              _buildLabel(
                                AppStrings.get('passwordLabel', lang),
                              ),
                              _buildTextField(
                                controller: _passwordController,
                                hintText: AppStrings.get('passwordHint', lang),
                                icon: Icons.lock_outline,
                                roleColor: roleColor,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                validator: (v) =>
                                    v!.length < 6 ? 'Min 6 chars' : null,
                              ),

                              _buildLabel(
                                AppStrings.get('confirmPasswordLabel', lang),
                              ),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                hintText: AppStrings.get(
                                  'confirmPasswordHint',
                                  lang,
                                ),
                                icon: Icons.lock_outline,
                                roleColor: roleColor,
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                                validator: (v) => v != _passwordController.text
                                    ? 'Passwords do not match'
                                    : null,
                              ),

                              const SizedBox(height: 30),

                              // Sign Up button
                              _buildGradientButton(
                                text: AppStrings.get('signUp', lang),
                                onPressed: () =>
                                    _handleSignUp(context, authService),
                                isLoading: authService.isLoading,
                                color: roleColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login link
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${AppStrings.get('alreadyHaveAccount', lang)} ',
                              style: TextStyle(
                                color: const Color(0xFF285430).withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                AppStrings.get('signIn', lang),
                                style: const TextStyle(
                                  color: Color(0xFF285430),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A3A2E),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color roleColor,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: Color(0xFF1A3A2E)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF1A3A2E).withOpacity(0.3),
          fontSize: 15,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1A3A2E).withOpacity(0.5),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: roleColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp(BuildContext context, AuthService authService) async {
    if (_formKey.currentState!.validate()) {
      final result = await authService.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        role: widget.userRole,
      );

      if (result.success && mounted) {
        if (widget.userRole == UserRole.patient) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PatientDataEntryPage(),
            ),
          );
        } else if (widget.userRole == UserRole.student) {
          // Navigate to student dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentDashboardScreen(),
            ),
          );
        } else {
          // Navigate to doctor/medical dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ModernDashboardScreen(),
            ),
          );
        }
      } else if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Registration failed'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (!value.contains('@')) {
      return 'Invalid email';
    }

    if (widget.userRole == UserRole.student) {
      if (!value.toLowerCase().endsWith('@cihanuniversity.edu.iq')) {
        final lang = Provider.of<LanguageService>(
          context,
          listen: false,
        ).currentLanguage;
        return AppStrings.get('studentEmailError', lang);
      }
    }

    return null;
  }
}
