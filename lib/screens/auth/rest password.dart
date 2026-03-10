import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medtech',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ResetPasswordPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  // Color palette
  static const Color colorCharcoal = Color(0xFF282828);
  static const Color colorWarmSand = Color(0xFFE6CA9A);
  static const Color colorSage = Color(0xFFCBD77A);
  static const Color colorWhite = Color(0xFFFFFFFF);

  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _passwordReset = false;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Float animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeController.forward();

    // Listen to password changes for real-time validation
    _passwordController.addListener(() {
      setState(() {});
    });

    _confirmPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Password strength calculation
  Map<String, dynamic> _getPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      return {'strength': 0, 'label': '', 'color': Colors.transparent};
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) strength++;

    if (strength <= 2) {
      return {
        'strength': 0.33,
        'label': 'Weak',
        'color': const Color(0xFFEF4444)
      };
    }
    if (strength <= 3) {
      return {
        'strength': 0.66,
        'label': 'Medium',
        'color': const Color(0xFFF59E0B)
      };
    }
    return {'strength': 1.0, 'label': 'Strong', 'color': colorSage};
  }

  @override
  Widget build(BuildContext context) {
    if (_passwordReset) {
      return _buildSuccessScreen();
    }
    return _buildResetPasswordScreen();
  }

  Widget _buildResetPasswordScreen() {
    final passwordStrength = _getPasswordStrength();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    return Scaffold(
      backgroundColor: colorWhite,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Stack(
            children: [
              // Floating background circles
              _buildFloatingCircle(
                top: -50,
                right: -30,
                size: 180,
                color: colorSage.withOpacity(0.15),
              ),
              _buildFloatingCircle(
                bottom: 100,
                left: -40,
                size: 200,
                color: colorWarmSand.withOpacity(0.15),
              ),

              // Main content
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Status bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '9:41',
                            style: TextStyle(
                              color: colorCharcoal,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.signal_cellular_4_bar,
                                  color: colorCharcoal, size: 16),
                              SizedBox(width: 4),
                              Icon(Icons.wifi, color: colorCharcoal, size: 16),
                              SizedBox(width: 4),
                              Icon(Icons.battery_full,
                                  color: colorCharcoal, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),

                          // Lock icon illustration
                          _buildAnimatedWidget(
                            delay: 0.1,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse ring
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 128 +
                                          (_pulseController.value * 80),
                                      height: 128 +
                                          (_pulseController.value * 80),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorSage.withOpacity(
                                              0.4 *
                                                  (1 - _pulseController.value),
                                            ),
                                            blurRadius: 0,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // Gradient circle with icon
                                Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [colorSage, colorWarmSand],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorSage.withOpacity(0.3),
                                        blurRadius: 40,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    size: 64,
                                    color: colorWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Title
                          _buildAnimatedWidget(
                            delay: 0.2,
                            child: const Text(
                              'Reset Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: colorCharcoal,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Description
                          _buildAnimatedWidget(
                            delay: 0.3,
                            child: Text(
                              'Create a strong password to secure your account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: colorCharcoal.withOpacity(0.6),
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // New Password field
                          _buildAnimatedWidget(
                            delay: 0.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'New Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorCharcoal.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorCharcoal.withOpacity(0.08),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: colorCharcoal,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter new password',
                                      hintStyle: TextStyle(
                                        color: colorCharcoal.withOpacity(0.3),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: colorCharcoal.withOpacity(0.4),
                                        size: 22,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color:
                                              colorCharcoal.withOpacity(0.4),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                // Password strength indicator
                                if (password.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Password Strength',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              colorCharcoal.withOpacity(0.5),
                                        ),
                                      ),
                                      Text(
                                        passwordStrength['label'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: passwordStrength['color'],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: colorCharcoal.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor:
                                          passwordStrength['strength'],
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: passwordStrength['color'],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Confirm Password field
                          _buildAnimatedWidget(
                            delay: 0.5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorCharcoal.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorCharcoal.withOpacity(0.08),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: colorCharcoal,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Re-enter new password',
                                      hintStyle: TextStyle(
                                        color: colorCharcoal.withOpacity(0.3),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: colorCharcoal.withOpacity(0.4),
                                        size: 22,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color:
                                              colorCharcoal.withOpacity(0.4),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                // Password match indicator
                                if (confirmPassword.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        password == confirmPassword
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 16,
                                        color: password == confirmPassword
                                            ? colorSage
                                            : const Color(0xFFEF4444),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        password == confirmPassword
                                            ? 'Passwords match'
                                            : 'Passwords don\'t match',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: password == confirmPassword
                                              ? colorSage
                                              : const Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Password requirements
                          _buildAnimatedWidget(
                            delay: 0.6,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorSage.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your password must contain:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorCharcoal.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildRequirement(
                                    'At least 8 characters',
                                    password.length >= 8,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildRequirement(
                                    'Upper & lowercase letters',
                                    RegExp(r'[A-Z]').hasMatch(password) &&
                                        RegExp(r'[a-z]').hasMatch(password),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildRequirement(
                                    'At least one number',
                                    RegExp(r'\d').hasMatch(password),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Reset Password button
                          _buildAnimatedWidget(
                            delay: 0.7,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [colorSage, colorWarmSand],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorSage.withOpacity(0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isLoading
                                      ? null
                                      : _handleResetPassword,
                                  borderRadius: BorderRadius.circular(28),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: colorWhite,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'Reset Password',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: colorWhite,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: colorWhite,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Stack(
            children: [
              // Floating background circles
              _buildFloatingCircle(
                top: -50,
                right: -30,
                size: 180,
                color: colorSage.withOpacity(0.15),
              ),
              _buildFloatingCircle(
                bottom: 100,
                left: -40,
                size: 200,
                color: colorWarmSand.withOpacity(0.15),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Status bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '9:41',
                            style: TextStyle(
                              color: colorCharcoal,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.signal_cellular_4_bar,
                                  color: colorCharcoal, size: 16),
                              SizedBox(width: 4),
                              Icon(Icons.wifi, color: colorCharcoal, size: 16),
                              SizedBox(width: 4),
                              Icon(Icons.battery_full,
                                  color: colorCharcoal, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Success icon
                    _buildAnimatedWidget(
                      delay: 0.0,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colorSage, colorWarmSand],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorSage.withOpacity(0.3),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: colorWhite,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    _buildAnimatedWidget(
                      delay: 0.2,
                      child: const Text(
                        'Password Reset!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: colorCharcoal,
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    _buildAnimatedWidget(
                      delay: 0.3,
                      child: Text(
                        'Your password has been successfully reset.\nYou can now log in with your new password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorCharcoal.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Back to Login button
                    _buildAnimatedWidget(
                      delay: 0.4,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colorSage, colorWarmSand],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: colorSage.withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate to login
                            },
                            borderRadius: BorderRadius.circular(28),
                            child: const Center(
                              child: Text(
                                'Back to Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorWhite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Positioned(
          top: top != null ? top + (_floatController.value * 20) : null,
          bottom:
              bottom != null ? bottom + (_floatController.value * 20) : null,
          left: left,
          right: right,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedWidget({
    required double delay,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(delay, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          final progress = Curves.easeOut.transform(
            (_fadeController.value - delay).clamp(0.0, 1.0 - delay) /
                (1.0 - delay),
          );
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * (1 - progress)),
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isMet ? colorSage : colorCharcoal.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? colorSage : colorCharcoal.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  void _handleResetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: colorCharcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password must be at least 8 characters long'),
          backgroundColor: colorCharcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: colorCharcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _passwordReset = true;
    });
  }
}
