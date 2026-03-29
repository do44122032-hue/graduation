import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../constants/app_spacing.dart';
import '../../services/language_service.dart';
import '../../constants/app_strings.dart';
import 'role_selection.dart';
import '../../constants/api_config.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _tapCount = 0;

  void _toggleEnvironment() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        ApiConfig.isLocal = !ApiConfig.isLocal;
        _tapCount = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Environment switched to: ${ApiConfig.isLocal ? "LOCAL (10.0.2.2)" : "PRODUCTION (Railway)"}',
            ),
            backgroundColor: ApiConfig.isLocal ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Rotation animation for sunshine effect
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    // Entrance Animations
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    // Start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final lang = languageService.currentLanguage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6AB5D8), // Blue
              Color(0xFFCBD77E), // Yellow-Green
              Color(0xFFE6CA9A), // Beige
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingLG,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16), // Small top safe margin
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildTopSection(languageService),
                  ),
                ),

                // Specific Spacing: Top Section -> Logo (80-120 range, using 100)
                const SizedBox(height: 100),

                // Center Section - Logo with Sunshine + App Name + Tagline
                _buildCenterSection(lang),

                const Spacer(),

                // Content -> Button Spacing (48-64 range, using 56)
                const SizedBox(height: 56),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildGetStartedButton(languageService),
                  ),
                ),

                // Button -> Bottom Spacing (24-40 range, using 32)
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(LanguageService languageService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // MyChart Logo Text
        GestureDetector(
          onTap: _toggleEnvironment,
          child: Text(
            AppStrings.get('appName', languageService.currentLanguage),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Language Buttons
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _buildLanguageButton(languageService, 'EN', 'en'),
                  _buildLanguageButton(languageService, 'AR', 'ar'),
                  _buildLanguageButton(languageService, 'KU', 'ku'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(
    LanguageService service,
    String label,
    String code,
  ) {
    final isSelected = service.currentLanguage == code;
    return GestureDetector(
      onTap: () {
        service.changeLanguage(code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingMD,
          vertical: AppSpacing.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM * 2.5), // 20
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4A7C59) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterSection(String lang) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stack for Logo + Sunburst
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180, // Increased from 100
              height: 180,
              child: OverflowBox(
                maxWidth: 350, // Increased from 200
                maxHeight: 350,
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: const RadialShineEffect(),
                ),
              ),
            ),
            Image.asset('assets/logo.png', width: 180, height: 180),
          ],
        ),

        // Logo -> App Name (16 px)
        const SizedBox(height: 16),

        Text(
          AppStrings.get('appName', lang),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // App Name -> Tagline (8 px)
        const SizedBox(height: 8),

        Text(
          AppStrings.get('appTagline', lang),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedButton(LanguageService languageService) {
    return EnhancedGetStartedButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      },
    );
  }
}

class RadialShineEffect extends StatelessWidget {
  const RadialShineEffect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350, // Increased from 200
      height: 350,
      child: CustomPaint(painter: RadialShinePainter()),
    );
  }
}

class RadialShinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const numberOfRays = 20;
    const rayAngle = (2 * math.pi) / numberOfRays;

    for (int i = 0; i < numberOfRays; i++) {
      final angle = i * rayAngle;

      final gradient = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.8, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(center.dx, center.dy);

      const rayWidthAngle = rayAngle * 0.4;

      final leftAngle = angle - rayWidthAngle / 2;
      final leftX = center.dx + radius * math.cos(leftAngle);
      final leftY = center.dy + radius * math.sin(leftAngle);

      final rightAngle = angle + rayWidthAngle / 2;
      final rightX = center.dx + radius * math.cos(rightAngle);
      final rightY = center.dy + radius * math.sin(rightAngle);

      path.lineTo(leftX, leftY);
      path.lineTo(rightX, rightY);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class EnhancedGetStartedButton extends StatefulWidget {
  final VoidCallback onTap;
  const EnhancedGetStartedButton({Key? key, required this.onTap})
    : super(key: key);

  @override
  State<EnhancedGetStartedButton> createState() =>
      _EnhancedGetStartedButtonState();
}

class _EnhancedGetStartedButtonState extends State<EnhancedGetStartedButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isRTL = languageService.isRTL;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          width: double.infinity,
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isPressed
                  ? [const Color(0xFFE0C890), const Color(0xFFD4B885)]
                  : _isHovered
                  ? [const Color(0xFFF5E5C8), const Color(0xFFE8C998)]
                  : [Colors.white, const Color(0xFFF5F5F5)],
            ),
            boxShadow: [
              if (_isPressed)
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else if (_isHovered) ...[
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  spreadRadius: 4,
                ),
              ] else
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          transform: Matrix4.identity()
            ..translate(0.0, _isPressed ? 2.0 : (_isHovered ? -4.0 : 0.0))
            ..scale(_isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Shimmer Effect
                if (_isHovered)
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Positioned(
                        left: -500 + (_shimmerController.value * 1000),
                        top: 0,
                        bottom: 0,
                        width: 400,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white60,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.get(
                          'getStarted',
                          languageService.currentLanguage,
                        ),
                        style: const TextStyle(
                          color: Color(0xFF5BA5CE),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.only(
                          left: isRTL ? 0 : (_isHovered ? 20 : 12),
                          right: isRTL ? (_isHovered ? 20 : 12) : 0,
                        ),
                        child: Icon(
                          isRTL
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          color: const Color(0xFF5BA5CE),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
