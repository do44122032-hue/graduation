import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'role_selection.dart';

// ─────────────────────────────────────────────
//  Usage in main.dart:
//
//  void main() => runApp(MaterialApp(
//    home: WelcomeScreen(),
//  ));
// ─────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _raysController;
  late AnimationController _cloud1Controller;
  late AnimationController _cloud2Controller;
  late AnimationController _cloud3Controller;
  late AnimationController _shimmerController;
  late AnimationController _entranceController;
  late AnimationController _groundController;
  late AnimationController _logoFloatController;

  late Animation<double> _cloud1Anim;
  late Animation<double> _cloud2Anim;
  late Animation<double> _cloud3Anim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _logoFloatAnim;
  late Animation<double> _nameFade;
  late Animation<double> _taglineFade;
  late Animation<double> _buttonFade;
  late Animation<Offset> _nameSlide;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _groundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _cloud1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 42),
    )..repeat();
    _cloud1Anim = Tween<double>(
      begin: -400,
      end: 1400,
    ).animate(CurvedAnimation(parent: _cloud1Controller, curve: Curves.linear));

    _cloud2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
    _cloud2Anim = Tween<double>(
      begin: -300,
      end: 1400,
    ).animate(CurvedAnimation(parent: _cloud2Controller, curve: Curves.linear));

    _cloud3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _cloud3Anim = Tween<double>(
      begin: -220,
      end: 1400,
    ).animate(CurvedAnimation(parent: _cloud3Controller, curve: Curves.linear));

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _shimmerAnim = Tween<double>(begin: 0.12, end: 0.28).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _nameFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _nameSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
      ),
    );

    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        );

    _logoFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _logoFloatAnim = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _logoFloatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _raysController.dispose();
    _groundController.dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _cloud3Controller.dispose();
    _shimmerController.dispose();
    _entranceController.dispose();
    _logoFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildSky(context)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Spacer(flex: 4),

                // App name & Logo
                FadeTransition(
                  opacity: _nameFade,
                  child: SlideTransition(
                    position: _nameSlide,
                    child: Column(
                      children: [
                        // Clean Floating Logo
                        AnimatedBuilder(
                          animation: _logoFloatAnim,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _logoFloatAnim.value),
                              child: child,
                            );
                          },
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.medical_services_rounded,
                                    size: 140,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Carely',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 2.4,
                            shadows: [
                              Shadow(
                                color: Color(0x33000000),
                                blurRadius: 14,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                FadeTransition(
                  opacity: _taglineFade,
                  child: const Text(
                    'Your Health, In Your Hands',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Color(0x33000000),
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Professional Floating Glass Button
                FadeTransition(
                  opacity: _buttonFade,
                  child: SlideTransition(
                    position: _buttonSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RoleSelectionScreen(),
                                ),
                              );
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Welcome',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSky(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7ECFC8),
            Color(0xFFA8D8A0),
            Color(0xFFC8DC88),
            Color(0xFFD8D070),
            Color(0xFFC8C868),
            Color(0xFFB8C060),
          ],
          stops: [0.0, 0.25, 0.5, 0.65, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Sun glow
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: const Offset(0, -55),
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.78),
                      const Color(0xFFFFF064).withOpacity(0.32),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 0.75],
                  ),
                ),
              ),
            ),
          ),

          // Rotating rays
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: const Offset(0, -138),
              child: AnimatedBuilder(
                animation: _raysController,
                builder: (_, __) => Transform.rotate(
                  angle: _raysController.value * 2 * pi,
                  child: Opacity(
                    opacity: 0.23,
                    child: CustomPaint(
                      size: const Size(520, 520),
                      painter: _RaysPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Cloud 1 (Large, white)
          AnimatedBuilder(
            animation: _cloud1Anim,
            builder: (_, __) => PositionedDirectional(
              top: 115,
              start: _cloud1Anim.value,
              child: CustomPaint(
                size: const Size(400, 120),
                painter: _RealisticCloudPainter(
                  color: Colors.white,
                  size: CloudSize.large,
                  opacities: const [0.16, 0.52, 0.7, 0.56, 0.36],
                ),
              ),
            ),
          ),

          // Cloud 2 (Medium, light green)
          AnimatedBuilder(
            animation: _cloud2Anim,
            builder: (_, __) => PositionedDirectional(
              top: 205,
              start: _cloud2Anim.value,
              child: CustomPaint(
                size: const Size(300, 95),
                painter: _RealisticCloudPainter(
                  color: const Color(0xFFC8F0D2),
                  size: CloudSize.medium,
                  opacities: const [0.22, 0.58, 0.62, 0.42],
                ),
              ),
            ),
          ),

          // Cloud 3 (Small, yellow-green)
          AnimatedBuilder(
            animation: _cloud3Anim,
            builder: (_, __) => PositionedDirectional(
              top: 82,
              start: _cloud3Anim.value,
              child: CustomPaint(
                size: const Size(220, 75),
                painter: _RealisticCloudPainter(
                  color: const Color(0xFFDCEB9A),
                  size: CloudSize.small,
                  opacities: const [0.20, 0.46, 0.40],
                ),
              ),
            ),
          ),

          // Shimmer
          AnimatedBuilder(
            animation: _shimmerAnim,
            builder: (_, __) => PositionedDirectional(
              bottom: 88,
              start: 0,
              end: 0,
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFFC8D250).withOpacity(_shimmerAnim.value),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Ground & trees
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: AnimatedBuilder(
              animation: _groundController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(screenWidth, 130),
                  painter: _EnhancedGroundPainter(
                    phase: _groundController.value * 2 * pi,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Painters
// ─────────────────────────────────────────────

class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 15) * pi / 180;
      paint.strokeWidth = i % 3 == 0 ? 18 : (i % 2 == 0 ? 13 : 10);
      paint.color = Colors.white.withOpacity(i % 3 == 0 ? 0.7 : 0.55);
      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * -radius,
          center.dy + sin(angle) * -radius,
        ),
        Offset(
          center.dx + cos(angle) * radius,
          center.dy + sin(angle) * radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum CloudSize { small, medium, large }

class _RealisticCloudPainter extends CustomPainter {
  final Color color;
  final CloudSize size;
  final List<double> opacities;

  const _RealisticCloudPainter({
    required this.color,
    required this.size,
    required this.opacities,
  });

  void _drawEllipse(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    double opacity,
  ) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      paint,
    );
  }

  void _drawCircle(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double opacity,
  ) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(cx, cy), r, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (this.size == CloudSize.small) {
      // Bottom base
      _drawEllipse(canvas, w * 0.38, h * 0.72, 58, 22, opacities[0] * 0.7);
      _drawEllipse(canvas, w * 0.58, h * 0.75, 52, 20, opacities[0] * 0.65);

      // Middle puffs
      _drawEllipse(canvas, w * 0.32, h * 0.58, 42, 28, opacities[1]);
      _drawEllipse(canvas, w * 0.48, h * 0.52, 48, 32, opacities[1] * 1.1);
      _drawEllipse(canvas, w * 0.65, h * 0.6, 46, 26, opacities[2]);

      // Top highlights
      _drawEllipse(canvas, w * 0.42, h * 0.38, 32, 22, opacities[1] * 1.15);
      _drawEllipse(canvas, w * 0.56, h * 0.42, 28, 18, opacities[2] * 1.1);

      // Detail puffs
      _drawCircle(canvas, w * 0.28, h * 0.62, 16, opacities[1] * 0.9);
      _drawCircle(canvas, w * 0.72, h * 0.65, 14, opacities[2] * 0.85);

      // Sunlit highlights
      _drawEllipse(canvas, w * 0.38, h * 0.32, 22, 14, 0.4);
      _drawEllipse(canvas, w * 0.52, h * 0.36, 18, 12, 0.35);
    } else if (this.size == CloudSize.medium) {
      // Bottom base
      _drawEllipse(canvas, w * 0.32, h * 0.76, 72, 26, opacities[0] * 0.65);
      _drawEllipse(canvas, w * 0.56, h * 0.78, 68, 24, opacities[0] * 0.6);
      _drawEllipse(canvas, w * 0.76, h * 0.77, 52, 22, opacities[0] * 0.58);

      // Middle body
      _drawEllipse(canvas, w * 0.28, h * 0.6, 58, 34, opacities[1]);
      _drawEllipse(canvas, w * 0.48, h * 0.54, 64, 38, opacities[1] * 1.1);
      _drawEllipse(canvas, w * 0.68, h * 0.58, 60, 32, opacities[2]);
      _drawEllipse(canvas, w * 0.82, h * 0.66, 42, 26, opacities[3]);

      // Upper puffs
      _drawEllipse(canvas, w * 0.38, h * 0.4, 46, 28, opacities[1] * 1.15);
      _drawEllipse(canvas, w * 0.58, h * 0.38, 50, 30, opacities[2] * 1.1);
      _drawEllipse(canvas, w * 0.72, h * 0.44, 38, 24, opacities[2] * 1.05);

      // Detail bumps
      _drawCircle(canvas, w * 0.22, h * 0.58, 20, opacities[1] * 0.9);
      _drawCircle(canvas, w * 0.45, h * 0.32, 18, opacities[2] * 0.95);
      _drawCircle(canvas, w * 0.65, h * 0.32, 16, opacities[2] * 0.9);
      _drawCircle(canvas, w * 0.86, h * 0.62, 14, opacities[3] * 0.85);

      // Sunlit highlights
      _drawEllipse(canvas, w * 0.42, h * 0.28, 28, 16, 0.45);
      _drawEllipse(canvas, w * 0.6, h * 0.3, 24, 14, 0.4);
    } else {
      // Large
      // Bottom foundation
      _drawEllipse(canvas, w * 0.28, h * 0.8, 88, 28, opacities[0] * 0.6);
      _drawEllipse(canvas, w * 0.5, h * 0.82, 120, 30, opacities[0] * 0.65);
      _drawEllipse(canvas, w * 0.72, h * 0.8, 82, 26, opacities[0] * 0.6);
      _drawEllipse(canvas, w * 0.86, h * 0.78, 52, 24, opacities[0] * 0.55);

      // Middle body
      _drawEllipse(canvas, w * 0.24, h * 0.62, 68, 40, opacities[1]);
      _drawEllipse(canvas, w * 0.42, h * 0.56, 76, 46, opacities[1] * 1.1);
      _drawEllipse(canvas, w * 0.6, h * 0.54, 82, 48, opacities[2] * 1.1);
      _drawEllipse(canvas, w * 0.78, h * 0.6, 64, 38, opacities[3]);
      _drawEllipse(canvas, w * 0.88, h * 0.68, 42, 28, opacities[4]);

      // Upper volume
      _drawEllipse(canvas, w * 0.32, h * 0.42, 58, 34, opacities[1] * 1.15);
      _drawEllipse(canvas, w * 0.5, h * 0.38, 68, 38, opacities[2] * 1.15);
      _drawEllipse(canvas, w * 0.68, h * 0.42, 56, 32, opacities[3] * 1.1);
      _drawEllipse(canvas, w * 0.82, h * 0.5, 44, 28, opacities[3] * 1.05);

      // Top billows
      _drawEllipse(canvas, w * 0.38, h * 0.28, 42, 26, opacities[2] * 1.15);
      _drawEllipse(canvas, w * 0.54, h * 0.26, 48, 28, opacities[2] * 1.2);
      _drawEllipse(canvas, w * 0.68, h * 0.3, 38, 24, opacities[3] * 1.1);

      // Detail puffs
      _drawCircle(canvas, w * 0.18, h * 0.6, 24, opacities[1] * 0.9);
      _drawCircle(canvas, w * 0.35, h * 0.5, 22, opacities[1] * 0.95);
      _drawCircle(canvas, w * 0.48, h * 0.22, 20, opacities[2] * 0.95);
      _drawCircle(canvas, w * 0.62, h * 0.24, 18, opacities[2] * 0.9);
      _drawCircle(canvas, w * 0.75, h * 0.36, 16, opacities[3] * 0.9);
      _drawCircle(canvas, w * 0.92, h * 0.64, 14, opacities[4] * 0.85);

      // Sunlit highlights
      _drawEllipse(canvas, w * 0.42, h * 0.22, 32, 18, 0.5);
      _drawEllipse(canvas, w * 0.58, h * 0.2, 36, 20, 0.48);
      _drawEllipse(canvas, w * 0.52, h * 0.32, 24, 14, 0.35);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnhancedGroundPainter extends CustomPainter {
  final double phase;

  _EnhancedGroundPainter({this.phase = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Back hill layer
    final backPath = Path()..moveTo(0, h);
    for (double i = 0; i <= w; i++) {
      final double x = i;
      final double y = h * 0.6 + sin(phase + (x * 0.015)) * 6;
      backPath.lineTo(x, y);
    }
    backPath.lineTo(w, h);
    backPath.close();
    canvas.drawPath(
      backPath,
      Paint()..color = const Color(0xFF8CAA50).withOpacity(0.55),
    );

    // Front hill layer
    final frontPath = Path()..moveTo(0, h);
    for (double i = 0; i <= w; i++) {
      final double x = i;
      final double y = h * 0.7 + cos(phase + (x * 0.02)) * 8;
      frontPath.lineTo(x, y);
    }
    frontPath.lineTo(w, h);
    frontPath.close();
    canvas.drawPath(
      frontPath,
      Paint()..color = const Color(0xFF789B46).withOpacity(0.75),
    );

    // Draw realistic trees - moved with waves
    _drawRealisticTree(
      canvas,
      w * 0.05,
      h * 0.55 + sin(phase + (w * 0.05 * 0.015)) * 6,
      h * 0.55,
    );
    _drawRealisticTree(
      canvas,
      w * 0.16,
      h * 0.52 + sin(phase + (w * 0.16 * 0.015)) * 6,
      h * 0.52,
    );
    _drawRealisticTree(
      canvas,
      w * 0.82,
      h * 0.53 + sin(phase + (w * 0.82 * 0.015)) * 6,
      h * 0.62,
    );
    _drawRealisticTree(
      canvas,
      w * 0.92,
      h * 0.5 + sin(phase + (w * 0.92 * 0.015)) * 6,
      h * 0.58,
    );
  }

  void _drawRealisticTree(Canvas canvas, double x, double base, double height) {
    final trunkWidth = height * 0.14;
    final trunkHeight = height * 0.42;
    final crownWidth = height * 0.9;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + height * 0.06, base + trunkHeight + 2),
        width: crownWidth * 0.9,
        height: 14,
      ),
      Paint()..color = Colors.black.withOpacity(0.18 * 0.6),
    );

    // Main trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - trunkWidth / 2, base, trunkWidth, trunkHeight),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF6B5744),
    );

    // Trunk shading (left)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - trunkWidth / 2, base, trunkWidth * 0.35, trunkHeight),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF4D3D2F).withOpacity(0.5),
    );

    // Trunk highlight (right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + trunkWidth * 0.15,
          base,
          trunkWidth * 0.25,
          trunkHeight,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF8B7355).withOpacity(0.4),
    );

    // Bark texture lines
    canvas.drawLine(
      Offset(x - trunkWidth * 0.25, base + trunkHeight * 0.15),
      Offset(x - trunkWidth * 0.25, base + trunkHeight * 0.85),
      Paint()
        ..color = const Color(0xFF3D3025).withOpacity(0.6)
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      Offset(x + trunkWidth * 0.25, base + trunkHeight * 0.2),
      Offset(x + trunkWidth * 0.25, base + trunkHeight * 0.8),
      Paint()
        ..color = const Color(0xFF65543F).withOpacity(0.4)
        ..strokeWidth = 0.8,
    );

    // Crown layers (bottom to top)
    // Lower crown
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, base - height * 0.12),
        width: crownWidth * 0.58 * 2,
        height: height * 0.38 * 2,
      ),
      Paint()..color = const Color(0xFF3D5A2E),
    );

    // Shadow detail in lower crown
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + crownWidth * 0.15, base - height * 0.08),
        width: crownWidth * 0.28 * 2,
        height: height * 0.18 * 2,
      ),
      Paint()..color = const Color(0xFF2D4222).withOpacity(0.7),
    );

    // Middle crown
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, base - height * 0.24),
        width: crownWidth * 0.52 * 2,
        height: height * 0.34 * 2,
      ),
      Paint()..color = const Color(0xFF527A3F),
    );

    // Upper crown
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x - crownWidth * 0.05, base - height * 0.34),
        width: crownWidth * 0.42 * 2,
        height: height * 0.29 * 2,
      ),
      Paint()..color = const Color(0xFF6B9451),
    );

    // Top highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x - crownWidth * 0.12, base - height * 0.44),
        width: crownWidth * 0.22 * 2,
        height: height * 0.15 * 2,
      ),
      Paint()..color = const Color(0xFF8BB06C).withOpacity(0.85),
    );

    // Additional light spot
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x - crownWidth * 0.18, base - height * 0.38),
        width: crownWidth * 0.12 * 2,
        height: height * 0.08 * 2,
      ),
      Paint()..color = const Color(0xFF9CC37A).withOpacity(0.6),
    );

    // Detail foliage clusters
    canvas.drawCircle(
      Offset(x - crownWidth * 0.45, base - height * 0.22),
      height * 0.11,
      Paint()..color = const Color(0xFF4A6E3A),
    );
    canvas.drawCircle(
      Offset(x + crownWidth * 0.42, base - height * 0.26),
      height * 0.09,
      Paint()..color = const Color(0xFF4A6E3A),
    );
    canvas.drawCircle(
      Offset(x + crownWidth * 0.28, base - height * 0.42),
      height * 0.08,
      Paint()..color = const Color(0xFF6B9451),
    );
    canvas.drawCircle(
      Offset(x - crownWidth * 0.32, base - height * 0.15),
      height * 0.07,
      Paint()..color = const Color(0xFF3D5A2E),
    );

    // Small branch ellipses
    canvas.save();
    canvas.translate(x - crownWidth * 0.38, base - height * 0.3);
    canvas.rotate(-25 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: crownWidth * 0.08 * 2,
        height: height * 0.05 * 2,
      ),
      Paint()..color = const Color(0xFF527A3F),
    );
    canvas.restore();

    canvas.save();
    canvas.translate(x + crownWidth * 0.36, base - height * 0.18);
    canvas.rotate(20 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: crownWidth * 0.07 * 2,
        height: height * 0.04 * 2,
      ),
      Paint()..color = const Color(0xFF4A6E3A),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



