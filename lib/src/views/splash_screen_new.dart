import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:TURF_TOWN_/src/CommonParameters/AppBackGround1/Appbg1.dart';
import 'package:TURF_TOWN_/src/views/Sliding_page.dart';

class SplashScreenNew extends StatefulWidget {
  const SplashScreenNew({super.key});

  @override
  State<SplashScreenNew> createState() => _SplashScreenNewState();
}

class _SplashScreenNewState extends State<SplashScreenNew>
    with TickerProviderStateMixin {
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  int _currentAnimationPhase = 0; // 0: Sports loader, 1: Cricket loader, 2: App name
  bool _showAppName = false;

  @override
  void initState() {
    super.initState();

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _zoomAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    // Phase 1: Sports loader (1200ms zoom + 2000ms display)
    _zoomController.forward();

    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        // Phase 2: Cricket bat & ball bouncing loader
        setState(() => _currentAnimationPhase = 1);
        _zoomController.reset();
        _zoomController.forward();
      }
    });

    // Phase 3: Display app name after all animations
    Timer(const Duration(milliseconds: 6400), () {
      if (mounted) {
        setState(() {
          _currentAnimationPhase = 2;
          _showAppName = true;
        });
      }
    });

    // Navigate after complete splash sequence
    Timer(const Duration(milliseconds: 9400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SlidingPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Appbg1.mainGradient),
        child: Stack(
          children: [
            // Animation content
            Center(
              child: ScaleTransition(
                scale: _zoomAnimation,
                child: _currentAnimationPhase == 0
                    ? _buildSportsLoader()
                    : _currentAnimationPhase == 1
                        ? _buildCricketLoader()
                        : const SizedBox.shrink(),
              ),
            ),

            // App name display (appears after animations)
            if (_showAppName)
              Center(
                child: AnimatedOpacity(
                  opacity: _showAppName ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFFE3F2FD),
                            Colors.white,
                            Color(0xFFFFF3E0),
                          ],
                          stops: [0.0, 0.3, 0.7, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          'CricSync',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Poppins',
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 8),
                                blurRadius: 20,
                              ),
                              Shadow(
                                color: Colors.blue.withValues(alpha: 0.5),
                                offset: Offset(-3, -3),
                                blurRadius: 15,
                              ),
                              Shadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                offset: Offset(3, 3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your Ultimate Sports Hub',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
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

  Widget _buildSportsLoader() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset(
        'assets/images/Sports loader.json',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildCricketLoader() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Lottie.asset(
        'assets/images/Cricket bat & ball bouncing loader.json',
        fit: BoxFit.contain,
      ),
    );
  }
}
