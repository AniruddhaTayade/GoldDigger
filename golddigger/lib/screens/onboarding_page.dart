import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'loading_screen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final Set<int> _animatedPages = {};
  final Map<int, bool> _titleVisible = {};
  final Map<int, bool> _subtitleVisible = {};

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/maincarousel1.png',
      'title': 'Plan Smart. Save Big.',
      'subtitle':
          'Master your money with AI-powered financial planning made simple.',
    },
    {
      'image': 'assets/maincarousel3.png',
      'title': 'Track. Spend. Level Up.',
      'subtitle':
          'Your money, your rules. Get real-time spending insights and control.',
    },
    {
      'image': 'assets/maincarousel2.png',
      'title': 'Work smartly for future.',
      'subtitle':
          'Discover AI-backed insights to boost your finances every day.',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Animate the first page on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runPageAnimations(0);
    });

    _controller.addListener(() {
      final newPage = _controller.page?.round() ?? 0;
      if (newPage != _currentPage) {
        _currentPage = newPage;
        if (!_animatedPages.contains(newPage)) {
          _runPageAnimations(newPage);
        }
      }
    });
  }

  void _runPageAnimations(int pageIndex) {
    _animatedPages.add(pageIndex);
    _titleVisible[pageIndex] = false;
    _subtitleVisible[pageIndex] = false;

    setState(() {}); // Refresh to reset

    Future.delayed(const Duration(milliseconds: 200), () {
      _titleVisible[pageIndex] = true;
      setState(() {});
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _subtitleVisible[pageIndex] = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              final showTitle = _titleVisible[index] ?? false;
              final showSubtitle = _subtitleVisible[index] ?? false;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 🖼 Background image
                  Image.asset(
                    page['image']!,
                    fit: BoxFit.cover,
                  ),

                  // 🟫 Overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // 📝 Title + Subtitle
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: screenHeight * 0.70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: showTitle ? 1.0 : 0.7,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          child: AnimatedOpacity(
                            opacity: showTitle ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              page['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedOpacity(
                          opacity: showSubtitle ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            page['subtitle']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Slide-to-unlock only on last page
                  if (index == pages.length - 1) const _SlideToUnlockButton(),
                ],
              );
            },
          ),

          // 🔘 Dots
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: const WormEffect(
                  dotColor: Colors.white38,
                  activeDotColor: Colors.white,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 Custom Slide Button Widget
class _SlideToUnlockButton extends StatefulWidget {
  const _SlideToUnlockButton();

  @override
  State<_SlideToUnlockButton> createState() => _SlideToUnlockButtonState();
}

class _SlideToUnlockButtonState extends State<_SlideToUnlockButton> {
  double _dragX = 0;
  late double _maxDrag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    _maxDrag = screenWidth - 80 - 60; // padding (40+40) and handle size (60)
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_dragX / _maxDrag).clamp(0.0, 1.0);

    return Positioned(
      bottom: 100,
      left: 40,
      right: 40,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white24),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Centered Crossfading Text
            Center(
              child: Stack(
                children: [
                  Opacity(
                    opacity: 1.0 - progress,
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: progress,
                    child: const Text(
                      "Way to Wealth",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sliding Button
            Positioned(
              left: _dragX,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragX += details.delta.dx;
                    _dragX = _dragX.clamp(0, _maxDrag);
                  });
                },
                onHorizontalDragEnd: (_) {
                  if (_dragX >= _maxDrag * 0.9) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoadingScreen()),
                    );
                  }
                  setState(() => _dragX = 0); // Reset
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white30,
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
