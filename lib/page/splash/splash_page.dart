import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_88trans/page/auth/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _busController;
  late AnimationController _roadController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _busAnimation;
  late Animation<double> _roadAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation untuk logo dan text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Bus animation - bergerak dari kiri ke kanan
    _busController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _busAnimation = Tween<double>(begin: -1.0, end: 1.2).animate(
      CurvedAnimation(parent: _busController, curve: Curves.easeInOut),
    );

    // Road animation - garis jalan bergerak
    _roadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _roadAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _roadController,
    );

    _fadeController.forward();
    _busController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _busController.dispose();
    _roadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Animated road lines
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _roadAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 4),
                    painter: RoadPainter(_roadAnimation.value),
                  );
                },
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', width: 140),
                    const SizedBox(height: 20),
                    const Text(
                      "88Trans Travel",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Explore Your Journey",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Animated bus
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _busAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _busAnimation.value * MediaQuery.of(context).size.width,
                      0,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_bus_rounded,
                        size: 60,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Loading indicator
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Memuat aplikasi...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter untuk garis jalan yang bergerak
class RoadPainter extends CustomPainter {
  final double animationValue;

  RoadPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const dashWidth = 40.0;
    const dashSpace = 30.0;
    double startX = -(animationValue * (dashWidth + dashSpace));

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(RoadPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}