import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Color palette
const Color colorCharcoal = Color(0xFF282828);
const Color colorWarmSand = Color(0xFFE6CA9A);
const Color colorSage = Color(0xFFCBD77A);
const Color colorWhite = Color(0xFFFFFFFF);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medtech',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const OnboardingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation =
        Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation =
        Tween<double>(begin: 30.0, end: 0.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Start fade animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Column(
            children: [
              // Status bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '9:41',
                      style: TextStyle(
                          color: colorCharcoal,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.signal_cellular_4_bar,
                            color: colorCharcoal, size: 16),
                        SizedBox(width: 4),
                        Icon(Icons.wifi, color: colorCharcoal, size: 16),
                        SizedBox(width: 4),
                        Icon(Icons.battery_full, color: colorCharcoal, size: 16),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(),

                      // Illustration with Pulse
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 256 + (_pulseController.value * 80),
                                    height: 256 + (_pulseController.value * 80),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorSage.withOpacity(
                                              0.4 * (1 - _pulseController.value)),
                                          blurRadius: 0,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 256,
                                height: 256,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [colorSage, colorWarmSand]),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 176,
                                    height: 176,
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 40,
                                          offset: const Offset(0, 10),
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

                      const SizedBox(height: 64),

                      // Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'Track Your Health',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: colorCharcoal,
                              letterSpacing: -0.5),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'Monitor your vital signs, medications,\nand appointments all in one place',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: colorCharcoal,
                              height: 1.5),
                        ),
                      ),

                      const Spacer(),

                      // Next button
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [colorSage, colorWarmSand]),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Navigate to next page
                              },
                              borderRadius: BorderRadius.circular(28),
                              child: const Center(
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: colorWhite),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Page indicators
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIndicator(8, false, false),
                            const SizedBox(width: 8),
                            _buildIndicator(24, true, true),
                            const SizedBox(width: 8),
                            _buildIndicator(8, false, false),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(double width, bool isActive, bool isGradient) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: 8,
      decoration: BoxDecoration(
        gradient: isGradient
            ? const LinearGradient(colors: [colorSage, colorWarmSand])
            : null,
        color: !isGradient ? colorCharcoal.withOpacity(0.15) : null,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
