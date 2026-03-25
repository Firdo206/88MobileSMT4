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
  late AnimationController _controller;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoTranslateY;
  late Animation<double> _logoTranslateX;
  late Animation<double> _textOpacity;
  late Animation<double> _textTranslateX;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    /// ⿡ Naik + membesar + fade in
    _logoScale = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.3)),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.3)),
    );

    _logoTranslateY = Tween<double>(begin: 300, end: -80).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.3)),
    );

    /// ⿢ Bounce turun
    _logoTranslateY = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 0.5, curve: Curves.bounceOut),
      ),
    );

    /// ⿣ Geser kiri
    _logoTranslateX = Tween<double>(begin: 0, end: -80).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.5, 0.7)),
    );

    /// ⿤ Text masuk dari kanan
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.7, 1)),
    );

    _textTranslateX = Tween<double>(begin: 200, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.7, 1)),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO
                Transform.translate(
                  offset: Offset(_logoTranslateX.value, _logoTranslateY.value),
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 80,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// TEXT
                Transform.translate(
                  offset: Offset(_textTranslateX.value, 0),
                  child: Opacity(
                    opacity: _textOpacity.value,
                    child: const Text(
                      "88Trans",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}