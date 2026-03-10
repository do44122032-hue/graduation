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
      home: const OnboardingPageThree(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnboardingPageThree extends StatefulWidget {
  const OnboardingPageThree({Key? key}) : super(key: key);

  @override
  State<OnboardingPageThree> createState() => _OnboardingPageThreeState();
}

class _OnboardingPageThreeState extends State<OnboardingPageThree>
    with TickerProviderStateMixin {
  // Color palette
  static const Color colorCharcoal = Color(0xFF282828);
  static const Color colorWarmSand = Color(0xFFE6CA9A);
  static const Color colorSage = Color(0xFFCBD77A);
  static const Color colorWhite = Color(0xFFFFFFFF);

  late AnimationController _fadeController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

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

                      // Illustration - Three overlapping circles
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: SizedBox(
                            width: 256,
                            height: 256,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Left circle
                                _buildDelayedCircle(
                                  width: 128,
                                  height: 128,
                                  color: colorSage.withOpacity(0.6),
                                  alignment: Alignment.centerLeft,
                                  delay: 0.1,
                                  shadow: BoxShadow(
                                    color: colorSage.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ),

                                // Right circle
                                _buildDelayedCircle(
                                  width: 128,
                                  height: 128,
                                  color: colorWarmSand.withOpacity(0.6),
                                  alignment: Alignment.centerRight,
                                  delay: 0.2,
                                  shadow: BoxShadow(
                                    color: colorWarmSand.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ),

                                // Center circle with gradient
                                FadeTransition(
                                  opacity: Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(
                                    CurvedAnimation(
                                      parent: _fadeController,
                                      curve: const Interval(0.3, 1.0,
                                          curve: Curves.easeOut),
                                    ),
                                  ),
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.8, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _fadeController,
                                        curve: const Interval(0.3, 1.0,
                                            curve: Curves.easeOut),
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Pulse ring
                                        AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return Container(
                                              width: 160 +
                                                  (_pulseController.value * 80),
                                              height: 160 +
                                                  (_pulseController.value * 80),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: colorSage.withOpacity(
                                                      0.4 *
                                                          (1 -
                                                              _pulseController
                                                                  .value),
                                                    ),
                                                    blurRadius: 0,
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                        // Gradient circle
                                        Container(
                                          width: 160,
                                          height: 160,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [colorSage, colorWarmSand],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    colorSage.withOpacity(0.4),
                                                blurRadius: 40,
                                                offset: const Offset(0, 15),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: colorWhite,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2),
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
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 64),

                      // Title
                      _buildAnimatedText(
                        'Stay Connected',
                        delay: 0.4,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: colorCharcoal,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      _buildAnimatedText(
                        'Connect with healthcare providers\nand get support anytime, anywhere',
                        delay: 0.5,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorCharcoal.withOpacity(0.6),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      // Get Started button
                      _buildAnimatedButton(
                        'Get Started',
                        delay: 0.6,
                        isPrimary: true,
                      ),

                      const SizedBox(height: 16),

                      // Skip button
                      _buildAnimatedButton(
                        'Skip',
                        delay: 0.7,
                        isPrimary: false,
                      ),

                      const SizedBox(height: 16),

                      // Page indicators
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.8, 1.0,
                                curve: Curves.easeOut),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIndicator(8, false, false),
                            const SizedBox(width: 8),
                            _buildIndicator(8, false, false),
                            const SizedBox(width: 8),
                            _buildIndicator(24, true, true),
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

  Widget _buildDelayedCircle({
    required double width,
    required double height,
    required Color color,
    required Alignment alignment,
    required double delay,
    required BoxShadow shadow,
  }) {
    return Align(
      alignment: alignment,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Interval(delay, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: _fadeController,
              curve: Interval(delay, 1.0, curve: Curves.easeOut),
            ),
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [shadow],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(
    String text, {
    required double delay,
    required TextStyle style,
    TextAlign textAlign = TextAlign.center,
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
            offset: Offset(0, 30 * (1 - progress)),
            child: child,
          );
        },
        child: Text(
          text,
          textAlign: textAlign,
          style: style,
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(String text,
      {required double delay, required bool isPrimary}) {
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
            offset: Offset(0, 30 * (1 - progress)),
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: isPrimary ? 56 : 48,
          decoration: isPrimary
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorSage, colorWarmSand],
                  ),
                  borderRadius: BorderRadius.circular(isPrimary ? 28 : 24),
                  boxShadow: [
                    BoxShadow(
                      color: colorSage.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                )
              : null,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate or perform action
              },
              borderRadius: BorderRadius.circular(isPrimary ? 28 : 24),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
                    color: isPrimary
                        ? colorWhite
                        : colorCharcoal.withOpacity(0.5),
                  ),
                ),
              ),
            ),
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
            ? const LinearGradient(
                colors: [colorSage, colorWarmSand],
              )
            : null,
        color: !isGradient ? colorCharcoal.withOpacity(0.15) : null,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}