import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import '../../enums/user_role.dart';
import '../../services/auth_service.dart';
import 'verification_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final UserRole userRole;

  const ForgotPasswordScreen({Key? key, required this.userRole})
    : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();

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
    _identifierController.dispose();
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
              begin: Alignment.topLeft,
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
                            AppStrings.get('forgotPasswordTitle', lang),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.get('forgotPasswordSubtitle', lang),
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
                            Text(
                              AppStrings.get('phoneLabel', lang),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A3A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildModernTextField(
                              controller: _identifierController,
                              hintText: AppStrings.get('phoneHint', lang),
                              prefixIcon: Icons.phone_outlined,
                              roleColor: roleColor,
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 32),
                            _buildGradientButton(
                              text: AppStrings.get('sendResetLink', lang),
                              onPressed: () =>
                                  _handleReset(context, authService, lang),
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleReset(
    BuildContext context,
    AuthService authService,
    String lang,
  ) async {
    if (_formKey.currentState!.validate()) {
      final result = await authService.resetPassword(
        _identifierController.text,
      );
      if (result.success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodeScreen(
              userRole: widget.userRole,
              identifier: _identifierController.text,
            ),
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
