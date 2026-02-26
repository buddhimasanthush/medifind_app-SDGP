import 'package:flutter/material.dart';

class WelcomeBackPage extends StatefulWidget {
  const WelcomeBackPage({super.key});

  @override
  State<WelcomeBackPage> createState() => _WelcomeBackPageState();
}

class _WelcomeBackPageState extends State<WelcomeBackPage>
    with SingleTickerProviderStateMixin {
  bool _isSignInSelected = true; // Default to Sign In selected
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _navigateToPage(bool isSignIn) {
    if (_animationController == null) return; // Safety check

    setState(() {
      _isSignInSelected = isSignIn;
    });

    // Animate the pill
    if (isSignIn) {
      _animationController!.reverse();
    } else {
      _animationController!.forward();
    }

    // Wait for animation to finish, then navigate
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        if (isSignIn) {
          Navigator.pushNamed(context, '/signin');
        } else {
          Navigator.pushNamed(context, '/signup');
        }
        // Reset animation after navigation
        _animationController?.reset();
        if (mounted) {
          setState(() {
            _isSignInSelected = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0796DE),
        ),
        child: Stack(
          children: [
            // Decorative circles (matching Figma exactly)
            _buildDecorativeCircles(),

            // Main content centered
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo - centered
                  Image.asset(
                    'assets/images/New logo VERT 1.png',
                    width: 132,
                    height: 74,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'MediFind',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Welcome Back text - centered
                  const Text(
                    'Welcome\nBack',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -0.48,
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Bottom buttons with sliding pill - EXACT Figma design
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    // Animated sliding white pill
                    AnimatedBuilder(
                      animation: _animation ?? AlwaysStoppedAnimation(0.0),
                      builder: (context, child) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final animValue = _animation?.value ?? 0.0;
                        final leftPosition =
                            (animValue * (screenWidth / 2)) - 76;

                        return Positioned(
                          left: leftPosition,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: (screenWidth / 2) + 76,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(63),
                                topRight: Radius.circular(63),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Button texts
                    Row(
                      children: [
                        // Sign In button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _navigateToPage(true),
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  color: _isSignInSelected
                                      ? const Color(0xFF0796DE)
                                      : Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.32,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Sign Up button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _navigateToPage(false),
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: !_isSignInSelected
                                      ? const Color(0xFF0796DE)
                                      : Colors.white,
                                  fontSize: 32,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          left: 124.48,
          top: 5.38,
          child: Transform.rotate(
            angle: 0.53,
            child: Container(
              width: 183,
              height: 183,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 112.01,
          top: 104.44,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 3.03,
              child: Container(
                width: 153.81,
                height: 153.81,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: const Alignment(0.93, 0.35),
                    end: const Alignment(0.06, 0.40),
                    colors: [const Color(0xAFFDEDCA), const Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 14.30,
          top: -19.87,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 0.57,
              child: Container(
                width: 89.35,
                height: 89.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: const Alignment(0.93, 0.35),
                    end: const Alignment(0.06, 0.40),
                    colors: [const Color(0xFFFDEDCA), const Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 92.99,
          top: 216.82,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 3.03,
              child: Container(
                width: 94.08,
                height: 94.08,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: const Alignment(0.93, 0.35),
                    end: const Alignment(0.06, 0.40),
                    colors: [const Color(0xAFFDEDCA), const Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 292.47,
          top: -117,
          child: Transform.rotate(
            angle: 0.40,
            child: Container(
              width: 167,
              height: 167,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 249.59,
          top: 336.74,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 6.17,
              child: Container(
                width: 153.81,
                height: 153.81,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: const Alignment(0.93, 0.35),
                    end: const Alignment(0.06, 0.40),
                    colors: [const Color(0xAFFDEDCA), const Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 371.17,
          top: 421.47,
          child: Opacity(
            opacity: 0.30,
            child: Transform.rotate(
              angle: 3.71,
              child: Container(
                width: 89.35,
                height: 89.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: const Alignment(0.93, 0.35),
                    end: const Alignment(0.06, 0.40),
                    colors: [const Color(0xFFFDEDCA), const Color(0xFF0A9BE2)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 69.13,
          top: 469.42,
          child: Transform.rotate(
            angle: 3.54,
            child: Container(
              width: 167,
              height: 167,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 30, color: const Color(0xFF10A2EA)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
