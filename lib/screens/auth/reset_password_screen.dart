import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../enums/user_role.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final UserRole userRole;
  final String identifier;

  const ResetPasswordScreen({
    Key? key,
    required this.userRole,
    required this.identifier,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    switch (widget.userRole) {
      case UserRole.doctor:
        roleColor = const Color(0xFF4A90E2);
        break;
      case UserRole.student:
        roleColor = const Color(0xFFE6CA9A);
        break;
      default:
        roleColor = const Color(0xFFCBD77E);
    }

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A3A2E),
                const Color(0xFF2D5F4C),
                roleColor,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('newPasswordTitle', lang),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.get('newPasswordSubtitle', lang),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
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
                            Text(
                              AppStrings.get('newPasswordLabel', lang),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A3A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildModernTextField(
                              controller: _passwordController,
                              hintText: AppStrings.get('newPasswordHint', lang),
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
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Required';
                                if (value.length < 6)
                                  return 'Min. 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              AppStrings.get('confirmNewPasswordLabel', lang),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A3A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildModernTextField(
                              controller: _confirmPasswordController,
                              hintText: AppStrings.get('newPasswordHint', lang),
                              prefixIcon: Icons.lock_reset_outlined,
                              obscureText: _obscurePassword,
                              roleColor: roleColor,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return AppStrings.get(
                                    'passwordMismatch',
                                    lang,
                                  );
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            _buildGradientButton(
                              text: AppStrings.get(
                                'loginTitle',
                                lang,
                              ), // "Set Password" or similar
                              onPressed: () =>
                                  _handleUpdate(context, authService, lang),
                              isLoading: authService.isLoading,
                              color: roleColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1A3A2E),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF1A3A2E).withOpacity(0.5),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: roleColor, width: 2),
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
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleUpdate(
    BuildContext context,
    AuthService authService,
    String lang,
  ) async {
    if (_formKey.currentState!.validate()) {
      final result = await authService.updatePassword(
        widget.identifier,
        _passwordController.text,
      );
      if (result.success && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.get('resetSuccess', lang)),
            content: Text(result.message ?? ''),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(AppStrings.get('backToLogin', lang)),
              ),
            ],
          ),
        );
      } else if (!result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}



