import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../enums/user_role.dart';

import 'sign_up.dart';
import 'forgot_password.dart';
import '../../services/auth_service.dart';
import '../medical/dashboard_screen.dart';
import '../student/student_dashboard.dart';
import '../doctor/doctor_dashboard.dart';

class ModernLoginScreen extends StatefulWidget {
  final UserRole userRole;

  const ModernLoginScreen({Key? key, this.userRole = UserRole.patient})
    : super(key: key);

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _useEmailLogin = false; // New state to toggle login method

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final authService = Provider.of<AuthService>(context);
    final lang = languageService.currentLanguage;
    final isRTL = languageService.isRTL;

    // Get color based on role
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

                    const SizedBox(height: 20),

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
                              widget.userRole == UserRole.student
                                  ? AppStrings.get('studentLoginTitle', lang)
                                  : widget.userRole == UserRole.doctor
                                  ? AppStrings.get('doctorLoginTitle', lang)
                                  : AppStrings.get('loginTitle', lang),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF285430),
                                height: 1.1,
                                fontFamily: isRTL ? 'Cairo' : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.get('loginSubtitle', lang),
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

                    const SizedBox(height: 50),

                    // Login Form Card
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
                              // Method Toggle (Only for Doctor)
                              if (widget.userRole == UserRole.doctor) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => _useEmailLogin = false,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: !_useEmailLogin
                                                ? roleColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: !_useEmailLogin
                                                  ? Colors.transparent
                                                  : roleColor.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppStrings.get(
                                                'sheetIdToggle',
                                                lang,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => _useEmailLogin = true,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _useEmailLogin
                                                ? roleColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: _useEmailLogin
                                                  ? Colors.transparent
                                                  : roleColor.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppStrings.get(
                                                'emailToggle',
                                                lang,
                                              ),
                                              style: TextStyle(
                                                color: _useEmailLogin
                                                    ? Colors.white
                                                    : roleColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Conditional Form Fields
                              if (widget.userRole == UserRole.student) ...[
                                // Student ID / Email field
                                Text(
                                  AppStrings.get('studentIdLabel', lang),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A3A2E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildModernTextField(
                                  controller: _emailController,
                                  hintText: AppStrings.get(
                                    'studentIdHint',
                                    lang,
                                  ),
                                  prefixIcon: Icons.badge_outlined,
                                  roleColor: roleColor,
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? AppStrings.get(
                                          'errorEnterIdOrEmail',
                                          lang,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 24),
                                // Password field for Student
                                Text(
                                  AppStrings.get('passwordLabel', lang),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A3A2E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildModernTextField(
                                  controller: _passwordController,
                                  hintText: AppStrings.get(
                                    'passwordHint',
                                    lang,
                                  ),
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  roleColor: roleColor,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? AppStrings.get(
                                          'errorEnterPassword',
                                          lang,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                // ID Hint section as requested
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    AppStrings.get(
                                      'studentEmailLoginHint',
                                      lang,
                                    ),
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF1A3A2E,
                                      ).withOpacity(0.5),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ] else if (widget.userRole == UserRole.doctor &&
                                  !_useEmailLogin) ...[
                                // Sheet ID field
                                Text(
                                  AppStrings.get('sheetIdLabel', lang),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A3A2E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildModernTextField(
                                  controller:
                                      _emailController, // Reusing for Sheet ID
                                  hintText: AppStrings.get('sheetIdHint', lang),
                                  prefixIcon: Icons.assignment_ind_outlined,
                                  roleColor: roleColor,
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? AppStrings.get(
                                          'errorEnterSheetId',
                                          lang,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 24),
                                // Password field
                                Text(
                                  AppStrings.get('passwordLabel', lang),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A3A2E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildModernTextField(
                                  controller: _passwordController,
                                  hintText: AppStrings.get(
                                    'passwordHint',
                                    lang,
                                  ),
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  roleColor: roleColor,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? AppStrings.get(
                                          'errorEnterPassword',
                                          lang,
                                        )
                                      : null,
                                ),
                              ] else ...[
                                // Unified Email field (for Patient or for Student/Doctor choosing Email)
                                Text(
                                  AppStrings.get('emailLabel', lang),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A3A2E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildModernTextField(
                                  controller: _emailController,
                                  hintText: AppStrings.get('emailHint', lang),
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  roleColor: roleColor,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return AppStrings.get(
                                        'errorEnterEmail',
                                        lang,
                                      );
                                    if (!value.contains('@'))
                                      return AppStrings.get(
                                        'errorInvalidEmail',
                                        lang,
                                      );
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                // Password field
                                Text(
                                  AppStrings.get('passwordLabel', lang),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A3A2E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildModernTextField(
                                  controller: _passwordController,
                                  hintText: AppStrings.get(
                                    'passwordHint',
                                    lang,
                                  ),
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  roleColor: roleColor,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? AppStrings.get(
                                          'errorEnterPassword',
                                          lang,
                                        )
                                      : null,
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordScreen(
                                              userRole: widget.userRole,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppStrings.get('forgotPassword', lang),
                                    style: TextStyle(
                                      color: roleColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Login button
                              _buildGradientButton(
                                text: AppStrings.get('signIn', lang),
                                onPressed: () =>
                                    _handleLogin(context, authService),
                                isLoading: authService.isLoading,
                                color: roleColor,
                              ),

                              const SizedBox(height: 20),

                              // Biometric login
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      AppStrings.get('orSignInWith', lang),
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF1A3A2E,
                                        ).withOpacity(0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildSocialButton(
                                          Icons.fingerprint,
                                          roleColor,
                                          () {},
                                        ),
                                        const SizedBox(width: 16),
                                        _buildSocialButton(
                                          Icons.face,
                                          roleColor,
                                          () {},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${AppStrings.get('dontHaveAccount', lang)} ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: const Color(0xFF285430).withOpacity(0.8),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SignUpScreen(userRole: widget.userRole),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppStrings.get('signUp', lang),
                                  style: const TextStyle(
                                    color: const Color(0xFF285430),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
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
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1A3A2E),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF1A3A2E).withOpacity(0.3),
          fontSize: 15,
        ),
        prefixIcon: Icon(
          prefixIcon,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: roleColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
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
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF1A3A2E).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }

  void _handleLogin(BuildContext context, AuthService authService) async {
    if (_formKey.currentState!.validate()) {
      AuthResult result;
      Widget destination = const ModernDashboardScreen();

      if (widget.userRole == UserRole.student) {
        result = await authService.loginAsStudent(
          _emailController.text,
          _passwordController.text,
        );
        destination = const StudentDashboardScreen();
      } else if (widget.userRole == UserRole.doctor) {
        if (_useEmailLogin) {
          result = await authService.loginAsDoctor(
            _emailController.text,
            _passwordController.text,
          );
        } else {
          result = await authService.loginAsDoctor(
            _emailController.text,
            _passwordController.text,
          );
        }
        destination = const DoctorDashboardScreen();
      } else {
        result = await authService.loginAsPatient(
          _emailController.text,
          _passwordController.text,
        );
        destination = const ModernDashboardScreen();
      }

      if (result.success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      } else if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Authentication failed'),
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
}
