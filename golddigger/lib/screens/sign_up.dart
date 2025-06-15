import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'sign_in.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌌 Background image
          Image.asset(
            'assets/login.png',
            fit: BoxFit.cover,
          ),

          // 🌚 Optional dark overlay
          Container(color: Colors.black.withOpacity(0.4)),

          // 🔲 Foreground content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hii Welcome back, you've been misssed",
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 40),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.purpleAccent),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white38)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Or sign in with',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white38)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SocialCircle(
                          icon: FontAwesomeIcons.facebook, color: Colors.blue),
                      SocialCircle(
                          icon: FontAwesomeIcons.google, color: Colors.red),
                      SocialCircle(
                          icon: FontAwesomeIcons.apple, color: Colors.black),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't Have an Account? ",
                        style: TextStyle(color: Colors.white60),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAccountPage()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.purpleAccent),
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
    );
  }
}

class HoverIcon extends StatefulWidget {
  final IconData icon;
  const HoverIcon({super.key, required this.icon});

  @override
  State<HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 24,
          child: Icon(
            widget.icon,
            color: isMobile
                ? Colors.black
                : _hovering
                    ? Colors.purpleAccent
                    : Colors.black,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class SocialCircle extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final Color? color;

  const SocialCircle({
    super.key,
    this.icon,
    this.iconAsset,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 15),
          )
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: color ?? Colors.black, size: 30)
            : iconAsset != null
                ? Image.asset(iconAsset!, width: 30, height: 30)
                : const SizedBox(),
      ),
    );
  }
}
