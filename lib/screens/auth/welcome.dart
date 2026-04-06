import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'role_selection.dart';

// ─────────────────────────────────────────────
//  WelcomeScreen (Entry point switcher)
// ─────────────────────────────────────────────

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const NightWelcomeScreen() : const DayWelcomeScreen();
  }
}

// ─────────────────────────────────────────────
//  Day Mode Welcome Screen (Original)
// ─────────────────────────────────────────────

class DayWelcomeScreen extends StatefulWidget {
  const DayWelcomeScreen({super.key});

  @override
  State<DayWelcomeScreen> createState() => _DayWelcomeScreenState();
}

class _DayWelcomeScreenState extends State<DayWelcomeScreen>
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
//  Night Mode Welcome Screen (New)
// ─────────────────────────────────────────────

class NightWelcomeScreen extends StatefulWidget {
  const NightWelcomeScreen({super.key});

  @override
  State<NightWelcomeScreen> createState() => _NightWelcomeScreenState();
}

class _NightWelcomeScreenState extends State<NightWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _moonGlowController;
  late AnimationController _moonFloatController;
  late List<AnimationController> _starControllers;
  late List<AnimationController> _shootControllers;
  late AnimationController _entranceController;
  late AnimationController _logoFloatController;

  late Animation<double> _moonGlowAnim;
  late Animation<double> _moonFloatAnim;
  late List<Animation<double>> _starAnims;
  late List<Animation<double>> _shootAnims;
  late Animation<double> _logoFloatAnim;

  late Animation<double> _nameFade;
  late Animation<Offset> _nameSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  // [top, left, size, animIndex(0-2)]
  final List<List<double>> _stars = const [
    [18, 22, 3.0, 0], [25, 80, 2.0, 1], [12, 155, 2.5, 2],
    [30, 240, 2.0, 0], [8, 310, 3.0, 1], [20, 360, 2.0, 2],
    [60, 40, 2.0, 1], [55, 110, 2.5, 0], [70, 198, 2.0, 2],
    [48, 275, 3.0, 0], [65, 345, 2.0, 1], [105, 18, 2.0, 2],
    [115, 70, 2.5, 0], [95, 170, 2.0, 1], [120, 255, 3.0, 2],
    [100, 330, 2.0, 0], [162, 130, 2.5, 2], [148, 220, 2.0, 0],
    [205, 280, 2.0, 0], [210, 30, 2.0, 0], [200, 95, 2.5, 1],
    [215, 185, 2.0, 2], [170, 300, 2.0, 1], [260, 55, 2.0, 2],
    [275, 160, 2.0, 0], [255, 320, 2.5, 1],
  ];

  // [top, left, width, delayMs]
  final List<List<double>> _shootingStars = const [
    [40, 20, 120, 1000],
    [90, 200, 95, 5000],
    [25, 280, 130, 9000],
    [140, 60, 100, 13000],
    [60, 240, 110, 17000],
  ];

  @override
  void initState() {
    super.initState();

    // Moon glow
    _moonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _moonGlowAnim = Tween<double>(begin: 0.6, end: 0.9).animate(
      CurvedAnimation(parent: _moonGlowController, curve: Curves.easeInOut),
    );

    // Moon float
    _moonFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _moonFloatAnim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _moonFloatController, curve: Curves.easeInOut),
    );

    // Stars — 3 twinkle patterns
    final twinkleDurations = [
      const Duration(milliseconds: 2800),
      const Duration(milliseconds: 3500),
      const Duration(milliseconds: 2200),
    ];
    _starControllers = List.generate(3, (i) {
      final c = AnimationController(vsync: this, duration: twinkleDurations[i]);
      Future.delayed(Duration(milliseconds: i * 400), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
    _starAnims = _starControllers
        .map((c) => Tween<double>(begin: 0.15, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    // Shooting stars
    final shootDurations = [3500, 4000, 3800, 3200, 4200];
    _shootControllers = List.generate(5, (i) {
      final c = AnimationController(
          vsync: this, duration: Duration(milliseconds: shootDurations[i]));
      Future.delayed(
        Duration(milliseconds: _shootingStars[i][3].toInt()),
        () {
          if (mounted) c.repeat();
        },
      );
      return c;
    });
    _shootAnims = _shootControllers
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: c, curve: Curves.easeIn),
            ))
        .toList();

    // Entrance
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _logoFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _logoFloatAnim = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _logoFloatController, curve: Curves.easeInOut),
    );

    _nameFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
    ));
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _moonGlowController.dispose();
    _moonFloatController.dispose();
    for (final c in _starControllers) c.dispose();
    for (final c in _shootControllers) c.dispose();
    _entranceController.dispose();
    _logoFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF05051A),
      body: Stack(
        children: [
          // ── Background gradient ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF05051A),
                    Color(0xFF0A0A2E),
                    Color(0xFF0D1040),
                    Color(0xFF111550),
                    Color(0xFF0F1A3A),
                    Color(0xFF0A1528),
                    Color(0xFF081020),
                  ],
                  stops: [0.0, 0.2, 0.38, 0.52, 0.68, 0.82, 1.0],
                ),
              ),
            ),
          ),

          // ── Stars ──
          ..._stars.map((s) {
            final idx = s[3].toInt();
            return AnimatedBuilder(
              animation: _starAnims[idx],
              builder: (_, __) => Positioned(
                top: s[0],
                left: s[1],
                child: Opacity(
                  opacity: _starAnims[idx].value,
                  child: Container(
                    width: s[2],
                    height: s[2],
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),

          // ── Moon glow ──
          AnimatedBuilder(
            animation: _moonGlowAnim,
            builder: (_, __) => Positioned(
              top: 18,
              left: w / 2 - 80,
              child: Opacity(
                opacity: _moonGlowAnim.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.28),
                        const Color(0xFFB4D2FF).withOpacity(0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 0.75],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Moon body ──
          AnimatedBuilder(
            animation: _moonFloatAnim,
            builder: (_, __) => Positioned(
              top: 42 + _moonFloatAnim.value,
              left: w / 2 - 45,
              child: CustomPaint(
                size: const Size(90, 90),
                painter: _MoonPainter(),
              ),
            ),
          ),

          // ── Shooting stars ──
          ...List.generate(5, (i) {
            return AnimatedBuilder(
              animation: _shootAnims[i],
              builder: (_, __) {
                final t = _shootAnims[i].value;
                final opacity =
                    (t < 0.7 ? 1.0 : (1.0 - t) / 0.3).clamp(0.0, 1.0);
                final dx = t * 300;
                final dy = t * 300;
                final star = _shootingStars[i];
                return Positioned(
                  top: star[0] + dy,
                  left: star[1] + dx,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: 45 * pi / 180,
                      child: CustomPaint(
                        size: Size(star[2], 4),
                        painter: _ShootingStarPainter(),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // ── Ground + Trees (taller canvas so trees show above hills) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(w, 140),
              painter: _NightGroundPainter(),
            ),
          ),

          // ── Moonlight ground reflection ──
          Positioned(
            bottom: 80,
            left: w / 2 - 90,
            child: Container(
              width: 180,
              height: 40,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC8DCFF).withOpacity(0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.75],
                ),
              ),
            ),
          ),

          // ── App name + tagline ──
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

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

                const SizedBox(height: 12),

                FadeTransition(
                  opacity: _taglineFade,
                  child: const Text(
                    'Your Health, In Your Hands',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xDDC8DCFF),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Welcome button ──
                FadeTransition(
                  opacity: _buttonFade,
                  child: SlideTransition(
                    position: _buttonSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RoleSelectionScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0x4DFFFFFF),
                              width: 1.5,
                            ),
                            backgroundColor: Colors.white.withOpacity(0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
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

// ─────────────────────────────────────────────
//  Night Mode Painters
// ─────────────────────────────────────────────

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 1;

    // Moon disc
    final moonPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 1.0,
        colors: const [
          Color(0xFFFFFDE8),
          Color(0xFFE8EFD8),
          Color(0xFFC8D8C0),
          Color(0xFFA8C0A8),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, moonPaint);

    // Shine
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.50),
          radius: 0.75,
          colors: [Colors.white.withOpacity(0.6), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // Craters
    final cp = Paint()..color = const Color(0xFF96AF96).withOpacity(0.32);
    canvas.drawCircle(Offset(cx - 13, cy - 7), 5, cp);
    canvas.drawCircle(Offset(cx + 13, cy - 15), 3.5, cp);
    canvas.drawCircle(Offset(cx + 5, cy + 10), 4, cp);
    canvas.drawCircle(Offset(cx - 17, cy + 11), 2.5, cp);
    canvas.drawCircle(Offset(cx + 17, cy + 3), 3, cp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ShootingStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Trail
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width - 2, 2),
        const Radius.circular(1),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.85),
            Colors.white,
          ],
          stops: const [0.0, 0.75, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, 2)),
    );
    // Head glow
    canvas.drawCircle(
      Offset(size.width, 1),
      2.5,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _NightGroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height; // 140px — gives trees room above hills

    // Hill 1 (back, lighter dark)
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..quadraticBezierTo(w * 0.13, h * 0.57, w * 0.28, h * 0.71)
        ..quadraticBezierTo(w * 0.45, h * 0.86, w * 0.58, h * 0.56)
        ..quadraticBezierTo(w * 0.72, h * 0.34, w * 0.85, h * 0.66)
        ..quadraticBezierTo(w * 0.93, h * 0.77, w, h * 0.66)
        ..lineTo(w, h)
        ..close(),
      Paint()..color = const Color(0xFF0A0F23),
    );

    // Hill 2 (front, darkest)
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..quadraticBezierTo(w * 0.12, h * 0.73, w * 0.26, h * 0.80)
        ..quadraticBezierTo(w * 0.41, h * 0.89, w * 0.55, h * 0.75)
        ..quadraticBezierTo(w * 0.69, h * 0.61, w * 0.82, h * 0.77)
        ..quadraticBezierTo(w * 0.91, h * 0.86, w, h * 0.77)
        ..lineTo(w, h)
        ..close(),
      Paint()..color = const Color(0xFF05080E),
    );

    // Trees — drawn AFTER hills so they appear on top
    final tp = Paint()..color = const Color(0xFF05080F);

    // Left trees
    _tree(canvas, tp, w * 0.040, h * 0.41, h * 0.42);
    _tree(canvas, tp, w * 0.095, h * 0.49, h * 0.32);
    _tree(canvas, tp, w * 0.148, h * 0.44, h * 0.38);

    // Right trees
    _tree(canvas, tp, w * 0.815, h * 0.39, h * 0.44);
    _tree(canvas, tp, w * 0.870, h * 0.45, h * 0.35);
    _tree(canvas, tp, w * 0.922, h * 0.41, h * 0.40);
  }

  void _tree(Canvas canvas, Paint p, double x, double base, double h) {
    // Trunk
    canvas.drawRect(Rect.fromLTWH(x - 3, base, 6, h * 0.35), p);
    // Lower cone
    canvas.drawPath(
      Path()
        ..moveTo(x, base - h * 0.30)
        ..lineTo(x - h * 0.20, base + h * 0.08)
        ..lineTo(x + h * 0.20, base + h * 0.08)
        ..close(),
      p,
    );
    // Upper cone
    canvas.drawPath(
      Path()
        ..moveTo(x, base - h * 0.55)
        ..lineTo(x - h * 0.14, base - h * 0.18)
        ..lineTo(x + h * 0.14, base - h * 0.18)
        ..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
