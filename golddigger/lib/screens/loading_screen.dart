import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'sign_up.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  int _currencyIndex = 0;

  final List<String> currencies = ['\$', '€', '₹', '¥', '£'];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currencyIndex = (_currencyIndex + 1) % currencies.length;
          });
          _controller.reset();
          _controller.forward();
        }
      });

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
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
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final isSecondHalf = _flipAnimation.value > pi / 2;
            final displayText = currencies[_currencyIndex];

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value),
              child: Opacity(
                opacity: 1.0,
                child: Transform.scale(
                  scale: isSecondHalf ? 1.05 : 1.0,
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 60,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
