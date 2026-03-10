import 'package:flutter/material.dart';
import 'dart:math' as math;

class RadialShineEffect extends StatefulWidget {
  final double width;
  final double height;
  final double rotationSpeedSeconds;
  final double pulseSpeedSeconds;

  const RadialShineEffect({
    Key? key,
    this.width = 1200,
    this.height = 1200,
    this.rotationSpeedSeconds = 30,
    this.pulseSpeedSeconds = 4,
  }) : super(key: key);

  @override
  State<RadialShineEffect> createState() => _RadialShineEffectState();
}

class _RadialShineEffectState extends State<RadialShineEffect>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse Animation (4s ease-in-out infinite)
    // 0% -> 50% -> 100% (Reverse logic handles the loop back)
    _pulseController = AnimationController(
      duration: Duration(
        milliseconds: (widget.pulseSpeedSeconds * 1000).toInt(),
      ),
      vsync: this,
    )..repeat(reverse: true);

    // Standard 0 -> 1 curve
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Rotation Animation (30s linear infinite)
    _rotationController = AnimationController(
      duration: Duration(
        milliseconds: (widget.rotationSpeedSeconds * 1000).toInt(),
      ),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Bright Central Glow - Multiple layers (Animated Pulse)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              // Keyframes:
              // 0% (val 0): opacity 0.6, scale 1
              // 50% (val 1): opacity 1, scale 1.15
              final value = _pulseAnimation.value;
              final scale = 1.0 + (value * 0.15);
              final opacity = 0.6 + (value * 0.4);

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 1200, // Increased to be larger than logo (800)
                    height: 1200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color.fromRGBO(255, 255, 255, 0.8),
                          const Color.fromRGBO(255, 255, 200, 0.4),
                          const Color.fromRGBO(255, 255, 255, 0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.2, 0.4, 0.7],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 2. Secondary Glow (Delayed pulse)
          AnimatedBuilder(
            animation:
                _pulseController, // Use controller to manually offset phase
            builder: (context, child) {
              // Delayed by 0.5s in 4s cycle?
              // 4s cycle = 2s up, 2s down.
              // Just approximation: sin wave offset
              double t = _pulseController.value;
              // Simplest visual approx: use same pulse but slightly different curve or lag
              // Let's stick to the previous implementation but refined
              final opacity = 0.5 + (t * 0.4); // 0.5 -> 0.9

              return Opacity(
                opacity: opacity,
                child: Container(
                  width: 900, // Increased
                  height: 900,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color.fromRGBO(255, 255, 255, 0.9),
                        const Color.fromRGBO(255, 255, 255, 0.5),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.6],
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Rotating Rays
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              // Reduced blur slightly for sharper rays as in image
              // Actually removing blur entirely for crisp lines as per new image requirement
              child: Stack(
                alignment: Alignment.center,
                children: List.generate(60, (index) {
                  return _buildRay(index, widget.width, widget.height);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRay(int index, double totalWidth, double totalHeight) {
    // 60 rays
    final angle = (index * 360 / 60) * (math.pi / 180);

    // Sharp, thin rays
    final rayWidth = 3.0; // Thinner for elegance
    final rayHeight = totalWidth * 0.8;

    return Positioned(
      top: totalHeight / 2,
      left: totalWidth / 2 - (rayWidth / 2),
      child: Transform(
        transform: Matrix4.identity()..rotateZ(angle),
        alignment: Alignment.topCenter,
        child: Container(
          width: rayWidth,
          height: rayHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromRGBO(
                  255,
                  255,
                  255,
                  0.5,
                ), // Less opaque at start
                const Color.fromRGBO(255, 255, 255, 0.2),
                const Color.fromRGBO(255, 255, 255, 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
