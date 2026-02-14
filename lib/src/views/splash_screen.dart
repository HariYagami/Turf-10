import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:TURF_TOWN_/src/CommonParameters/AppBackGround1/Appbg1.dart';
import 'package:TURF_TOWN_/src/views/Sliding_page.dart';
import 'package:TURF_TOWN_/src/services/splash_animations_service.dart';
import 'package:TURF_TOWN_/src/widgets/morphing_sport_shape.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  late SplashAnimationsService _animationsService;

  int _currentPhase = 0;

  @override
  void initState() {
    super.initState();

    // Initialize morphing animations service
    _animationsService = SplashAnimationsService();
    _animationsService.initialize(this);
    _animationsService.startAnimations();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _mainController.addListener(() {
      if (_animation.value < 0.33) {
        if (_currentPhase != 0) {
          setState(() => _currentPhase = 0);
          _fadeController.forward(from: 0);
        }
      } else if (_animation.value < 0.66) {
        if (_currentPhase != 1) {
          setState(() => _currentPhase = 1);
          _fadeController.forward(from: 0);
        }
      } else {
        if (_currentPhase != 2) {
          setState(() => _currentPhase = 2);
          _fadeController.forward(from: 0);
        }
      }
    });

    _mainController.forward();

    Timer(const Duration(milliseconds: 5200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => SlidingPage(),
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
    _animationsService.dispose();
    _mainController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Appbg1.mainGradient),
        child: Stack(
          children: [
            // Parallax background layers
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: Transform.translate(
                      offset: Offset(
                        math.sin(_glowController.value * 2 * math.pi) * 30,
                        math.cos(_glowController.value * 2 * math.pi) * 20,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.5,
                            colors: [
                              Colors.blue.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Animated particle background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticlesPainter(_particleController.value),
                  );
                },
              ),
            ),
            
            // Main animated content
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  children: [
                    if (_currentPhase == 0) _buildCricketAnimation(),
                    if (_currentPhase == 1) _buildBadmintonAnimation(),
                    if (_currentPhase == 2) _buildFootballAnimation(),

                    // Morphing Sport Shape Overlays (Responsive)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            MorphingSportShape(
                              sportType: 'cricket',
                              morphValue: _animationsService.getCricketMorphAnimation(),
                              shadowValue: _animationsService.getCricketShadowAnimation(),
                              rotationValue: _animationsService.getCricketRotationAnimation(),
                              position: Offset(constraints.maxWidth * 0.1, constraints.maxHeight * 0.2),
                            ),
                            MorphingSportShape(
                              sportType: 'badminton',
                              morphValue: _animationsService.getBadmintonMorphAnimation(),
                              shadowValue: _animationsService.getBadmintonShadowAnimation(),
                              rotationValue: _animationsService.getBadmintonRotationAnimation(),
                              position: Offset(constraints.maxWidth * 0.65, constraints.maxHeight * 0.22),
                            ),
                            MorphingSportShape(
                              sportType: 'football',
                              morphValue: _animationsService.getFootballMorphAnimation(),
                              shadowValue: _animationsService.getFootballShadowAnimation(),
                              rotationValue: _animationsService.getFootballRotationAnimation(),
                              position: Offset(constraints.maxWidth * 0.35, constraints.maxHeight * 0.45),
                            ),
                          ],
                        );
                      },
                    ),

                    // 3D App branding
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX(0.05 * math.sin(_glowController.value * math.pi))
                                  ..rotateY(0.05 * math.cos(_glowController.value * math.pi)),
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3 + (_glowController.value * 0.2)),
                                        blurRadius: 40 + (_glowController.value * 20),
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ShaderMask(
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
                                      'CricTrax',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 52,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Poppins',
                                        letterSpacing: 6,
                                        height: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(0, 8),
                                            blurRadius: 20,
                                          ),
                                          Shadow(
                                            color: Colors.blue.withOpacity(0.5),
                                            offset: Offset(-3, -3),
                                            blurRadius: 15,
                                          ),
                                          Shadow(
                                            color: Colors.orange.withOpacity(0.3),
                                            offset: Offset(3, 3),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.002)
                                  ..rotateX(-0.1),
                                alignment: Alignment.center,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Your Ultimate Sports Hub',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      letterSpacing: 3,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          offset: Offset(0, 2),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCricketAnimation() {
    double progress = (_animation.value * 3).clamp(0.0, 1.0);
    
    double batRotation = progress < 0.4 
        ? -0.6 + (Curves.easeInCubic.transform(progress / 0.4) * 1.4)
        : 0.8;
    
    double ballProgress = progress < 0.4 ? 0 : (progress - 0.4) / 0.6;
    double ballX = Curves.easeOut.transform(ballProgress) * 400;
    double ballY = -ballProgress * 200 + (ballProgress * ballProgress * 250);
    double ballRotation = ballProgress * 8 * math.pi;
    
    double impactOpacity = (progress > 0.38 && progress < 0.45) 
        ? 1.0 - ((progress - 0.38) / 0.07)
        : 0.0;

    // 3D depth effect
    double depthScale = 0.95 + (0.05 * math.sin(progress * math.pi * 2));

    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0.1)
          ..scale(depthScale),
        alignment: Alignment.center,
        child: SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Enhanced motion blur trail
              if (ballProgress > 0)
                ...List.generate(7, (i) {
                  double trailProgress = (ballProgress - (i * 0.04)).clamp(0.0, 1.0);
                  double trailX = Curves.easeOut.transform(trailProgress) * 400;
                  double trailY = -trailProgress * 200 + (trailProgress * trailProgress * 250);
                  return Transform.translate(
                    offset: Offset(trailX, trailY),
                    child: Container(
                      width: 32 - (i * 2),
                      height: 32 - (i * 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.red.withOpacity(0.25 - (i * 0.035)),
                            Colors.red.withOpacity(0.0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.15 - (i * 0.02)),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              
              // Enhanced Cricket Bat with 3D effect
              Transform.translate(
                offset: const Offset(-60, 30),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-0.2),
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: batRotation,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 105,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFFB8733C),
                                const Color(0xFFE89F5F),
                                const Color(0xFFFFC589),
                                const Color(0xFFE89F5F),
                                const Color(0xFFB8733C),
                              ],
                              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(4, 4),
                              ),
                              BoxShadow(
                                color: Color(0xFFFFD700).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(-2, -2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 2.5,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B4513).withOpacity(0.4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Wood grain effect
                              ...List.generate(3, (i) => Positioned(
                                left: 6 + (i * 6.0),
                                child: Container(
                                  width: 1,
                                  height: 105,
                                  color: const Color(0xFF8B4513).withOpacity(0.15),
                                ),
                              )),
                            ],
                          ),
                        ),
                        Container(
                          width: 14,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF2C1810),
                                const Color(0xFF1A0F08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              7,
                              (index) => Container(
                                height: 2.5,
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.withOpacity(0.8),
                                      Colors.red.withOpacity(0.6),
                                      Colors.red.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Enhanced impact flash with 3D rings
              if (impactOpacity > 0)
                Transform.translate(
                  offset: const Offset(-30, 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ...List.generate(3, (i) => Container(
                        width: 70.0 + (i * 25),
                        height: 70.0 + (i * 25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(impactOpacity * (0.6 - i * 0.2)),
                            width: 3,
                          ),
                        ),
                      )),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(impactOpacity * 0.9),
                              Colors.yellow.withOpacity(impactOpacity * 0.6),
                              Colors.orange.withOpacity(impactOpacity * 0.3),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.3, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(impactOpacity * 0.8),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Enhanced Cricket Ball with 3D lighting
              Transform.translate(
                offset: Offset(ballX, ballY),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(ballRotation * 0.3)
                    ..rotateZ(ballRotation),
                  alignment: Alignment.center,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment(-0.3, -0.4),
                        colors: [
                          const Color(0xFFFF4444),
                          const Color(0xFFCC0000),
                          const Color(0xFF990000),
                          const Color(0xFF660000),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.7),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(-3, -3),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: CricketBallSeamPainter(),
                    ),
                  ),
                ),
              ),
              
              // 3D Sport label
              Positioned(
                top: 50,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(0.15),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Text(
                      'CRICKET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                          Shadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadmintonAnimation() {
    double progress = ((_animation.value - 0.33) * 3).clamp(0.0, 1.0);
    
    double racketRotation = progress < 0.4 
        ? -0.9 + (Curves.easeInCubic.transform(progress / 0.4) * 1.6)
        : 0.7;
    
    double shuttleProgress = progress < 0.4 ? 0 : (progress - 0.4) / 0.6;
    double shuttleX = Curves.easeOut.transform(shuttleProgress) * 380;
    double shuttleY = -shuttleProgress * 220 + (shuttleProgress * shuttleProgress * 280);
    double shuttleRotation = shuttleProgress * 6 * math.pi;
    
    double impactOpacity = (progress > 0.38 && progress < 0.45) 
        ? 1.0 - ((progress - 0.38) / 0.07)
        : 0.0;

    double depthScale = 0.95 + (0.05 * math.sin(progress * math.pi * 2));

    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0.1)
          ..scale(depthScale),
        alignment: Alignment.center,
        child: SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shuttlecock trail
              if (shuttleProgress > 0)
                ...List.generate(5, (i) {
                  double trailProgress = (shuttleProgress - (i * 0.05)).clamp(0.0, 1.0);
                  double trailX = Curves.easeOut.transform(trailProgress) * 380;
                  double trailY = -trailProgress * 220 + (trailProgress * trailProgress * 280);
                  return Transform.translate(
                    offset: Offset(trailX, trailY),
                    child: Opacity(
                      opacity: 0.3 - (i * 0.06),
                      child: Transform.scale(
                        scale: 1.0 - (i * 0.15),
                        child: _buildShuttlecock(28),
                      ),
                    ),
                  );
                }),
              
              // Enhanced Badminton Racket with 3D effect
              Transform.translate(
                offset: const Offset(-90, 10),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-0.15),
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: racketRotation,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 75,
                          height: 95,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment(-0.3, -0.3),
                              colors: [
                                const Color(0xFFFFE082),
                                const Color(0xFFFFD700),
                                const Color(0xFFFFA500),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            border: Border.all(
                              width: 8,
                              color: const Color(0xFFFFD700),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.6),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.4),
                                blurRadius: 20,
                                offset: Offset(-3, -3),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: RacketStringsPainter(),
                          ),
                        ),
                        Container(
                          width: 9,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFF333333),
                                const Color(0xFF555555),
                                const Color(0xFF333333),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF2C2C2C),
                                const Color(0xFF1A1A1A),
                                const Color(0xFF0D0D0D),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              8,
                              (index) => Container(
                                height: 2.5,
                                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00E5FF).withOpacity(0.8),
                                      const Color(0xFF00B8D4).withOpacity(0.6),
                                      const Color(0xFF00E5FF).withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Enhanced impact flash
              if (impactOpacity > 0)
                Transform.translate(
                  offset: const Offset(-40, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ...List.generate(3, (i) => Container(
                        width: 80.0 + (i * 30),
                        height: 80.0 + (i * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(impactOpacity * (0.5 - i * 0.15)),
                            width: 2.5,
                          ),
                        ),
                      )),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(impactOpacity * 0.8),
                              Colors.yellow.withOpacity(impactOpacity * 0.5),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(impactOpacity * 0.7),
                              blurRadius: 45,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Shuttlecock with 3D effect
              Transform.translate(
                offset: Offset(shuttleX, shuttleY),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(shuttleRotation * 0.2)
                    ..rotateZ(shuttleRotation),
                  alignment: Alignment.center,
                  child: _buildShuttlecock(32),
                ),
              ),
              
              // 3D Sport label
              Positioned(
                top: 50,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(0.15),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Text(
                      'BADMINTON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                          Shadow(
                            color: Colors.cyan.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShuttlecock(double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 0.85,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                const Color(0xFFF5F5F5),
                Colors.white.withOpacity(0.95),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size * 0.7),
              topRight: Radius.circular(size * 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                blurRadius: 18,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: CustomPaint(
            painter: ShuttlecockFeathersPainter(),
          ),
        ),
        Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment(-0.3, -0.3),
              colors: [
                const Color(0xFF43A047),
                const Color(0xFF2E7D32),
                const Color(0xFF1B5E20),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(1, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFootballAnimation() {
    double progress = ((_animation.value - 0.66) * 3).clamp(0.0, 1.0);
    
    double bounceY = 0.0;
    double scale = 1.0;
    double rotation = progress * 4 * math.pi;
    
    if (progress < 0.25) {
      double t = progress / 0.25;
      bounceY = -Curves.easeOut.transform(t) * 130 + (t * t * 130);
      scale = 0.55 + (t * 0.45);
    } else if (progress < 0.5) {
      double t = (progress - 0.25) / 0.25;
      bounceY = -Curves.easeOut.transform(t) * 85 + (t * t * 85);
    } else if (progress < 0.75) {
      double t = (progress - 0.5) / 0.25;
      bounceY = -Curves.easeOut.transform(t) * 45 + (t * t * 45);
    } else {
      double t = (progress - 0.75) / 0.25;
      bounceY = -Curves.easeOut.transform(t) * 18 + (t * t * 18);
    }

    double depthScale = 0.95 + (0.05 * math.sin(progress * math.pi * 2));

    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(0.1)
          ..scale(depthScale),
        alignment: Alignment.center,
        child: SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Enhanced ground shadow with 3D effect
              Positioned(
                bottom: 70,
                child: Container(
                  width: 150 * scale,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.5 * scale),
                        Colors.black.withOpacity(0.2 * scale),
                        Colors.black.withOpacity(0.0),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Enhanced Football with 3D lighting
              Transform.translate(
                offset: Offset(0, bounceY - 20),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(rotation * 0.3)
                    ..rotateZ(rotation),
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(-0.4, -0.4),
                          colors: [
                            Colors.white,
                            const Color(0xFFFAFAFA),
                            const Color(0xFFF0F0F0),
                            const Color(0xFFE0E0E0),
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.7),
                            blurRadius: 30,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 25,
                            offset: Offset(-4, -4),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 18,
                            offset: const Offset(5, 5),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: FootballPainter(),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 3D Sport label
              Positioned(
                top: 50,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(0.15),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Text(
                      'FOOTBALL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Poppins',
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                          Shadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Enhanced ground line with 3D effect
              Positioned(
                bottom: 70,
                child: Container(
                  width: 260,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        blurRadius: 10,
                      ),
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
}

// Enhanced Particle background painter
class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      double x = (size.width * (i * 0.11)) % size.width;
      double y = ((size.height * (i * 0.17)) + (animationValue * size.height * 0.7)) % size.height;
      double radius = 1.5 + (i % 4) * 0.8;
      double opacity = 0.08 + ((i % 5) * 0.02);
      
      paint.color = Colors.white.withOpacity(opacity);
      
      // Add glow effect
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}

// Cricket ball seam painter
class CricketBallSeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double centerX = size.width / 2;
    double centerY = size.height / 2;

    Path seamPath = Path();
    seamPath.moveTo(centerX - size.width * 0.3, centerY - size.height * 0.15);
    seamPath.quadraticBezierTo(
      centerX,
      centerY - size.height * 0.45,
      centerX + size.width * 0.3,
      centerY - size.height * 0.15,
    );
    seamPath.moveTo(centerX - size.width * 0.3, centerY + size.height * 0.15);
    seamPath.quadraticBezierTo(
      centerX,
      centerY + size.height * 0.45,
      centerX + size.width * 0.3,
      centerY + size.height * 0.15,
    );

    canvas.drawPath(seamPath, paint);
    
    paint.strokeWidth = 1.8;
    for (int i = 0; i < 7; i++) {
      double x = centerX - size.width * 0.27 + (i * size.width * 0.09);
      canvas.drawLine(
        Offset(x, centerY - size.height * 0.2),
        Offset(x, centerY - size.height * 0.1),
        paint,
      );
      canvas.drawLine(
        Offset(x, centerY + size.height * 0.1),
        Offset(x, centerY + size.height * 0.2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Racket strings painter
class RacketStringsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < 6; i++) {
      double x = size.width * i / 6;
      canvas.drawLine(Offset(x, 5), Offset(x, size.height - 5), paint);
    }

    for (int i = 1; i < 7; i++) {
      double y = size.height * i / 7;
      canvas.drawLine(Offset(5, y), Offset(size.width - 5, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Shuttlecock feathers painter
class ShuttlecockFeathersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 10; i++) {
      double x = size.width * (i + 0.5) / 10;
      canvas.drawLine(
        Offset(x, 0),
        Offset(size.width / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Football painter
class FootballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2;

    Path pentagonPath = Path();
    for (int i = 0; i < 5; i++) {
      double angle = (i * 2 * math.pi / 5) - math.pi / 2;
      double x = centerX + radius * 0.28 * math.cos(angle);
      double y = centerY + radius * 0.28 * math.sin(angle);
      if (i == 0) {
        pentagonPath.moveTo(x, y);
      } else {
        pentagonPath.lineTo(x, y);
      }
    }
    pentagonPath.close();
    canvas.drawPath(pentagonPath, paint);

    for (int i = 0; i < 5; i++) {
      double angle = (i * 2 * math.pi / 5) - math.pi / 2;
      double x = centerX + radius * 0.65 * math.cos(angle);
      double y = centerY + radius * 0.65 * math.sin(angle);
      
      Path hexPath = Path();
      for (int j = 0; j < 6; j++) {
        double hexAngle = (j * 2 * math.pi / 6) + angle;
        double hx = x + radius * 0.18 * math.cos(hexAngle);
        double hy = y + radius * 0.18 * math.sin(hexAngle);
        if (j == 0) {
          hexPath.moveTo(hx, hy);
        } else {
          hexPath.lineTo(hx, hy);
        }
      }
      hexPath.close();
      canvas.drawPath(hexPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}